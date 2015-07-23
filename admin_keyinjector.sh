#!/bin/bash
set -e

: ${CEPH_ADMIN_USER:?"Need to set CEPH_ADMIN_USER environment variable"}
echo "CEPH_ADMIN_USER is $CEPH_ADMIN_USER" >> /tmp/keyscript.log
#create ceph admin user (root user for ceph manipulation) - comes from an evn variable CEPH_ADMIN_USER (in OpenNebula provided by conttextualization custom_vars)
useradd -d /home/$CEPH_ADMIN_USER -m $CEPH_ADMIN_USER
echo "past useradd" >> /tmp/keyscript.log
echo "$CEPH_ADMIN_USER ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/$CEPH_ADMIN_USER
echo "past sudo" >> /tmp/keyscript.log
chmod 0440 /etc/sudoers.d/$CEPH_ADMIN_USER
echo "past chmod" >> /tmp/keyscript.log

IDRSAPRIVATE=`cat /mnt/idrsaprivate`
IDRSAPUBLIC=`cat /mnt/idrsapublic`

echo "IDRSAPRIVATE is $IDRSAPRIVATE" >> /tmp/keyscript.log
echo "IDRSAPUBLIC is $IDRSAPUBLIC" >> /tmp/keyscript.log

echo "$IDRSAPRIVATE" > /tmp/idpriv
echo "$IDRSAPUBLIC" > /tmp/idpub

mkdir /home/$CEPH_ADMIN_USER/.ssh
chmod 700 /home/$CEPH_ADMIN_USER/.ssh
echo $IDRSAPRIVATE > /home/$CEPH_ADMIN_USER/.ssh/id_rsa
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/id_rsa
echo $IDRSAPUBLIC > /home/$CEPH_ADMIN_USER/.ssh/authorized_keys
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/authorized_keys
