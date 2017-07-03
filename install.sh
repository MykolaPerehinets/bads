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
##
case "$OSTYPE" in
  linux*)   OS="linux"  ;;
  *)        echo "Your operating system ('$OSTYPE') is not supported by BADS. Exiting." && exit 1 ;;
esac
## Configuration
VERSION=03072017
LOGROTATEDIR=/etc/logrotate.d
SERVICEDIR=/usr/lib/systemd/system
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
## Deploying
#$DIR/env-var.sh
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR
#sudo su root
cd $ANSIBLEDIR
ssh-agent bash
ssh-add /root/.ssh/id_rsa
sleep 3
cd $DIR
cp -fuvb $DIR/bads.logrotate $LOGROTATEDIR/ >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
logrotate -f /etc/logrotate.conf >> $LOGDIR/bads.log 2>&1
cp -fuvb $DIR/bads.service $SERVICEDIR/ >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
systemctl -l enable bads.service >> $LOGDIR/bads.log 2>&1
systemctl -l start bads.service >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
systemctl -l status bads.service >> $LOGDIR/bads.log 2>&1
if [[ ! -e $ENVVAR ]]; then
    cp -fuvb $DIR/env-var.sh.default $DIR/$ENVVAR >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
elif [[ ! -d $LOGDIR ]]; then
    cp -fuvb $DIR/env-var.sh.default $DIR/$ENVVAR.rpmnew >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
fi
chmod u+x $DIR/$ENVVAR
cp -fuvb $DIR/ansible/* $ANSIBLEDIR/ >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err
echo "-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "Instaling Bacula Agent Deploy Server (ver.$VERSION)... Instaled at $DATE..." >> $LOGDIR/bads.log 2>&1
echo "Ok... Bacula Agent Deploy Server (ver.$VERSION) has been deployed successfully..."
exit 0

