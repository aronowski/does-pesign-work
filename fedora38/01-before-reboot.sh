#!/bin/bash -x

sudo dnf install -y grubby rpmdevtools softhsm autoconf automake bison device-mapper-devel flex fuse-devel gettext-devel help2man ncurses-devel rpm-devel squashfs-tools texinfo efivar-devel gcc git libuuid-devel make mandoc nspr-devel nss-devel nss-tools python3-rpm-macros

# What happens when cms_common has debug mode enabled?
rpmdev-setuptree
dnf download --source pesign-116-2.fc38
rpmdev-extract -C ~/rpmbuild/SOURCES/ pesign-116-2.fc38.src.rpm
cd ~/rpmbuild/SOURCES/
mv */* .
cp /vagrant/force_debug.patch .
echo "Patch1001: force_debug.patch" >> pesign.patches
rpmbuild -D 'dist .fc38.aronowski' -ba *.spec
sudo dnf -C install -y ~/rpmbuild/RPMS/x86_64/*.rpm

sudo usermod -a -G pesign vagrant
sudo bash -c "echo 'vagrant' >> /etc/pesign/users"
sudo /usr/libexec/pesign/pesign-authorize

sudo grubby --update-kernel ALL --args selinux=0

softhsm2-util --init-token --label HSM --so-pin Secret.123 --pin Secret.123 --free
sudo chmod -R 777 /var/lib/softhsm/

sudo dnf -C reinstall -y ~/rpmbuild/RPMS/x86_64/*.rpm
