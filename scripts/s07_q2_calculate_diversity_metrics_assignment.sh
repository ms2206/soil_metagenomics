#!/bin/bash
# Matthew Spriggs: 19Jan25

# Crescent2 script
# Note: this script should be run on a compute node
# qsub script.sh

# PBS directives
#---------------

#PBS -N s07_q2_calculate_diversity_metrics_assignment
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
echo "QIIME2: Calculate multiple diversity metrics"
date
echo ""

# Folders
base_folder="/mnt/beegfs/home/s430452/soil_metagenomics"
results_folder="${base_folder}/results"
diversity_metrics_folder="${results_folder}/s07_diversity_metrics"
metadata_folder="${results_folder}/exported_metadata"

# pull min non-chimeric reads from sample-frequency-detail.csv
min_depth=$(awk -F, 'NR >1 {print int($2)}' "${metadata_folder}/sample-frequency-detail.csv" | sort | head -n1)
echo ""
echo "min-depth: ${min_depth}"


# Remove results, if existed
rm -fr "${diversity_metrics_folder}"


# Calculate a whole bunch of diversity metrics
# Select the sampling-depth as the minimal count of non-chimeric reads (see output of step 4)
qiime diversity core-metrics-phylogenetic \
--i-table "${results_folder}/s04_table_dada2.qza" \
--i-phylogeny "${results_folder}/s05_rooted_tree.qza" \
--p-sampling-depth ${min_depth} \
--m-metadata-file "${base_folder}/data/tabsamplesheet.txt" \
--output-dir "${diversity_metrics_folder}"

# Export some results out of QIIME2 format to explore
# (these files can be used for analysis outsede of QIIME2)

# Alpha-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/observed_features_vector.qza" \
  --output-path "${diversity_metrics_folder}/observed_features_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/faith_pd_vector.qza" \
  --output-path "${diversity_metrics_folder}/faith_pd_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/evenness_vector.qza" \
  --output-path "${diversity_metrics_folder}/evenness_vector"

qiime tools export \
  --input-path "${diversity_metrics_folder}/shannon_vector.qza" \
  --output-path "${diversity_metrics_folder}/shannon_vector"

# Beta-diversity metrics
qiime tools export \
  --input-path "${diversity_metrics_folder}/unweighted_unifrac_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/unweighted_unifrac_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/weighted_unifrac_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/weighted_unifrac_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/jaccard_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/jaccard_distance_matrix"

qiime tools export \
  --input-path "${diversity_metrics_folder}/bray_curtis_distance_matrix.qza" \
  --output-path "${diversity_metrics_folder}/bray_curtis_distance_matrix"

# Completion message
echo ""
echo "Done"
date

## Tidy up the log directory
## =========================
rm $PBS_O_WORKDIR/$PBS_JOBID

