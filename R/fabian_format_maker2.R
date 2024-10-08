# Reformatting 'file1' to match input format required
# as input for script "fabian_tffm_counter"

# Load necessary libraries
library(dplyr)

# Read the first file
# snp_file1 <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/fabian_tf/required_format/fabian_format_all_39_SNPs_20240723_144047.txt"
snp_file1 <- "data/input/fabian_tffm/fabian_format_32_SNPs_20240801_101111.txt"
file1 <- read.table(snp_file1, header = TRUE, sep = "\t")

# Read the second file
# snp_file2 <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/fabian_tf/six_snps_fabian_format.txt"
# snp_file2 <- "data/input/fabian_tffm/six_snps_fabian_format.txt"
# file2 <- read.table(snp_file2, header = TRUE, sep = "\t")

# Adjust the first file to match the columns and order of the second file
file1_reformatted <- file1 %>%
  select(rsid, chrom, chromStart, ref_allele, risk_allele, fabian_format) %>%
  rename(hg38 = chromStart, ref = ref_allele, risk = risk_allele) %>%
  mutate(chrom = as.integer(gsub("chr", "", chrom)))

# Write the reformatted file to a new file
# output_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/fabian_tf/required_format/"
output_path <- "data/input/fabian_tffm/"
output_file <- paste0(output_path, "reformatted_fabian_all_39_SNPs.txt")
output_file <- paste0(output_path,
                      "reformatted_fabian_",
                      nrow(file1_reformatted),
                      "_SNPs.txt")
write.table(file1_reformatted, output_file, sep = "\t", row.names = FALSE, quote = FALSE)
