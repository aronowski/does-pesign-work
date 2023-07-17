#!/bin/bash -x

sudo dnf install -y grubby https://repo.almalinux.org/vault/9.0/AppStream/x86_64/os/Packages/pesign-113-21.el9.x86_64.rpm softhsm 
sudo usermod -a -G pesign vagrant
sudo bash -c "echo 'vagrant' >> /etc/pesign/users"
sudo grubby --update-kernel ALL --args selinux=0

softhsm2-util --init-token --label HSM --so-pin Secret.123 --pin Secret.123 --free
