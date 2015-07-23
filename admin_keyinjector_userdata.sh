#!/bin/bash
set -e 
env > /tmp/keyinjector_userdata_ran
source /mnt/context.sh
yum install -y epel-release
yum install -y git 
export HOME=/tmp/userdata_launchpad
git clone https://github.com/wwdillingham/ceph_rc $HOME
cd $HOME
bash admin_keyinjector.sh 2>&1 /tmp/admin_keyinjector.log

