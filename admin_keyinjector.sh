#!/bin/bash
set -e

: ${CEPH_ADMIN_USER:?"Need to set CEPH_ADMIN_USER environment variable"}
#create ceph admin user (root user for ceph manipulation) - comes from an evn variable CEPH_ADMIN_USER (in OpenNebula provided by conttextualization custom_vars)
useradd -d /home/$CEPH_ADMIN_USER -m $CEPH_ADMIN_USER
echo "$CEPH_ADMIN_USER ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/$CEPH_ADMIN_USER
chmod 0440 /etc/sudoers.d/$CEPH_ADMIN_USER

#cp /mnt/idrsaprivate.tar.gz/idrsaprivate /tmp
#cp /mnt/idrsapublic.tar.gz/idrsapublic /tmp


mkdir /home/$CEPH_ADMIN_USER/.ssh
chmod 700 /home/$CEPH_ADMIN_USER/.ssh
cp /mnt/idrsaprivate.tar.gz/idrsaprivate /home/$CEPH_ADMIN_USER/.ssh/id_rsa
cp /mnt/idrsapublic.tar.gz/idrsapublic /home/$CEPH_ADMIN_USER/.ssh/id_rsa.pub
cp /mnt/idrsapublic.tar.gz/idrsapublic /home/$CEPH_ADMIN_USER/.ssh/authorized_keys #this will overwrite - should handle other key situations
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/authorized_keys
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/id_rsa.pub
chmod 0600 /home/$CEPH_ADMIN_USER/.ssh/id_rsa
chown -R $CEPH_ADMIN_USER:$CEPH_ADMIN_USER /home/$CEPH_ADMIN_USER/.ssh
yum install -y ntp ntpdate ntp-doc
yum install -y yum-plugin-priorities

#need to setup ceph repo and  install ceph-deploy
cp ceph.repo /etc/yum.repos.d/ceph.repo
yum updateinfo && yum install -y ceph-deploy
