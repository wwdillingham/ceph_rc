#!/bin/bash
set -e
source /mnt/context.sh
export HOME=/tmp/userdata_launchpad
env > /tmp/keyinjector_userdata_ran
yum install -y epel-release
yum install -y git
git clone https://github.com/wwdillingham/ceph_rc $HOME
cd $HOME
bash non_admin_keyinjector.sh 2>&1 > /tmp/non_admin_keyinjector.log
