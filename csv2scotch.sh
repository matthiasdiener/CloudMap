#!/bin/bash

set -o errexit -o nounset -o pipefail
diagonal=0 # if 0, clear diagonal of matrix

if [ $# -ne 1 ]; then
	echo "Usage: $0 <csv>"
	exit 1
fi

fin=$1
fout="$fin.grf"

readarray a < $fin

nthreads=${#a[@]}

i=$((nthreads-1))
j=0

for l in "${a[@]}"; do
	j=0
	IFS=, read -a line < <(echo $l)
	for f in "${!line[@]}"; do
		comb=values_${i}_${j}
		eval "$comb=${line[f]}"
		j=$((j+1))
    done
	i=$((i-1))
done


if [ $diagonal -eq 0 ]; then
	for i in $(seq 0 $((nthreads-1))); do
		comb=values_${i}_${i}
		eval "$comb=0"
	done
fi

echo "0" > $fout
echo "$nthreads $((nthreads*(nthreads-1)))" >> $fout
echo "0 010" >> $fout

for i in $(seq 0 $((nthreads-1))); do
	echo -n $((nthreads-1)) >> $fout
	for j in $(seq 0 $((nthreads-1))); do
		if [ $j -ne $i ]; then
			comb=values_${i}_${j}
			echo -n " ${!comb}  $j" >> $fout
		fi
	done
	echo >> $fout
done

# echo "$fin: $nthreads threads/cores; output: $fout"

exit 0
