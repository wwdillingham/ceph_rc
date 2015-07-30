ceph-deploy purge $_ADMIN1 $_MON0 $_MON1 $_MON2 $_MDS0 $_OSD0 $_OSD1 $_OSD2
ceph-deploy purgedata $_ADMIN1 $_MON0 $_MON1 $_MON2 $_MDS0 $_OSD0 $_OSD1 $_OSD2
ceph-deploy forgetkeys
rm /tmp/userdata_launchpad/*.keyring
