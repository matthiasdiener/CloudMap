#!/bin/bash

set -o errexit -o nounset -o pipefail -o posix

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p comm
rm -f comm/*

mpibench="$DIR/mpibench/mpi_bench"

(cd $DIR/mpibench && make -s)

if [ $# -ne 3 ] ; then
	echo "Usage: $0 ./gen-arch-csv.sh <hostfile> <metric> <message_size>"
	exit 1
fi

hostfile="$1"
metric="$2"
size="$3"

num_nodes=$(sed -n '/[^[:space:]]/p' $hostfile | wc -l)

readarray -t nodes < $hostfile

for from in $(seq 0 $((num_nodes-1)) ); do

	for to in $(seq $from $((num_nodes-1)) ); do
		if [ $from -eq $to ]; then continue; fi
		echo "$from,$to"
		from_node=${nodes[from]}
		to_node=${nodes[to]}

		if [ $from -eq $((num_nodes-2)) -a $to -eq $((num_nodes-1)) ]; then
			mpirun -bynode -host $from_node,$to_node $mpibench -i 1000 -$metric -$size | cut -f 2 -d ' ' | xargs echo -e $from-$to\t > comm/$from-$to.csv
		else
			mpirun -bynode -host $from_node,$to_node $mpibench -i 1000 -$metric -$size | cut -f 2 -d ' ' | xargs echo -e $from-$to\t > comm/$from-$to.csv &
			sleep 0.05
		fi
	done
done

cat comm/*.csv > comm.csv
