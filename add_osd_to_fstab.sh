#!/bin/bash
#Wes Dillingham
#wes_dillingham@harvard.edu
#https://github.com/wwdillingham

#The purpose of this script is to determine pre-existing filesystem mounts as setup and mounted by the ceph-deploy utility.
# ceph-deploy mounts them at creation time and this script takes it a step further and defines that mount in /etc/fstab. 
#Basically we scan for existing ceph-osd mount points, extract the uuid and then insert an entry into fstab mounting by that uuid
if [[ $1 == "--help" ]]; then
	echo "The following options are supported:"
	echo "--yes | -y : run non interactively (assume yes for all answers)"
	echo "--help : print this menu"
	exit
elif [[ $1 == "--yes" || $1 == "-y" ]]; then
	UNNATENDED=true
fi

IFS=$'\n' #set internal field seperator to get whole lines
for i in `grep -i ceph /proc/mounts` 
do
	#Harvest the fields
	#echo "The whole lines: $i"
	PARTITION=`echo $i | cut -f1 -d " "`
	echo "The partition is $PARTITION"
	MOUNTPOINT=`echo $i | cut -f2 -d " "`
	echo "mountpoint is $MOUNTPOINT"
	FILESYSTEM=`echo $i | cut -f3 -d " "`
	echo "filesystem type is $FILESYSTEM"
	MOUNTOPTIONS=`echo $i | cut -f4 -d " "`
	echo "mount options are $MOUNTOPTIONS"
	DUMP=`echo $i | cut -f5 -d " "`
	echo "The dump is $DUMP"
	PASS=`echo $i | cut -f6 -d " "`
	echo "The pass is $PASS"

	#get the filesystem UUID
	UUID=`blkid $PARTITION | cut -f2 -d " "`	
	echo "UUID is $UUID"
	
	echo -e "$UUID \t $MOUNTPOINT \t $FILESYSTEM \t $MOUNTOPTIONS \t $DUMP $PASS" >> /tmp/temp_fstab

done

echo -e "The following is going to be added to /etc/fstab:"	
echo -e "-------------------------------------------------------------------------------------------------------- \n\n"	
cat /tmp/temp_fstab
echo -e "\n\n"
echo -e "-------------------------------------------------------------------------------------------------------- \n\n"

if [[ ! $UNNATENDED  ]]; then
	echo "Should I add this to fstab [Y/N] ?"
	read PROCEED
	if [[ $PROCEED == 'y' || $PROCEED == 'Y' ]]
	 then
		echo "Will proceed with updating /etc/fstab"
	else
		echo "cleaning up temp files and aborting"
		rm -f /tmp/temp_fstab
		exit
	fi
fi

if [[ $UNNATENDED -eq "true" || $PROCEED -eq "y" || $PROCEED -eq "Y" ]]; then
	cat /tmp/temp_fstab >> /etc/fstab
	echo "Cleaning up temp files"
	rm -f /tmp/temp_fstab
fi

