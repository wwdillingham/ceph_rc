#!/bin/bash
#Wesley Dillingham
#wes_dillingham@harvard.edu
#https://github.com/wwdillingham

SYSPART=`df | grep "/$" | cut -d" " -f1 | cut -d"/" -f3`
if [[ $SYSPART=="mapper" ]]
then
        echo "System disk is on an LVM - determining underlying block device..."
        SYSPART=`pvscan | grep -i root | awk -F " " '{print $2}' | awk -F "/" '{print $3}' | cut -c1,2,3`
fi
diskid='wwn'
echo "System on $SYSPART"

failed()
{
  sleep 2 # Wait for the kernel to stop whining
  echo "Hrm, that didn't work.  Calling for help."
#  sudo ipmitool chassis identify force
  echo "RAID Config failed: ${1}"
  while [ 1 ]; do sleep 10; done
  exit 1;
}

fakefailed()
{
  echo "ignoring megacli errors and forging on: ${1}"
}

echo "Making label on OSD devices"

# Data 
i=0
for DEV in `ls -al /dev/disk/by-id | grep $diskid | grep -v part | cut -f3 -d"/" | tr '\n' ' '`
do
  if [[ ! $SYSPART =~ $DEV ]]
  then 
    OSDNUM=`mount | grep -i $DEV | cut -f3 -d " " | cut -f2 -d "-"` #determine OSD device number osd.# that corresponds to block device
    echo "DEV is $DEV and the OSD is $OSDNUM"
    #ceph-deploy makes the data partition at /dev/sdx1 and the journal at /dev/sdx2
    ln -s /dev/${DEV}1 /dev/disk/by-partlabel/osd-device-$OSDNUM-data
    ln -s /dev/${DEV}2 /dev/disk/by-partlabel/osd-device-$OSDNUM-journal
    let "i++"
  fi
done
