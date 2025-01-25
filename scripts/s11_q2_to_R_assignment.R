# ---
#   title: "S11_q2_to_R_assignment"
# author: "Matthew Spriggs"
# date: "2025-01-24"
# ---


# This script imports QIIME 2 artifacts and metadata into R, converts them into a 
# phyloseq object, and performs hierarchical clustering and PERMANOVA analysis. 
# To visualize and statistically analyze the relationships between microbial 
# communities in different sample groups.

# Install Packages
# Install CRAN packages if not installed
for (pkg in c("devtools", "BiocManager", "dendextend", "remotes")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg, ask = FALSE)
}

# Install Bioconductor packages if not installed
for (pkg in c("phyloseq", "vegan")) {
  if (!requireNamespace(pkg, quietly = TRUE)) BiocManager::install(pkg, update = FALSE, ask = FALSE)
}

# Install GitHub package if not installed
if (!requireNamespace("qiime2R", quietly = TRUE)) remotes::install_github("jbisanz/qiime2R", quiet = TRUE)


# Packages are quite verbos;
suppressPackageStartupMessages(suppressWarnings(library(qiime2R))) # for importing QIIME2 artifacts
suppressPackageStartupMessages(suppressWarnings(library(phyloseq))) # for handling phyloseq objects
suppressPackageStartupMessages(suppressWarnings(library(vegan))) # for calculating PERMANOVA using ad
suppressPackageStartupMessages(suppressWarnings(library(dendextend))) # for colouring samples dendrogram

# Load current wd
current_dir = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(current_dir)

# set wd one level higher
setwd('..')
root_dir = getwd()

# Set up folders and filepaths
data_folder=paste0(root_dir, '/results')
table_qza=file.path(data_folder,"s06b_rarefied_table.qza")
rooted_tree_qza=file.path(data_folder,"s05_rooted_tree.qza")
taxonomy_qza=file.path(data_folder,"s10_taxonomy.qza")
scripts_folder=paste0(root_dir, '/scripts')
tsv_foler=paste0(root_dir, '/data')
metadata_tsv=file.path(tsv_foler,"tabsamplesheet.txt")

# Remove '#' from first columns - causing parsing errors with qza_to_phyloseq obj.
lines <- readLines(metadata_tsv)
lines[1] <- sub("^#", "", lines[1])
writeLines(lines, metadata_tsv)

# Import to phyloseq data type using qiime2R package. Then data could be further
# extracted from the phyloseq object, if necessary.

# Convert QIIME2 artifacts & metadata to phyloseq
phy <- qza_to_phyloseq(table_qza, rooted_tree_qza, taxonomy_qza, metadata_tsv)

# Extract metadata and distance matrix from phyloseq object
metadata <- data.frame(sample_data(phy))
distance_matrix <- distance(phy, method="bray")

bray_clust <- hclust(distance_matrix, method="ward.D2")
bray_dend <- as.dendrogram(bray_clust, hang=0.1)

group_names <- unique(metadata$Group)
group_colors <- setNames(c("red", "blue"), group_names) 
colour_labels <- group_colors[as.factor(metadata$Group)]
labels_colors(bray_dend) <- colour_labels

png(filename = paste0(data_folder, '/sample_dendrogram.png'), width = 800, height = 600)

plot(bray_dend, main="Samples dendrogram", ylab="Distances")

legend("topright", legend = group_names, 
       fill = group_colors, title = "Groups")

dev.off()

# Run PERMANOVA
adonis2(distance_matrix ~ Group, data = metadata, permutations=100000)

# Session info
sessionInfo()
