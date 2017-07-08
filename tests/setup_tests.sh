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
DIR=/opt/bads/tests
ENVVAR=env-var.sh
DATE=$(date +%Y-%m-%d_%H:%M)
## Verifying
if [[ ! -e $LOGDIR ]]; then
    mkdir -p $LOGDIR
elif [[ ! -d $LOGDIR ]]; then
    echo "ERROR: $LOGDIR already exists but is not a directory... Please fix..." 2>&1
fi
## Deploying
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR
#sudo su root
cd $DIR
# Version of CentOS/RHEL
el_version=$1
# Run tests in Container
if [ "$el_version" = "6" ]; then

sudo docker run --rm=true -v `pwd`:/opt/bads/tests:rw centos:centos${OS_VERSION} /bin/bash -c "bash -xe /opt/bads/tests/test_inside_docker.sh ${OS_VERSION}"

elif [ "$el_version" = "7" ]; then

docker run --privileged -d -ti -e "container=docker"  -v /sys/fs/cgroup:/sys/fs/cgroup -v `pwd`:/opt/bads/tests:rw  centos:centos${OS_VERSION}   /usr/sbin/init
DOCKER_CONTAINER_ID=$(docker ps | grep centos | awk '{print $1}')
docker logs $DOCKER_CONTAINER_ID
docker exec -ti $DOCKER_CONTAINER_ID /bin/bash -xec "bash -xe /opt/bads/tests/test_inside_docker.sh ${OS_VERSION};
  echo -ne \"------\nEND BADS CONTAINER TESTS\n\";"
docker ps -a
docker stop $DOCKER_CONTAINER_ID
docker rm -v $DOCKER_CONTAINER_ID

fi

echo "-----------------------------------------------------------------------------------------------------------------" >> $LOGDIR/bads.log 2>&1
echo "TEST: TEST CONTAINER for Bacula Agent Deploy Server (ver.$VERSION)... CREATED at $DATE..." >> $LOGDIR/bads.log 2>&1
echo "TEST: Ok... CONTAINER for Bacula Agent Deploy Server (ver.$VERSION) has been TESTED successfully..."
exit 0

