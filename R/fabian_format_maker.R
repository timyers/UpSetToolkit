# Create a file with the 39 SNPs of interest from the RCC
# project.  The required format is one chromosomal annotation
# per line.  e.g.
#   chr17:19437135G>A
# where 'G' is the reference allele and 'A' is the risk or
# effect allele.
# Input is two text files.  The first is a .bed file 
# from previous analyses in the following format:
#    chr14	72801212	72801212	rs11158979
#    chr15	66387263	66387263	rs112542693
#
# The second input file was provided by T. Winter
# and provides the reference and effect/risk alleles.
#     rsid	risk_allele	ref_allele	risk_allele_frequency	beta	standard_error	p_value
#     rs6667088	A	G	0.605472	0.0240945	0.0112607	0.0323795
#     rs6426930	A	G	0.673943	0.0173988	0.0117543	0.138816
#
# Purpose:  combine these to files and add a column with
# required format used by Fabian Variant 
# (https://www.genecascade.org/fabian/#batch)

# Load necessary library
library(dplyr)

# Define column names for the BED file
bed_colnames <- c("chrom", "chromStart", "chromEnd", "rsid")

# Read the BED file
bed_filename <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/rcc_snps_39_20240723_075528.bed"
bed_file <- read.table(bed_filename, header = FALSE, 
                       col.names = bed_colnames, 
                       stringsAsFactors = FALSE)

# Read the sumstats file
sumstats_filename <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/all_39_SNPs_sumstats_risk-alleles.txt"
sumstats_file <- read.table(sumstats_filename, header = TRUE, stringsAsFactors = FALSE)

# Perform the join by rsid
combined_data <- inner_join(bed_file, sumstats_file, by = "rsid")

# Create the new column in the specified format required by
# Fabian Variant web app.
combined_data <- combined_data %>%
  mutate(fabian_format = paste0(chrom, ":", 
                                chromStart, ref_allele, ">", 
                                risk_allele))

# View the first few rows of the combined data
head(combined_data)

# Write the combined data to a new file
# Get current date and time to use for unique filename
current_time <- format(Sys.time(), "%Y%m%d_%H%M%S") # used to create unique filenames

# DNase output path
output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/fabian_tf/required_format/"
output_file <- paste0(output_path, "fabian_format", 
                      "_all_39_SNPs_", current_time, ".txt")

write.table(combined_data, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
