#!/bin/bash
# Usage: sbatch slurm-serial-job-script
# Prepared By: Kai Xi,  Oct 2014
#              help@massive.org.au

# NOTE: To activate a SLURM option, remove the whitespace between the '#' and 'SBATCH'

# $1: line counter
# Need to use variables OUTSIDE of this script, #SBATCH doesn't support variables: https://help.rc.ufl.edu/doc/Using_Variables_in_SLURM_Jobs
# SBATCH --job-name=coherence


# To set a project account for credit charging, 
#SBATCH --account=qb48


# Request CPU resource for a serial job
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
# SBATCH --exclusive
#SBATCH --cpus-per-task=8

# Memory usage (MB)
#SBATCH --mem-per-cpu=8000

# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#SBATCH --time=0-10:00:00

# SBATCH --qos=shortq

# To receive an email when job completes or fails
#SBATCH --mail-user=aleu6@student.monash.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL


# Set the file for output (stdout)
# SBATCH --output=classify_coherence.out

# Set the file for error log (stderr)
# SBATCH --error=classify_coherence.err


# Use reserved node to run job when a node reservation is made for you already
# SBATCH --reservation=reservation_name


# Job script
module load matlab/r2018a
echo "${1}"

# Create temporary directory for MATLAB parallelisation files, specific to job
mkdir -p matlab_pct/$SLURM_JOB_ID
echo "matlab_pct/${SLURM_JOB_ID}"

# Run job command
time eval "${1}"

# Remove temporary directory
rm -rf matlab/$SLURM_JOB_ID
echo "temp dir ${SLURM_JOB_ID} deleted"