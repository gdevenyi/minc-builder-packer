#!/bin/bash
set -euo pipefail

mkdir -p /tmp/provision

cd /tmp/provision

#Make sure apt doesn't complain
export DEBIAN_FRONTEND=noninteractive

apt update
apt -y full-upgrade
apt-get --purge -y autoremove

#Command line tools
apt install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common
apt-add-repository -y ppa:git-core/ppa
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list
apt update

apt install -y docker-engine git

service docker start

git clone --recursive https://github.com/BIC-MNI/minc-toolkit-v2.git
cd minc-toolkit-v2
git clone https://github.com/packpack/packpack.git packpack
./packpack/packpack

apt-get -y clean
apt-get -y --purge autoremove

#Cleanup to ensure extra files aren't packed into VM
cd ~
rm -rf /tmp/provision
rm -f /var/cache/apt/archives/*.deb
rm -rf /var/lib/apt/lists/*

dd if=/dev/zero of=/zerofillfile bs=1M || true
rm -f /zerofillfile
