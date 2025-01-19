# QIIME2 - Rarefaction plot
# Matthew Spriggs: 19Jan25
# Requires environment with QIIME2

# Crescent2 script
# Note: this script should be run on a compute node
# qsub script.sh

# PBS directives
#---------------

#PBS -N s06a_q2_rarefaction_assignment
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
module load QIIME2/2022.8

# Start message
echo "QIIME2: Rarefaction plot"
date
echo ""

# Base folder
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"

# base_folder="..."
results_folder="${base_folder}/results"
metadata_folder="${results_folder}/exported_metadata"

# pull max non-chimeric reads from sample-frequency-detail.csv
max_depth=$(awk -F, 'NR >1 {print int($2)}' "${metadata_folder}/sample-frequency-detail.csv" | sort -r | head -n1)
echo ""
echo "max-depth: ${max_depth}"

# The samplesheet.csv needs to be tab separated
# The header SRA_ID should be #SampleID
tr ',' '\t' < "${base_folder}/data/samplesheet.csv" \
| awk 'NR==1{sub(/SRA_ID/, "#SampleID")}{print}' \
> "${base_folder}/data/tabsamplesheet.txt"

# Alpha rarefaction
# Max-depth based on max non-chimeric reads in s04_stats_dada2.qzv
# Download csv from qiime2view to get exact numeric rarefaction thresholds
qiime diversity alpha-rarefaction \
--i-table "${results_folder}/s04_table_dada2.qza" \
--i-phylogeny "${results_folder}/s05_rooted_tree.qza" \
--p-max-depth ${max_depth} \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--o-visualization "${results_folder}/s06a_alpha_rarefaction.qzv"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID
