#!/bin/bash
set -euo pipefail

mkdir -p /tmp/build

cd /tmp/build

#Make sure apt doesn't complain
export DEBIAN_FRONTEND=noninteractive

# Don't install recommends
echo 'apt::install-recommends "false";' > /etc/apt/apt.conf.d/00recommends

apt update

#Command line tools
apt install -y apt-transport-https ca-certificates software-properties-common

apt-add-repository -y ppa:git-core/ppa
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list

apt update

apt install -y docker-engine git ruby

gem install package_cloud

service docker start

git clone --depth 1 --recursive --branch auto-build https://github.com/gdevenyi/minc-toolkit-v2.git minc-toolkit-v2 || true
cd minc-toolkit-v2
git clone --branch ccache-optional https://github.com/gdevenyi/build.git packpack

export CCACHE_DISABLE=1

echo $BUILD_NAME
OS=$(echo $BUILD_NAME | grep -o -E '^.*\-' | tr -d '-' || true)
DIST=$(echo $BUILD_NAME | grep -o -E '\-.*$' | tr -d '-' || true)
export OS
export DIST

echo "Building OS=${OS}, DIST=${DIST}"


./packpack/packpack

for file in build/*.deb
do
    package_cloud push gdevenyi/minc-toolkit-v2/${OS}/${DIST} $file
done
