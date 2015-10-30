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
#This script is intended to stess test a ceph cluster

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
        echo "--rbd_dd options:"
        echo "--num_block_devices=integer [required]"
        echo "--block_device_size=integer size in MB [required]"
        echo "--block_size=integer block size to use for write [required]"
        echo "--time=integer Time to sustain test. In progress write operations will continue, none  [required]"
        echo "--pool=string pool name to use, will create if non-existent but will not remove pool [required]"
        echo "--replication_size number of replicas to make [required for non-existent pools, ignored for existing pools]"
	echo "----------------------------------------------"
	echo "--rbd_bonnie options:"
	echo "--rbd_bonnie expects"
}

function does_pool_exist() {

}

function set_pg_num() {
  POOL=$1
  PGS=$2
  #verify numnber of PGS 
}

function create_pool() {  
  rados mkpool $1
}

function rbd_dd() {
 NUM_BLOCK_DEVICE=$1
 SIZE_BLOCK_DEVICE=$2
 BLOCK_SIZE_IN_MB=$3
 TEST_TIME_IN_SEC=$4
 POOL_NAME=$5
 REPLICATION_SIZE=$6
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
 for arg in "$@"
 do
	KEY=`echo $arg | awk -F "=" '{print $1}'`
        VALUE=`echo $arg | awk -F "=" '{print $2}'`
	#Check if there is a flag that shouldnt be there
	if [[ $KEY != "--num_block_devices" && $KEY != "--block_device_size" && $KEY != "--block_size" && $KEY != "--time" && $KEY != "-pool" && $KEY != "--replication_size" ]]; then
		echo "$arg is not a valid parameter"
		print_help
		exit
	fi 
	
 done

 NUM_BLOCK_DEVICE=$1
 SIZE_BLOCK_DEVICE=$2
 BLOCK_SIZE_IN_MB=$3
 TEST_TIME_IN_SEC=$4
 POOL_NAME=$5
 REPLICATION_SIZE=$6	
}


function check_input_args_for_rbd_bonnie() {
}

function check_input_args_for_rados_bench() {
}

function check_input_args_for_rbd_benchwrite() {
}





#Handle command line argument input

echo "dollar sign 1: $1"
echo "dollar sign 2: $2"

if [[ $1 == "--help" ]] 
	print_help
elif [[  $1 -ne "--rbd_dd" && $1 -ne "--rados_bench" && $1 -ne "--rbd_benchwrite" &&  $1 -ne "rbn_bonnie"]]; then
	echo "Invalid first option - printing help:"
        print_help
elif [[ $1 == "--rbd_dd" ]]
	echo "Performing rbd mounts and doing a dd" 
	if [[ $# -eq 5 || $# -eq 6 ]]; then #the correct number of args
	  check_input_args_for_rbd_dd $2 $3 $4 $5 $6 $7 
	else
	  echo "Wrong number of arguments received for rbd_dd"
	  print_help
	  exit
	fi 
	rbd_dd
elif [[ $1 == "-rados_bench" ]]
	echo "Engaging rados bench utility"
	rados_bench()
elif [[ $1 == "--rbd_benchwrite" ]]
	echo "Engaging rbd bench-write system"
	rbd_benchwrite()
else
	echo "ERROR: input is malformed"
	print_help
fi