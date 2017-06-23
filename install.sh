#!/bin/sh
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
VERSION=23062017
##
set -e
case "$OSTYPE" in
  linux*)   OS="linux"  ;;
  *)        echo "Your operating system ('$OSTYPE') is not supported by BADS. Exiting." && exit 1 ;;
esac
##
LOGROTATEDIR=/etc/logrotate.d
SERVICEDIR=/usr/lib/systemd/system
LOGDIR=/var/log/bads
DIR=/opt/bads
DATE=$(date +%Y-%m-%d_%H:%M)
##
if [[ ! -e $LOGDIR ]]; then
    mkdir -p $LOGDIR
elif [[ ! -d $LOGDIR ]]; then
    echo "ERROR: $LOGDIR already exists but is not a directory... Please fix..." 2>&1
fi
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR
sudo su root
#cd /etc/ansible/roles/InstallBaculaAgent
#ssh-agent bash
#ssh-add /root/.ssh/id_rsa
#sleep 3
cd $DIR
cp -fuvb $DIR/bads.logrotate $LOGROTATEDIR/ >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
logrotate -f /etc/logrotate.conf >> $LOGDIR/bads.log 2>&1
cp -fuvb $DIR/bads.service $SERVICEDIR/ >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
systemctl -l enable bads.service >> $LOGDIR/bads.log 2>&1
systemctl -l start bads.service >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
systemctl -l status bads.service >> $LOGDIR/bads.log 2>&1
echo "-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "Instaling The Bacula Agent Deploy Server (ver.$VERSION)... Instaled at $DATE..." >> $LOGDIR/bads.log 2>&1
echo "Bacula Agent Deploy Server (ver.$VERSION) has been deployed successfully..."
exit 0
