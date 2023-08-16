#!/bin/bash -xe

sudo dnf install -y git grubby openssl pesign rpmdevtools softhsm

sudo usermod -a -G pesign vagrant
#sudo bash -c "echo 'vagrant' >> /etc/pesign/users" # unused?

sudo setenforce 0 ; sudo grubby --update-kernel ALL --args selinux=0

export PESIGN_TOKEN_PIN="Secret.123"
softhsm2-util --init-token --label HSM --so-pin ${PESIGN_TOKEN_PIN} --pin ${PESIGN_TOKEN_PIN} --free
modutil -dbdir /etc/pki/pesign -list

# .p12 stuff
git clone https://github.com/rhboot/shim.git --depth 1
pushd shim
./make-certs example
pk12util -k <(echo "${PESIGN_TOKEN_PIN}") -w /dev/zero -i example.p12 -d /etc/pki/pesign -h HSM
popd

# permission fixes to be applied only after the .p12 import
sudo chmod -R 777 /var/lib/softhsm/
sudo /usr/libexec/pesign/pesign-authorize

sudo dnf reinstall -y pesign && sudo systemctl start pesign

pesign-client -u -t HSM || sudo journalctl --no-pager --unit=pesign.service --output=cat

# An error message like below should be printed, but it's not, unless SSHing to the vagrant box and running the unlock command manually.
# OSSLEVPSymmetricAlgorithm.cpp(512): EVP_DecryptFinal failed (0x00000000): error:1C800064:Provider routines::bad decrypt
# In regard to https://stackoverflow.com/questions/34304570/how-to-resolve-the-evp-decryptfinal-ex-bad-decrypt-during-file-decryption, Was there some mismatch regarding OpenSSL versions when different applications were being compiled (openssl, pesign, softhsm, etc.) or something?

