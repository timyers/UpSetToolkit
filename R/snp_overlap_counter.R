# Accepts two text files as input.  The first (1) is a
# list of SNPs of interest.  The required format is:

# chr15	66505154	66505154	rs3087660
# chr15	66404397	66404397	rs1549854

# Columns are "chrom", "chromStart", "chromEnd", "rsid"
# This file can be created from a list of rsIds using
# the script `bed.maker`

# The second (2) file is the output from the script
# "bed_parser".

# Load necessary library
library(dplyr)
library(readr)
library(stringr)

############## First Input File ##################
# Input file options, **choose one only**, same for all analyses
six_rcc_snps <- "data/input/snps_of_interest/rcc_snps_six_gr38.bed"
all_39_rcc_snps <- "data/input/snps_of_interest/rcc_snps_39_20240723_075528.bed"
subset_32_rcc_snps <- "data/input/snps_of_interest/rcc_snps_32_20240801_085645.bed"

# Load the first bed file of SNPs of interest
snp_file <- six_rcc_snps
snp_file <- all_39_rcc_snps    # choose one from above for crispri/a screening proj.
snp_file <- subset_32_rcc_snps
snps <- read_delim(snp_file, delim = "\t", col_names = c("chrom", "chromStart", "chromEnd", "rsid"), comment = "#")
#################################################


# Second input files (.bed) are different for each analyses
# They were downloaded from the CHiP-atlas and parsed
# with Rscript 'bed_parser'. Use only one at a time.

################### DNase #######################
# Load the second bed file, ** DNAase ** , parsed from chip-atlas
coordinates_file <- "data/output/DNase/parsed.DNase.Kidney.100.AllAg.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# ATAC-seq ######################
# Load the second bed file, ** ATAC-seq ** , parsed from chip-atlas
coordinates_file <- "data/output/ATAC/parsed_Atac.Kidney.100.AllAg.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K4me1 #######################
# Load the second bed file, ** H3K4me1 ** , parsed from chip-atlas
coordinates_file <- "data/output/H3K4me1/parsed_Histone.Kidney.100.H3K4me1.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K4me3 #######################
# Load the second bed file, ** H3K4me3 ** , parsed from chip-atlas
coordinates_file <- "data/output/H3K4me3/parsed_Histone.Kidney.100.H3K4me3.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K27ac #######################
# Load the second bed file, ** H3K27ac ** , parsed from chip-atlas
coordinates_file <- "data/output/H3K27ac/parsed_Histone.Kidney.100.H3K27ac.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

# Extract the new column name from the second bed file
new_col_name <- str_extract(coordinates$metadata2[1], "(?<=Name=)[^ ]+")
new_col_name_count <- paste0(new_col_name, "_count")

# Ensure that chromosome names are consistently formatted
format_chrom <- function(chrom) {
  if (!startsWith(chrom, "chr")) {
    chrom <- paste0("chr", chrom)
  }
  return(chrom)
}

snps$chrom <- sapply(snps$chrom, format_chrom)
coordinates$chrom <- sapply(coordinates$chrom, format_chrom)

# Function to count overlaps
count_overlaps <- function(snp_row, coordinates) {
  chrom <- snp_row$chrom
  start <- as.numeric(snp_row$chromStart)
  end <- as.numeric(snp_row$chromEnd)
  
  overlaps <- coordinates %>%
    filter(chrom == !!chrom & chromStart <= !!end & chromEnd >= !!start)
  
  return(nrow(overlaps))
}

# Apply the count_overlaps function to each SNP
snps[[new_col_name_count]] <- apply(snps, 1, function(row) count_overlaps(as.data.frame(t(row)), coordinates))

# Apply the count_overlaps function to each SNP
# snps$overlap_count <- apply(snps, 1, function(row) count_overlaps(as.data.frame(t(row)), coordinates))

# Save the updated SNP file with the new column
# Get current date and time to use for unique filename
current_time <- format(Sys.time(), "%Y%m%d_%H%M%S") # used to create unique filenames
num_snps <- nrow(snps)

# DNase output path
output_path <- "data/output/DNase/counts/"
# ATAC output path
output_path <- "data/output/ATAC/counts/"
# H3K4me1 output path
output_path <- "data/output/H3K4me1/counts/"
# H3K4me3 output path
output_path <- "data/output/H3K4me3/counts/"
# H3K27ac output path
output_path <- "data/output/H3K27ac/counts/"

# output_file <- paste0(output_path, new_col_name, "_six_SNPs.bed.txt")
# output_file <- paste0(output_path, new_col_name, "_all_39_SNPs_", current_time, ".bed.txt")
output_file <- paste0(output_path,
                     new_col_name,
                     "_",
                     num_snps,
                     "_SNPs_",
                     current_time,
                     ".bed.txt")

write_delim(snps, output_file, delim = "\t", col_names = TRUE)

cat("Updated file with overlap counts has been saved to:", output_file, "\n")
