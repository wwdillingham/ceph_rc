#!/bin/bash
#Wes Dillingham
#wes_dillingham@harvard.edu
#Research Computing - Harvard University 
#All Rights Reserved



###### DO NOT Modify this script outside of the puppet repo, it is a template generated by puppet.
###### Any modifications directly to this file will be overwritten @ the next Puppet Run
#For every Ceph cluster, a group of scripts is to be deployed, including this one, it is dynamically populated by 
#Puppet, as a template, and is specific only to the cluster it is generated for, this is not a general pupose 
#script for use with ANY given ceph cluster, it is only to be used with this cluster: <$CLUSTERNAME>


#Purpose 
#This script is intended to stess test a ceph cluster it 

#I know who I am, do you know who you are?
if [[ `id -u` != 0 ]]; then
    echo "Must be superuser to run script"
    exit 1
fi


function print_help() {
	echo -e "--help : print this menu \n"
	echo "This utility has 4 modes"
        echo "Usage:   --rbd_dd [options]   or   --rbd_bonnie [options]   or   --rados_bench [options]    or   --rbd_benchwrite [options]"
        echo "Note either --rbd_dd or --rbd_bonnie or --rados_bench or --rbd_benchwrite must be passed as the first argument (order matters)"
        echo "----------------------------------------------"
        echo "--rbd_dd options:"
        echo "--num_block_devices=integer [required]"
        echo "--block_device_size=integer size in MB [required]"
        echo "--block_size=integer block size to use for write [required]"
        echo "--time=integer Time to sustain test. In progress write operations will continue, none  [required]"
        echo "--pool=string pool name to use, will create if non-existent but will not remove pool [required]"
        echo "--replication_size=integer number of replicas to make [required for non-existent pools, ignored for existing pools]"
        echo "--pg_num=integer number of placement groups for the pool [required for non-existent pools, ignored for existing pools]"
        echo "----------------------------------------------"
        echo "--rbd_bonnie options:"
        echo "--bonnie_string=\"string\" enclose bonnie++ options to run in parentheses [required]"
        echo "--num_block_devices=integer [required]"
        echo "--block_device_size=integer size in MB [required]"
        echo "--pool=string pool name to use, will create if non-existent but will not remove pool [required]"
        echo "--replication_size  number of replicas to make [required for non-existent pools, ignored for existing pools]"
        echo "--pg_num=integer number of placement groups for the pool [required for non-existent pools, ignored for existing pools]"
        echo "----------------------------------------------"
        echo "--rados_bench options:"
        echo "--time=integer Time to sustain test. In progress write operations will continue till completion [required]" 
        echo "--mode=[write,seq,rand] write mode to test ....., sequential writes, random writes [required]"
        echo "--ops=integer number of concurrent rados operations per client[required]"
        echo "--pool=string pool name to use, will create if non-existent but will not remove pool [required]"
        echo "--replication_size=integer number of replicas to make [required for non-existent pools, ignored for existing pools]"
        echo "--pg_num=integer number of placement groups for the pool [required for non-existent pools, ignored for existing pools]"
        echo "--rbd_benchwrite options:"
}

function check_create_pool() {
  if [[ `ceph osd lspools | grep -i "$1" | wc -l` == 0 ]]; then
    echo "Creating Pool: $1"
    rados mkpool $1
    ceph osd pool set $1 pg_num $2 
    ceph osd pool set $1 pgp_num $2
  else
    echo "That pool already exists - will use it for testing"
  fi
}


function rbd_dd() {
 NUM_BLOCK_DEVICE=$1
 SIZE_BLOCK_DEVICE=$2
 BLOCK_SIZE_IN_MB=$3
 TEST_TIME_IN_SEC=$4
 POOL_NAME=$5
 REPLICATION_SIZE=$6
 
 #first create the rbd devices and prep their mount points
 if ! [ -d /mnt/rbd_dd ]; then
   mkdir /mnt/rbd_dd
 fi
 RBD_MAP_LIST=()
 for rbd_device in `seq 1 $NUM_BLOCK_DEVICE`
 do
   if ! [ -d /mnt/rbd_dd/$rbd_device ]; then
     mkdir /mnt/rbd_dd/$rbd_device
     rbd -p $POOL_NAME create --size $SIZE_BLOCK_DEVICE rbd_test_$rbd_device
     #the output of the rbd map command is the /dev/rbdX that it gets mapped to exectute cmd and set variable:
     MAPPED_LOCATION=`rbd -p $POOL_NAME map rbd_test_$rbd_device`
     RBD_MAP_LIST+=($MAPPED_LOCATION)
     mkfs.xfs $MAPPED_LOCATION
   else
     echo "ERROR: /mnt/rbd_dd/$rbd_device already exists"
     echo "This is likely left over by a previous rbd_dd benchmark - please manually inspect"
     echo "and remove any directories in /mnt/rbd_dd that are no longer needed"
     echo "you may find the following useful:"
     echo "rbd showmapped"
     echo "mount | grep -i rbd"
     echo "Will now abort process to prevent any damage"
     exit
   fi
 done
 
}

function rados_bench() {
 TEST_TIME_IN_SEC=$1
 TEST_MODE=$2 #options are write | seq | rand
 CONCURRENT_OPERATIONS=$3
 OPERATION_SIZE_IN_MB=$4
 POOL_NAME=$5
 REPLICATION_SIZE=$6
}

function rbd_benchwrite() {
 IO_WRITE_SIZE=$
 IO_WRITE_THREADS=$

}


function rbd_bonnie() {
 BONNIE_STRING=$1
 POOL_NAME=$2
 REPLICATION_SIZE=$3
 }

function check_input_args_for_rbd_dd() {
  #At this point the first arg has been stripped off of the parameter list.
for arg in "$@"
do
	KEY=`echo $arg | awk -F "=" '{print $1}'`
  VALUE=`echo $arg | awk -F "=" '{print $2}'`
	#Check if there is a flag that shouldnt be there
	if [[ $KEY != "--num_block_devices" && $KEY != "--block_device_size" && $KEY != "--block_size" && $KEY != "--time" && $KEY != "-pool" && $KEY != "--replication_size" ]]; then
		echo "ERROR: $arg is not a valid parameter"
		print_help
		exit
	fi
  if [[ $KEY == "--num_block_devices" ]]; then
    NUM_BLOCK_DEVICE=$VALUE
  elif [[ $KEY == "--block_device_size" ]]
    SIZE_BLOCK_DEVICE=$VALUE
  elif [[ $KEY == "--block_size" ]]
    BLOCK_SIZE_IN_MB=$VALUE
  elif [[ $KEY == "--time" ]]
    TEST_TIME_IN_SEC=$VALUE
  elif [[ $KEY == "--pool" ]]
    POOL_NAME=$VALUE
  elif [[ $KEY == "--replication_size" ]]
    REPLICATION_SIZE=$VALUE
  elif [[ $KEY == "--pg_num" ]]
    PG_NUM=$VALUE
  fi
done

if ! [[ $NUM_BLOCK_DEVICE =~ ^[1-9]+$ ]]; then
  echo "ERROR: --num_block_devices must be a positive integer"
  print_help
  exit
fi
if ! [[ $SIZE_BLOCK_DEVICE =~ ^[1-9]+$ ]]; then
  echo "ERROR: --block_device_size must be a positive integer"
  print_help
  exit
fi
if ! [[ $BLOCK_SIZE_IN_MB =~ ^[1-9]+$ ]]; then
  echo "ERROR: --block_size must be a positive integer"
  print_help
  exit
fi
if ! [[ $TEST_TIME_IN_SEC =~ ^[1-9]+$ ]]; then
  echo "ERROR: --time must be a positive integer"
  print_help
  exit
fi
if ! [[ $REPLICATION_SIZE =~ ^[2-9]+$ ]]; then
  echo "ERROR: --replication_size must be a positive integer greater than 2"
  print_help
  exit
fi

if ! [[ $POOL_NAME =~ ^[0-9A-Za-z_]+$ ]]; then
  echo  "ERROR: --pool must be alphanumberic, including underscores, no spaces"
  print_help
  exit
fi
if ! [[ $PG_NUM =~ ^[2-9]+$ ]]; then
  echo  "ERROR: --pg_num must be a positive integer greater than 2"
  print_help
  exit
fi
if ! [ -z $POOL_NAME ]; then #if pool is passed to script, then lets try to create it
  check_create_pool $POOL_NAME $PG_NUM
fi

}


function check_input_args_for_rbd_bonnie() {
  #At this point the first arg has been stripped off of the parameter list.
  for arg in "$@"
  do
  	KEY=`echo $arg | awk -F "=" '{print $1}'`
    VALUE=`echo $arg | awk -F "=" '{print $2}'`

  	#Check if there is a flag that shouldnt be there
if [[ $KEY != "--bonnie_string" && $KEY != "--pool" && $KEY != "--replication_size" && $KEY != "--pg_num" && $KEY != "--num_block_devices" && $KEY != "--block_device_size" ]]; then
  echo "ERROR: $arg is not a valid parameter"
  print_help
  exit
fi

  if [[ $KEY == "--num_block_devices" ]]; then
    NUM_BLOCK_DEVICE=$VALUE
  elif [[ $KEY == "--block_device_size" ]]
    SIZE_BLOCK_DEVICE=$VALUE
  elif [[ $KEY == "--pool" ]]
    POOL_NAME=$VALUE
  elif [[ $KEY == "--replication_size" ]]
    REPLICATION_SIZE=$VALUE
  elif [[ $KEY == "--pg_num" ]]
    PG_NUM=$VALUE
  elif [[ $key == "--bonnie_string" ]]
    BONNIE_STRING=$VALUE
  fi
  

done  
  
if ! [[ $NUM_BLOCK_DEVICE =~ ^[1-9]+$ ]]; then
  echo "ERROR: --num_block_devices must be a positive integer"
  print_help
  exit
fi
if ! [[ $SIZE_BLOCK_DEVICE =~ ^[1-9]+$ ]]; then
  echo "ERROR: --block_device_size must be a positive integer"
  print_help
  exit
fi
if ! [[ $REPLICATION_SIZE =~ ^[2-9]+$ ]]; then
  echo "ERROR: --replication_size must be a positive integer greater than 2"
  print_help
  exit
fi

if ! [[ $POOL_NAME =~ ^[0-9A-Za-z_]+$ ]]; then
  echo  "ERROR: --pool must be alphanumberic, including underscores, no spaces"
  print_help
  exit
fi
if ! [[ $PG_NUM =~ ^[2-9]+$ ]]; then
  echo  "ERROR: --pg_num must be a positive integer greater than 2"
  print_help
  exit
fi
  
}

function check_input_args_for_rados_bench() {
  #At this point the first arg has been stripped off of the parameter list.
  for arg in "$@"
  do
  	KEY=`echo $arg | awk -F "=" '{print $1}'`
    VALUE=`echo $arg | awk -F "=" '{print $2}'`

  	#Check if there is a flag that shouldnt be there
    if [[ $KEY != "--time" && $KEY != "--mode" && $KEY != "--ops" && $KEY != "--pool" && $KEY != "--replication_size" && $KEY != "--pg_num" ]]; then
      echo "ERROR: $arg is not a valid parameter"
      print_help
      exit
    fi
    
    if [[ $KEY == "--time" ]]; then
      TEST_TIME_IN_SEC=$VALUE
    elif [[ $KEY == "--mode" ]]
      MODE=$VALUE
    elif [[ $KEY == "--ops" ]]
      OPS=$VALUE
    elif [[ $KEY == "--pool" ]]
      POOL_NAME=$VALUE
    elif [[ $KEY == "--replication_size" ]]
      REPLICATION_SIZE=$VALUE
    elif [[ $key == "--pg_num" ]]
      PG_NUM=$VALUE
    fi
  done

  if ! [[ $REPLICATION_SIZE =~ ^[2-9]+$ ]]; then
    echo "ERROR: --replication_size must be a positive integer greater than 2"
    print_help
    exit
  fi
  if ! [[ $POOL_NAME =~ ^[0-9A-Za-z_]+$ ]]; then
    echo  "ERROR: --pool must be alphanumberic, including underscores, no spaces"
    print_help
    exit
  fi
  if ! [[ $PG_NUM =~ ^[2-9]+$ ]]; then
    echo  "ERROR: --pg_num must be a positive integer greater than 2"
    print_help
    exit
  fi
  if ! [[ $MODE == "seq" || $MODE == "write" || $MODE == "rand"]]; then
    echo "ERROR: --mode can either be seq, write, or rand"
    print_help
    exit
  fi
  if ! [[ $ops =~ ^[1-9]+$ ]]; then
    echo "ERROR --ops must be a positive integer"
    print_help
    exit
  fi
  if ! [[ $TEST_TIME_IN_SEC =~ ^[1-9]+$ ]]; then
    echo "ERROR: --time must be a positive integer"
    print_help
    exit
  fi
  

}

function check_input_args_for_rbd_benchwrite() {
}





#Handle command line argument input

echo "dollar sign 1: $1"
echo "dollar sign 2: $2"

if [[ $1 == "--help" ]] 
	print_help
elif [[  $1 -ne "--rbd_dd" && $1 -ne "--rados_bench" && $1 -ne "--rbd_benchwrite" &&  $1 -ne "rbd_bonnie" ]]; then
	echo "ERROR: Invalid first option"
        print_help
elif [[ $1 == "--rbd_dd" ]]
	echo "Performing rbd mounts and doing a dd" 
	if [[ $# -eq 6 || $# -eq 8 ]]; then #the correct number of args
	  check_input_args_for_rbd_dd $2 $3 $4 $5 $6 $7 $8 
	else
	  echo "Wrong number of arguments received for rbd_dd"
	  print_help
	  exit
	fi 
	rbd_dd
elif [[ $1 == "--rbd_bonnie" ]]
	echo "Performing rbd mounts and doing a bonnie run upon that rbd mount"
  if [[ $# -eq 5 || $# -eq 7 ]]; then
    check_input_args_for_rbd_bonnie $2 $3 $4 $5 $6 $7
  else
    echo "Wrong number of arguments received for --rbd_bonnie"
    print_help
    exit
  fi 
elif [[ $1 == "-rados_bench" ]]
	echo "Engaging rados bench utility"
  if [[ $# -eq 5 || $# -eq 7 ]]; then
    echo "Performing rados bench operation"
    check_input_args_for_rados_bench $2 $3 $4 $5 $6 $7
  else
    echo "Wrong number of arguments received for --rados_bench"
    print_help
    exit
  fi
	rados_bench
elif [[ $1 == "--rbd_benchwrite" ]]
	echo "Engaging rbd bench-write system"
	rbd_benchwrite
else
	echo "ERROR: input is malformed"
	print_help
fi
