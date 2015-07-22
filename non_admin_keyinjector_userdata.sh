#!/bin/bash
set -e 
env > /tmp/keyinjector_userdata_ran
source /mnt/context.sh

IDRSAPUBLIC=`cat idrsapublic`
echo $IDRSAPUBLIC > /root/id_rsa.pub
chmod 0644 /root/id_rsa.pub

