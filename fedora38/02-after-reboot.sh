#!/bin/bash -x

sudo systemctl start pesign
export PESIGN_TOKEN_PIN="Secret.123"
modutil -dbdir /etc/pki/pesign -list

pesign-client -u -t HSM #fail for unknown reason?
pesign-client --is-unlocked --token HSM

# Let's see a (hopefully) meaningful error message
#sudo journalctl --no-pager --grep=cms_common --unit=pesign.service --output=cat --lines=1
