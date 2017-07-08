#!/bin/sh -xe
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file. If not, see <http://www.gnu.org/licenses/>.
##
#
# Script Submitted and Deployment in production environments by:
# Mykola Perehinets (mperehin)
# Tel: +380 67 772 6910
# mailto:mykola.perehinets@gmail.com
#
##
case "$OSTYPE" in
  linux*)   OS="linux"  ;;
  *)        echo "Your operating system ('$OSTYPE') is not supported by BADS. Exiting." && exit 1 ;;
esac
## Configuration
VERSION=07072017
LOGDIR=/var/log/bads
ANSIBLEDIR=/etc/ansible/roles/InstallBaculaAgent
DIR=/opt/bads
DIR_DEPLOY=/opt
DIR_BUILD=/opt/bads
DIR_TEST=/opt/bads/tests
ENVVAR=env-var.sh
DATE=$(date +%Y-%m-%d_%H:%M)
# Golang version
GOVERSION=1.8.3
#OS=linux
ARCH=amd64
#
## Verifying
if [[ ! -e $LOGDIR ]]; then
    mkdir -p $LOGDIR
elif [[ ! -d $LOGDIR ]]; then
    echo "ERROR: $LOGDIR already exists but is not a directory... Please fix..." 2>&1
fi
## Deploying
#cd $DIR_DEPLOY

OS_VERSION=$1

# Clean the yum cache
yum -y clean all
yum -y clean expire-cache

# First, install all the needed packages
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OS_VERSION}.noarch.rpm
yum -y install yum-plugin-priorities ansible wget git tar
#yum -y install rpm-build gcc gcc-c++ boost-devel cmake git tar gzip make autotools

# Install the Go tools
# Download the archive and extract it into /usr/local, creating a Go tree in /usr/local/go
cd $DIR_DEPLOY
wget -c https://storage.googleapis.com/golang/go$GOVERSION.$OS-$ARCH.tar.gz
tar -C /usr/local -xzf go$GOVERSION.$OS-$ARCH.tar.gz
export PATH=/usr/local/go/bin:$PATH

# Build the BADS from source repo version
cd $DIR_DEPLOY
git clone https://github.com/MykolaPerehinets/bads.git
cd $DIR_BUILD
./install.sh

# Fix the lock file error on EL7.  /var/lock is a symlink to /var/run/lock
mkdir -p /var/run/lock

# Run unit tests

# BADS really, really wants a domain name. Fake one
#sed /etc/hosts -e "s/`hostname`/`hostname`.unl.edu `hostname`/" > /etc/hosts.new
#/bin/cp -f /etc/hosts.new /etc/hosts

# Bind on the right interface and skip hostname checks
#cat << EOF > /etc/condor/config.d/99-local.conf
#NETWORK_INTERFACE=eth0
#GSI_SKIP_HOST_CHECK=true
#SCHEDD_DEBUG=\$(SCHEDD_DEBUG) D_FULLDEBUG
#SCHEDD_INTERVAL=1
#SCHEDD_MIN_INTERVAL=1
#EOF
#cp /etc/condor/config.d/99-local.conf /etc/condor-ce/config.d/99-local.conf

# Some simple debug files for failures.
#openssl x509 -in $DIR_BUILD/server.crt -noout -text
echo "------------ BADS Logs --------------"
cat /var/log/bads.log
cat /var/log/bads.err
netstat -ntulp | grep bads

echo "-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "TEST: Testing Bacula Agent Deploy Server (ver.$VERSION)... Instaled and Tested at $DATE..." >> $LOGDIR/bads.log 2>&1
echo "TEST: Ok... Bacula Agent Deploy Server (ver.$VERSION) has been TESTED successfully..."
exit 0

