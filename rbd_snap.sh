#!/bin/bash
#Wes Dillingham
#wes_dillingham@harvard.edu

#based off work by scuttlemonkey and rapide.nl https://ceph.com/dev-notes/incremental-snapshots-with-rbd/

SOURCEPOOL="my-sourcepool"
DESTPOOL="my-destpool"
DESTHOST="root@xxx.xxx.xxx.xxx"

#what is today's date?

TODAY=`date +"%Y-%m-%d"`
YESTERDAY=`date +"%Y-%m-%d" --date="1 days ago"`

#list all images in the pool

IMAGES=`rbd ls $SOURCEPOOL`

for LOCAL_IMAGE in $IMAGES; do

	#check whether remote host/pool has image

	if [[ -z $(ssh $DESTHOST rbd ls $DESTPOOL | grep $LOCAL_IMAGE) ]]; then
		echo "info: image does not exist in remote pool. creating new image"

		#todo: check succesful creation

		`ssh $DESTHOST rbd create $DESTPOOL/$LOCAL_IMAGE -s 1`
	fi

	#create today's snapshot

	if [[ -z $(rbd snap ls $SOURCEPOOL/$LOCAL_IMAGE | grep $TODAY) ]]; then
		echo "info: creating snapshot $SOURCEPOOL/$LOCAL_IMAGE@$TODAY"
		`rbd snap create $SOURCEPOOL/$LOCAL_IMAGE@$TODAY`
	else
		echo "warning: source image $SOURCEPOOL/$LOCAL_IMAGE@$TODAY already exists"
	fi

	# check whether to do a init or a full

	if [[ -z $(ssh $DESTHOST rbd snap ls $DESTPOOL/$LOCAL_IMAGE) ]]; then
		echo "info: no snapshots found for $DESTPOOL/$LOCAL_IMAGE doing init"
		`rbd export-diff $SOURCEPOOL/$LOCAL_IMAGE@$TODAY - | ssh $DESTHOST rbd import-diff - $DESTPOOL/$LOCAL_IMAGE`
	else
		echo "info: found previous snapshots for $DESTPOOL/$LOCAL_IMAGE doing diff"

		#check yesterday's snapshot exists at remote pool

		if [[ -z $(ssh $DESTHOST rbd snap ls $DESTPOOL/$LOCAL_IMAGE | grep $YESTERDAY) ]]; then
				echo "error: --from-snap $LOCAL_IMAGE@$YESTERDAY does not exist on remote pool"
				exit 1
		fi
		#check todays's snapshot already exists at remote pool

		if [[ -z $(ssh $DESTHOST rbd snap ls $DESTPOOL/$LOCAL_IMAGE | grep $TODAY) ]]; then
				`rbd export-diff --from-snap $YESTERDAY $SOURCEPOOL/$LOCAL_IMAGE@$TODAY - | ssh $DESTHOST rbd import-diff - $DESTPOOL/$LOCAL_IMAGE`

				#comparing changed extents between source and destination

				SOURCE_HASH=`rbd diff --from-snap $YESTERDAY $SOURCEPOOL/$LOCAL_IMAGE@$TODAY --format json | md5sum | cut -d ' ' -f 1`
				DEST_HASH=`ssh $DESTHOST rbd diff --from-snap $YESTERDAY $DESTPOOL/$LOCAL_IMAGE@$TODAY --format json | md5sum | cut -d ' ' -f 1`

				if [ $SOURCE_HASH == $DEST_HASH ]; then
						echo "info: changed extents hash check ok"
				else
						echo "error: changed extents hash on source and destination don't match: $SOURCE_HASH not equals $DEST_HASH"
				fi
		else
				echo "error: snapshot $DESTPOOL/$LOCAL_IMAGE@$TODAY already exists, skipping"
				exit 1
		fi
	fi

done
