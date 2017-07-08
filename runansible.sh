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
VERSION=08072017
LOGDIR=/var/log/bads
ANSIBLEDIR=/etc/ansible/roles/InstallBaculaAgent
DIR=/opt/bads
DATE=$(date +%Y-%m-%d_%H:%M)
## Verifying
if [[ ! -e $LOGDIR ]]; then
    mkdir -p $LOGDIR
elif [[ ! -d $LOGDIR ]]; then
    echo "ERROR: $LOGDIR already exists but is not a directory... Please fix..." 2>&1
fi
## Starting
cd $DIR
echo "ANSIBLE:-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "ANSIBLE: Starting Ansible playbook... Start at $DATE..." >> $LOGDIR/bads.log 2>&1
#echo "" >> $LOGDIR/bads.log 2>&1
#sudo su root
cd $ANSIBLEDIR
ssh-agent bash >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err &
ssh-add /root/.ssh/id_rsa >> $LOGDIR/bads.log 2>> $LOGDIR/bads.err &
sleep 3
#
./ansible -K --limit InstallBaculaAgentTest ping.yml 2>&1
sleep 3
#
cd $DIR
echo "ANSIBLE:-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "ANSIBLE: Stoping Ansible playbook... Stop at $DATE..." >> $LOGDIR/bads.log 2>&1
echo "ANSIBLE: Ansible playbook has been stoped successfully..." >> $LOGDIR/bads.log 2>&1
echo "ANSIBLE: Ansible playbook has been stoped successfully..."
exit 0

