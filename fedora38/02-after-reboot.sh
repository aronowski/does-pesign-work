#!/bin/bash -x

sudo systemctl start pesign
export PESIGN_TOKEN_PIN="Secret.123"
modutil -dbdir /etc/pki/pesign -list

sudo chmod -R 777 /run/pesign /var/run/pesign

pesign-client -u -t HSM #fail for unknown reason?
