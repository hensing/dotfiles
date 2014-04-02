#!/bin/zsh

PASS=`kdialog --password "Bitte VPN-Passwort eingeben" 2>/dev/null`

sudo vpnc =(sed "s/PASSWORD/$PASS/g" /etc/vpnc/vorlage.conf)

