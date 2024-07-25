# Description: accept as input a .bed file downloaded from
# the ChIP-Atlas and parse it into a more human readable
# format.  The output is used as input for the file
# "snp_overlap_counter".

# Load necessary libraries
library(data.table)
library(dplyr)
library(stringr)
library(readr)
library(tidyr)

# Read the .bed file
bed_data <- fread("data/input/DNase/DNase.Kidney.100.AllAg.AllCell.bed", header = FALSE, sep = "\t")

# Assign column names based on .bed file format
colnames(bed_data) <- c("chrom", "chromStart", "chromEnd", "name", "score", "strand", "thickStart", "thickEnd", "itemRgb")

# Determine the maximum number of elements in the metadata column "name"
max_splits <- max(sapply(strsplit(bed_data$name, ";"), length))

# Create the new column names dynamically
new_columns <- paste0("metadata", 1:(max_splits+1))

# Separate the column
bed_data_separated <- separate(bed_data, 
                               col = name, 
                               into = new_columns, 
                               sep = ";", 
                               fill = "right")

# Replace %20 with spaces and decode URL-encoded strings
decode_url <- function(x) {
  URLdecode(gsub("%20", " ", x))
}

bed_data_separated <- bed_data_separated %>%
  mutate(across(everything(), decode_url))


# View the result (optional)
print(bed_data_separated)


# Define the path to the output file
output_file_path <- "data/output/DNase/parsed.DNase.Kidney.100.AllAg.AllCell.bed.txt"

# Write the final data frame to a text file
write_tsv(bed_data_separated, output_file_path)

