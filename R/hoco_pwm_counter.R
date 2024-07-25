# Description:  Accepts two text files as input.  The first (1)
# is a list of SNPs of interest using the text file created to
# use formating required by Fabian-Variant web app.  The filename
# is "reformated_fabian_all_39_SNPs.txt", for all 39 RCC SNPs
# of interest. The first file has the rsid, reference and risk/alleles.
# The second (2) is the output results text file
# file from my 'motifFindR' R project created for our RCC analysis
# that's a wrapper for `motifBreakR` R package.  The second
# filename for all 39 RCC SNPs is:
# "rcc_39-snps_hocomoco_no-ld_granges_object_pval_20240724_081716.csv"
# These two files will be used to count the TFBS from HOCOMOCO
# with a "strong" effect, as determined by `motifBreakR` analysis.

library(readr)
library(dplyr)

##### Input Files #####
# Read the first text file of SNPs of interest,
# with Fabian Variant required formatting
snp_file <- "data/input/fabian_tffm/reformated_fabian_all_39_SNPs.txt"
snps <- read_delim(snp_file, delim = "\t", col_names = TRUE, comment = "#")

# Read the second HOCOMOCO results CSV file,
hoco_results_file <- "data/input/motifbreakr_hoco/rcc_39-snps_hocomoco_no-ld_granges_object_pval_20240724_081716.csv"
hoco_results <- read_csv(hoco_results_file, 
                         col_names = TRUE
                        )

# Rename relevant column names in `hoco_results` to
# match `snps`
# Rename the columns in hoco_results
colnames(hoco_results)[colnames(hoco_results) == "SNP_id"] <- "rsid"
colnames(hoco_results)[colnames(hoco_results) == "start"] <- "hg38"
colnames(hoco_results)[colnames(hoco_results) == "REF"] <- "ref"
colnames(hoco_results)[colnames(hoco_results) == "ALT"] <- "risk"
colnames(hoco_results)[colnames(hoco_results) == "seqnames"] <- "chrom"

# Remove the "chr" prefix from the chrom column in hoco_results
# to match `snps`
hoco_results$chrom <- gsub("chr", "", hoco_results$chrom)

# Convert the chrom column in hoco_results to double
hoco_results$chrom <- as.numeric(hoco_results$chrom)

# For each row in `snps`, count the matching rows in 
# `hoco_results` where 'rsid', 'ref', and 'risk' match,
# and the `effect` column is "strong".
snps <- snps %>%
  rowwise() %>%
  mutate(hoco_count = sum(hoco_results$rsid == rsid & 
                            hoco_results$ref == ref & 
                            hoco_results$risk == risk & 
                            hoco_results$effect == "strong"))

# Delete the fabian_format column from snps
snps <- snps %>% select(-fabian_format)

# Write the updated snps data to a new file
write_tsv(snps, "data/output/motifbreakr_hoco/hoco_count_39_snps.txt")
