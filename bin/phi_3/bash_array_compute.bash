#!/bin/bash

line_increment=500 # size of job array

# Find total number of parameter lines (total number of jobs to be submitted across all arrays)
lines=$(wc -l < array_commands) # Total number of jobs which need to be computed

# Loop through parameter lines
for (( line=1; line<=$lines; line=$line+$line_increment )); do
	squeue -u aleung > job_list
	jobs=$(wc -l < job_list)
	echo "there are $jobs jobs"
	while [ $jobs -ge 2 ]; do
		echo "too many jobs, sleeping"
		sleep 60s
		squeue -u aleung > job_list
		jobs=$(wc -l < job_list)
		echo "slept, now there are $jobs jobs"
	done
	
	echo "array submitting (from line $line)"
	sbatch --job-name="phi3_array" --output="logs/array_%A_%a.out" --error="logs/array_%A_%a.err" --array=1-$line_increment bash_array_sbatch.bash $line
	echo "submitted, now sleeping for a little"
	sleep 60s
done
