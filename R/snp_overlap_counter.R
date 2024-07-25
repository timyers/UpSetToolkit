# Accepts two text files as input.  The first (1) is a
# list of SNPs of interest.  The required format is:

# chr15	66505154	66505154	rs3087660
# chr15	66404397	66404397	rs1549854

# Columns are "chrom", "chromStart", "chromEnd", "rsid"

# The second (2) file is the output from the script
# "bed_parser".

# Load necessary library
library(dplyr)
library(readr)
library(stringr)

############## First Input File ##################
# Input file options, choose one only, same for all analyses
# six_rcc_snps <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/six_SNPs_gr38.bed"
all_39_rcc_snps <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/rcc_snps_39_20240723_075528.bed"


# Load the first bed file of SNPs of interest
snp_file <- all_39_rcc_snps    # choose one from above for crispri/a screening proj.
snps <- read_delim(snp_file, delim = "\t", col_names = c("chrom", "chromStart", "chromEnd", "rsid"), comment = "#")
#################################################


# Second input files (.bed) are different for each analyses
# They were downloaded from the CHiP-atlas and parsed
# with Rscript 'bed_parser'. Use only one at a time.

################### DNase #######################
# Load the second bed file, ** DNAase ** , parsed from chip-atlas
coordinates_file <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/dnase_chip-atlas/parsed.DNase.Kidney.100.AllAg.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# ATAC-seq ######################
# Load the second bed file, ** ATAC-seq ** , parsed from chip-atlas
coordinates_file <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/atac_chip-atlas/parsed_Atac.Kidney.100.AllAg.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K4me1 #######################
# Load the second bed file, ** H3K4me1 ** , parsed from chip-atlas
coordinates_file <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K4me1/parsed_Histone.Kidney.100.H3K4me1.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K4me3 #######################
# Load the second bed file, ** H3K4me3 ** , parsed from chip-atlas
coordinates_file <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K4me3/parsed_Histone.Kidney.100.H3K4me3.AllCell.bed.txt"
coordinates <- read_delim(coordinates_file, delim = "\t")
#################################################

################# H3K27ac #######################
# Load the second bed file, ** H3K27ac ** , parsed from chip-atlas
coordinates_file <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K27ac/parsed_Histone.Kidney.100.H3K27ac.AllCell.bed.txt"
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

# DNase output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/dnase_chip-atlas/overlap_counts_output/"
# ATAC output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/atac_chip-atlas/overlap_counts_output/"
# H3K4me1 output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K4me1/count_overlaps_output/"
# H3K4me3 output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K4me3/counts_overlap_output/"
# H3K27ac output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/histone_chip-atlas/H3K27ac/count_overlaps_output/"

# output_file <- paste0(output_path, new_col_name, "_six_SNPs.bed.txt")
output_file <- paste0(output_path, new_col_name, "_all_39_SNPs_", current_time, ".bed.txt")

write_delim(snps, output_file, delim = "\t", col_names = TRUE)

cat("Updated file with overlap counts has been saved to:", output_file, "\n")
