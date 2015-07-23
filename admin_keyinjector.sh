#!/bin/bash
set -e

: ${CEPH_ADMIN_USER:?"Need to set CEPH_ADMIN_USER environment variable"}

#create ceph admin user (root user for ceph manipulation) - comes from an evn variable CEPH_ADMIN_USER (in OpenNebula provided by conttextualization custom_vars)
useradd -d /home/$CEPH_ADMIN_USER -m $CEPH_ADMIN_USER
echo "$CEPH_ADMIN_USER ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$CEPH_ADMIN_USER
chmod 0440 /etc/sudoers.d/$CEPH_ADMIN_USER

IDRSAPRIVATE=`echo /mnt/idrsaprivate`
IDRSAPUBLIC=`echo /mnt/idrsapublic`

echo "$IDRSAPRIVATE" > /tmp/idpriv
echo "$IDRSAPUBLIC" > /tmp/idpub

mkdir /home/$CEPH_ADMIN_USER/.ssh
chmod 700 /home/$CEPH_ADMIN_USER/.ssh
echo $IDRSAPRIVATE > /home/$CEPH_ADMIN_USER/.ssh/id_rsa
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/id_rsa
echo $IDRSAPUBLIC > /home/$CEPH_ADMIN_USER/.ssh/authorized_keys
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/authorized_keys
