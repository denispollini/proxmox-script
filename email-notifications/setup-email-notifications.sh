#!/bin/bash

# I update the package database and install the "mailutils" package
set -e
apt update
apt install -y libsasl2-modules mailutils

# Path to the configuration file "/etc/postfix/sasl_passwd"
SASL_PASSWD="/etc/postfix/sasl_passwd"

# Ask the user to enter the SMTP server
echo "Enter the SMTP server (e.g. smtp.domain.tld):"
read SERVER_SMTP

# Ask the user to enter the SMTP server port
echo "Enter the SMTP server port (e.g. 25,465,587):"
read SERVER_SMTP_PORT

# Ask the user to enter their email address
echo "Enter the email address for SMTP server authentication (e.g. smtp@domain.tld):"
read EMAIL_SMTP

# Enter your email user password
echo "Enter your email user password for SMTP server authentication (e.g. password123):"
read PASSWD_SMTP

# Verify that the user has entered all the required data
if [ -z "$SERVER_SMTP" ] || [ -z "$EMAIL_SMTP" ] || [ -z "$PASSWD_SMTP" ]; then
    echo "SMTP server, email or password not provided. Exit."
    exit 1
fi

# Replace only the device name and IP address part
echo -e "$SERVER_SMTP $EMAIL_SMTP:$PASSWD_SMTP" > $SASL_PASSWD

echo "The configuration was successfully updated."

chmod 600 /etc/postfix/sasl_passwd
postmap hash:/etc/postfix/sasl_passwd

cp  /etc/postfix/main.cf /etc/postfix/main.cf.bak

cat << EOF >> /etc/postfix/main.cf
# smtp oln configuration

relayhost = 
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/Entrust_Root_Certification_Authority.pem
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
smtp_header_checks = pcre:/etc/postfix/smtp_header_checks
EOF

sed -i "/relayhost/s/$/ $SERVER_SMTP:$SERVER_SMTP_PORT/" /etc/postfix/main.cf

echo "Configuration complete main.cf file"

apt install postfix-pcre

# Path to the configuration file "/etc/postfix/smtp_header_checks"
SMTP_HEADER_CHECKS="/etc/postfix/smtp_header_checks"

# Prompt the user to enter their display name when notification emails are sent
echo "Enter the display name you want when proxmox sends notification emails (e.g. customername-pve01):"
read NAME_EMAIL

# Prompt the user to enter their email address when notification emails are sent
echo "Enter the email address you want when notification emails are sent (e.g. pve01@customerdomain.tld):"
read EMAIL_SENDER_ADDRESS

# Verify that the user has entered all the required data
if [ -z "$NAME_EMAIL" ] || [ -z "$EMAIL_SENDER_ADDRESS" ]; then
    echo "Sender email name and/or email address not provided. Exit."
    exit 1
fi

# Sostituisci solo la parte relativa al nome del dispositivo e all'indirizzo IP
echo -e "/^From:.*/ REPLACE From: $NAME_EMAIL <$EMAIL_SENDER_ADDRESS>" > $SMTP_HEADER_CHECKS

echo "La configurazione è stata aggiornata con successo."

postmap hash:/etc/postfix/smtp_header_checks
postfix reload

#Test Email

#Chiedo all'utente indirizzo per invio mail di prova
echo "Inserisci indirizzo per inviare email di prova(es. indirizzo@dominio.tld):"
read EMAIL_TO_ADDRESS

echo "This is a test message sent from postfix on my Proxmox Server" | mail -s "Test Email from Proxmox" $EMAIL_TO_ADDRESS

echo "Script Completato."