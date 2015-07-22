#!/bin/bash
set -e 
env > /tmp/keyinjector_userdata_ran
source /mnt/context.sh

IDRSAPRIVATE=`cat idrsaprivate`
IDRSAPUBLIC=`cat idrsapublic`
echo $IDRSAPRIVATE > /root/id_rsa
chmod 0600 /root/id_rsa
echo $IDRSAPUBLIC > /root/id_rsa.pub
chmod 0644 /root/id_rsa.pub

