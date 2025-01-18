#!/bin/bash
# FastQC & MiltiQC
# Matthew Spriggs: 18Jan25
# Requires FastQC and MultiQC in environment

# PBS directives
#---------------

#PBS -N s02_qc_assignment
#PBS -l nodes=1:ncpus=12
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.452@cranfield.ac.uk

#===============
#PBS -j oe
#PBS -v "CUDA_VISIBLE_DEVICES="
#PBS -W sandbox=PRIVATE
#PBS -k n
ln -s $PWD $PBS_O_WORKDIR/$PBS_JOBID
## Change to working directory
cd $PBS_O_WORKDIR
## Calculate number of CPUs and GPUs
export cpus=`cat $PBS_NODEFILE | wc -l`
## Load production modules
module use /apps2/modules/all
## =============

# Stop at runtime errors
set -e

# Load required modules 
module load FastQC/0.11.9-Java-11
module load MultiQC/1.12-foss-2021b

# Base folder 
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics/"

# Start message
echo "FastQC & MultiQC"
date
echo ""

# Folders
data_folder="${base_folder}/data" # should exist and contain fastq files

# Go to data folder
cd "${data_folder}"

# List of fastq files in data folder
fastq_files=$(ls *.fastq)

# Run FastQC for all fastq files
fastqc $fastq_files

# Run MultiQC in the current folder
multiqc .

# Completion message
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
