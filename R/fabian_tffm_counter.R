# Description:  Accepts two text files as input.  The first (1)
# is a list of SNPs of interest. The second (2) is the full
# results from Fabian-Variant (https://www.genecascade.org/fabian/).

library(readr)

# Read the first bed file of 6 SNPs of interest
snp_file <- "data/input/fabian_tffm/six_snps_fabian_format.txt"
snps <- read_delim(snp_file, delim = "\t", col_names = TRUE, comment = "#")

# Or with 39 SNPs
snp_file <- "data/input/fabian_tffm/reformated_fabian_all_39_SNPs.txt"
snps <- read_delim(snp_file, delim = "\t", col_names = TRUE, comment = "#")

# Orr with 32 SNPs
snp_file <- "data/input/fabian_tffm/reformatted_fabian_32_SNPs.txt"
snps <- read_delim(snp_file, delim = "\t", col_names = TRUE, comment = "#")

# Read the second Fabian-varaint results file,
# see Fabian documentation for column descriptions
# fabian_results_file <- "data/input/fabian_tffm/six_snps_fabian_full_results_2024-07-09_1720552854_11091_data.tsv"
# fabian_results_file <- "data/input/fabian_tffm/_38_variants_fabian_web_app_1721760199_46373_data.tsv"
fabian_results_file <- "data/input/fabian_tffm/_32_variants_fabian_web_app_1722521823_07327_data.tsv"
fabian_results <- read_delim(fabian_results_file, 
                             delim = "\t",
                             col_names = TRUE,
                             comment = "#"
                             )

# Function to count matching rows in fabian_results with score >= 0.9
count_matching_rows <- function(fabian_format, fabian_results) {
  variant <- strsplit(fabian_format, "\\.")[[1]][1]
  matching_rows <- fabian_results %>%
    filter(grepl(variant, variant_hg38), abs(score) >= 0.9)
  count <- nrow(matching_rows)
  return(count)
}

# Apply the function to each row in snps
snps$tffm_count <- sapply(snps$fabian_format, count_matching_rows, fabian_results = fabian_results)

# Delete the fabian_format column from snps
snps <- snps %>% select(-fabian_format)

# Print the updated snps data
print(snps)

# Generate file name and path
current_time <- format(Sys.time(), "%Y%m%d_%H%M%S") # used to create unique filenames
output_path <- "data/output/fabian_tffm/"
output_file <- paste0(output_path,
                      "tffm_count_",
                      nrow(snps),
                      "_snps_",
                      current_time,
                      ".txt")

# Write the updated snps data to a new file
write_tsv(snps, output_file)

