#!/bin/bash
# Metagenomics analysis: S11_q2_to_R_assignment
# Laucher for R script S11_q2_to_R_assignment.R
# This script takes < 1 min to run
# Matthew Spriggs 25Jan2025

# PBS directives that you should review and change if needed
#-----------------------------------------------------------

#PBS -N s11_R_launcher
#PBS -l nodes=1:ncpus=6
#PBS -l walltime=00:30:00
#PBS -q half_hour
#PBS -m abe
#PBS -M matthew.spriggs.452@cranfield.ac.uk

# PBS directives and code that you should not change
#===================================================
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

# Start message
echo "Started launcher shell script"
date
echo ""

# Load required module
module load R/4.2.1-foss-2022a

# Folders
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"
results_folder="${base_folder}/results"
samplesheet="${base_folder}/data/tabsamplesheet.txt"

# tabsamplesheet header has a '#' charecter that is causing
# parse issues into R using read.table().
# remove in place the '#'
sed -i '' '1s/#//' "${samplesheet}"

# Launch R script
Rscript s11_q2_to_R_assignment.R 

# Completion message
echo ""
echo "Completed launcher shell script"
date

# Clean-up
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
