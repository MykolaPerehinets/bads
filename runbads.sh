#!/bin/bash
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
ENVVAR=env-var.sh
DATE=$(date +%Y-%m-%d_%H:%M)
## Verifying
if [[ ! -e $LOGDIR ]]; then
    mkdir -p $LOGDIR
elif [[ ! -d $LOGDIR ]]; then
    echo "ERROR: $LOGDIR already exists but is not a directory... Please fix..." 2>&1
fi
## Starting
$DIR/$ENVVAR
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR
#sudo su root
cd $ANSIBLEDIR
ssh-agent bash
ssh-add /root/.ssh/id_rsa
sleep 3
cd $DIR
echo "-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "Starting Bacula Agent Deploy Server (ver.$VERSION)... Starting at $DATE..." >> $LOGDIR/bads.log 2>&1
$DIR/bads >> $LOGDIR/bads.log 2>&1 &
sleep 3
netstat -ntulp | grep bads >> $LOGDIR/bads.log 2>&1
echo "Ok... Bacula Agent Deploy Server (ver.$VERSION) has been started successfully..."
exit 0
