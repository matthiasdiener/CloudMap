#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

# Directory where this script resides in
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

####################
###### Configuration
####################

HOSTFILE=$DIR/hostnames.txt   # File that contains hostnames, 1 host per line
MSG_SIZE="M1K"                # 1 KByte messages by default
METRIC="l"                    # Latency (l) or Bandwidth (b)

########################
###### End configuration
########################

if [ $# -ne 2 ]; then
 echo "Usage: $0 <binary> <num_ranks>"
 echo ""
 exit 1
fi

mkdir -p matrix

exe="$1"
num_ranks="$2"

num_nodes=$(sed -n '/[^[:space:]]/p' $HOSTFILE | wc -l)
benchname=$(basename $exe)

# location of application' communication matrix (obtained offline using EZTrace, for example)
commcsv=$exe.csv

if [ ! -f $commcsv ]; then
	echo "Cannot open $commcsv, exiting"
	exit 2
fi


# Compute communication performance using the number of nodes and the metric to evaluate, latency or bandwidth (default: latency)
$DIR/gen-arch-csv.sh $HOSTFILE $MSG_SIZE $METRIC


# Generate network matrix using the measured communication performance
$DIR/arch-mat.R $num_nodes comm.csv arch-$benchname-$num_ranks.csv


# Calculate the task mapping using the Scotch library on the communication matrix/network matrix and create a rankfile for OpenMPI
$DIR/calcmap.sh $commcsv arch-$benchname-$num_ranks.csv


# Execute the application using the mapping stored in rankfile.txt
# This command assumes openmpi
mpirun --rankfile rankfile.txt --hostfile $HOSTFILE -n $num_ranks $exe
