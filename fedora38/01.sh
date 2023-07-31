#!/bin/bash -x

sudo dnf install -y grubby pesign softhsm

sudo usermod -a -G pesign vagrant
sudo bash -c "echo 'vagrant' >> /etc/pesign/users"
sudo /usr/libexec/pesign/pesign-authorize

sudo setenforce 0 ; sudo grubby --update-kernel ALL --args selinux=0

softhsm2-util --init-token --label HSM --so-pin Secret.123 --pin Secret.123 --free
sudo chmod -R 777 /var/lib/softhsm/

sudo dnf reinstall -y pesign
