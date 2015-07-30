#/bin/bash
#Wes Dillingham
#wes_dillingham@harvard.edu
#Research Computing - Harvard University 
#All Rights Reserved

###### DO NOT Modify this script outside of the puppet repo, it is a template generated by puppet.
###### Any modifications directly to this file will be overwritten @ the next Puppet Run
#For every Ceph cluster, a group of scripts is to be deployed, including this one, it is dynamically populated by 
#Puppet, as a template, and is specific only to the cluster it is generated for, this is not a general pupose 
#script for use with ANY given ceph cluster, it is only to be used with this cluster: <$CLUSTERNAME>


#########   PURPOSE: ##########
#This scripts goal is to build a fully functional (Active+Clean) Ceph Cluster from bare hardware.
#It builds out ceph MDS, Ceph Mon and Ceph OSD nodes, and activates the components.
#This script expects that the target systems will have an OS installed, a user (cephrc) with passwordless sudo, 
# On the OSD hosts that the disks will be raw and clean of any previous configuration.

#host variable definitions
_MON0=
_MON1=
_MON2=
_MDS0=
_OSD0=
_OSD1=
_OSD2=
_ADMIN1=

#####Mons

#Prepare Firewall
ssh -t $_MON0 "sudo service firewalld stop"
ssh -t $_MON1 "sudo service firewalld stop"
ssh -t $_MON2 "sudo service firewalld stop"
ssh -t $_MDS0 "sudo service firewalld stop"
ssh -t $_OSD0 "sudo service firewalld stop"
ssh -t $_OSD1 "sudo service firewalld stop"
ssh -t $_OSD2 "sudo service firewalld stop"
sudo service firewalld stop

#Deploy
ceph-deploy new $_MON0 $_MON1 $_MON2 #initial monitor members

#Install ceph
ceph-deploy --overwrite-conf install $_ADMIN1 $_MON0 $_MON1 $_MON2 $_MDS0 $_OSD0 $_OSD1 $_OSD2

#Copy Mon Keyring
rsync -avhP --rsync-path="sudo rsync" ceph.mon.keyring $_OSD0:/etc/ceph/ceph.mon.keyring
rsync -avhP --rsync-path="sudo rsync" ceph.mon.keyring $_OSD1:/etc/ceph/ceph.mon.keyring
rsync -avhP --rsync-path="sudo rsync" ceph.mon.keyring $_OSD2:/etc/ceph/ceph.mon.keyring

# wait until they form quorum and then
# gatherkeys, reporting the monitor status along the
# process. If monitors don't form quorum the command
# will eventually time out.
ceph-deploy --overwrite-conf mon create-initial

#####OSDs

#first zap the disks
for i in `ssh $_OSD0 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy disk zap $_OSD0:$i; done
for i in `ssh $_OSD1 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy disk zap $_OSD1:$i; done
for i in `ssh $_OSD2 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy disk zap $_OSD2:$i; done

#Deploy the OSDs
for i in `ssh $_OSD0 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy osd prepare $_OSD0:$i:$i; done
for i in `ssh $_OSD1 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy osd prepare $_OSD1:$i:$i; done
for i in `ssh $_OSD2 "lsblk --output KNAME | grep -i sd | grep -v sda"`; do ceph-deploy osd prepare $_OSD2:$i:$i; done

#Activate the OSDs
for i in `ssh $_OSD0 "lsblk --output KNAME | grep -i sd | grep -v sda | grep 1"`; do ceph-deploy osd activate $_OSD0:${i}; done
for i in `ssh $_OSD1 "lsblk --output KNAME | grep -i sd | grep -v sda | grep 1"`; do ceph-deploy osd activate $_OSD1:${i}; done
for i in `ssh $_OSD2 "lsblk --output KNAME | grep -i sd | grep -v sda | grep 1"`; do ceph-deploy osd activate $_OSD2:${i}; done

#check cluster health
ceph health
