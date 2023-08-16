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
cd shim
./make-certs example
pk12util -k <(echo "${PESIGN_TOKEN_PIN}") -w /dev/zero -i example.p12 -d /etc/pki/pesign -h HSM

# permission fixes to be applied only after the .p12 import
sudo chmod -R 777 /var/lib/softhsm/
sudo /usr/libexec/pesign/pesign-authorize

sudo dnf reinstall -y pesign && sudo systemctl start pesign

pesign-client -u -t HSM #fail for unknown reason?
pesign-client --is-unlocked --token HSM

# let's try signing shimx64.efi
dnf download shim
rpmdev-extract shim-x64-*.x86_64.rpm
cd /home/vagrant/shim-x64-*.x86_64/boot/efi/EFI/fedora
pesign --remove-signature --signature-number=0 --in=shimx64.efi --out=shimx64.efi.unsigned
pesign-client -t HSM -c example -i ~/shimx64.efi.unsigned -o ~/shimx64.efi.signed -s 
