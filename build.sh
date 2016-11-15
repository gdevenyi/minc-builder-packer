#!/bin/bash
set -euo pipefail

mkdir -p /tmp/build

cd /tmp/build

#Make sure apt doesn't complain
export DEBIAN_FRONTEND=noninteractive

apt update

#Command line tools
apt install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common

apt-add-repository -y ppa:git-core/ppa
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list

apt update

apt install -y --no-install-recommends docker-engine git ruby-full

gem install package_cloud

service docker start

git clone --recursive --branch auto-build https://github.com/gdevenyi/minc-toolkit-v2.git minc-toolkit-v2 || true
cd minc-toolkit-v2
git clone https://github.com/packpack/packpack.git packpack
OS=ubuntu DIST=xenial ./packpack/packpack

for file in build/*.deb
do
    package_cloud push gdevenyi/minc-toolkit-v2/ubuntu/xenial $file
done
