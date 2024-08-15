# Description: accept as input the text file created
# by bed_parser.R script and subset rows by chromosome
# number and columns, "chrom, chromStart, chromEnd,
# score". Save the file to .bed file.  This file will
# used as input in my R project `winterPlots` to plot
# signal tracks.


library(data.table)
library(readr)

# Define the function
subset_bed_by_chrom <- function(file_path, chromosome) {
  
  # Read the .bed file
  df <- fread(file_path, sep = "\t", header = TRUE)
  
  # Ensure chromosome input is in correct format (e.g., "chr15")
  chrom_label <- paste0("chr", chromosome)
  
  # Filter rows where the chromosome matches the input
  df_filtered <- df[df$chrom == chrom_label]
  
  # Select specific columns
  df_subset <- df_filtered[, .(chrom, chromStart, chromEnd, score)]
  
  # Return the subsetted DataFrame
  return(df_subset)
}

# Example usage of the function
# result <- subset_bed_by_chrom("path_to_your_file.bed", 15)

########## End function ##########

# Define input parameters
chrom_to_subset <- 15
file_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Rprojects_OneDrive/winter/UpSetTookit/data/output/H3K27ac/"
file_name <- "parsed_Histone.Kidney.100.H3K27ac.AllCell.bed.txt"
my_file <- paste0(file_path, file_name)

# Call subset bed function
df <- subset_bed_by_chrom(my_file, chrom_to_subset)

# Define the path to the output file
output_filepath <- paste0(file_path,
                          "subset_",
                          "chr",
                          chrom_to_subset,
                          "_",
                          file_name)

# Write the final data frame to a text file
readr::write_tsv(df, output_filepath)
