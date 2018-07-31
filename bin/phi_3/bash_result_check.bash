#!/bin/bash
nChannels=4
flies=13 # 13
conditions=(1 2)
set_ids=($(seq 1 1 1365)) #(1036)
taus=(4) #(1 2 3 4 8 12 16 24 32 48 64 128 256 512 4500 9000) #(4 8 16)
trials=8
global_tpm=0
tau_bin=0
start_samples=1

prefix="split2250_bipolarRerefType1_lineNoiseRemoved_postPuffpreStim_nChannels${nChannels}_globalTPM${global_tpm}_"
suffix=".mat"

if [ $global_tpm -eq 0 ]; then
	tau_string="tau"
else
	tau_string="tauBin"
fi

> array_commands
for (( fly=1; fly<=$flies; fly++ )); do
	printf -v fly_padded "%02d" $fly
	for condition in "${conditions[@]}"; do
		for set in "${set_ids[@]}"; do
			printf -v set_padded "%04d" $set
			for tau in "${taus[@]}"; do
				for (( trial=1; trial<=$trials; trial++ )); do
					#for (( start_sample=1; start_sample<=$tau; start_sample++ )); do
					for (( start_sample=1; start_sample<=start_samples; start_sample++ )); do
						sample_offset=$((${start_sample}-1))
						
						id="f${fly_padded}c${condition}${tau_string}${tau}tauOffset${sample_offset}s${set_padded}t${trial}"
						
						results_file="results_split/${prefix}${id}${suffix}"
						
						# Check if results file exists, if not, output command to recompute
						if [ ! -e $results_file ]; then
							echo "${results_file}"
							echo "python3 phi_compute.py $nChannels $fly $condition $set $tau $trial $global_tpm $tau_bin $start_sample" >> array_commands
						fi
						
					done
				done
			done
		done
	done
done