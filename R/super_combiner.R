# Read in each output results files from "CHiP-atlas", ATAC-seq,
# DNase-seq, H3K4me1, H3K4me3, H3K27ac and transcription
# factor analyses from MotifBreakR (HOCOMOCO only) and
# Fabian Variant web app (TFFM-Jaspar only). Check that
# all files have the same `rsid` and the same number of 
# rows and merge the data frames by `rsid`.  This super
# data frame will be used to generate a binary count file 
# for creating an upset plot for TW RCC CRISPRi/a screening
# project.  This type of file is required input for
# `UpSetR` R package.

# Load necessary libraries
library(dplyr)

# Step 1: List all text files in the directory
directory_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/upset_plots/input_count_files"
text_files <- list.files(path = directory_path, pattern = "\\.txt$", full.names = TRUE)

# Step 2: Read each text file into a data frame and store them in a list
data_frames_list <- lapply(text_files, function(file) {
  read.table(file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)
})

# Step 3: Check that all data frames have the same `rsid` entries and the same number of rows
common_rsid <- data_frames_list[[1]]$rsid

if (!all(sapply(data_frames_list, function(df) all(df$rsid == common_rsid)))) {
  stop("Not all files have the same `rsid` entries.")
}

# Step 4: Merge the data frames by `rsid`
combined_data_frame <- Reduce(function(x, y) merge(x, y, by = "rsid"), data_frames_list)

# Step 5: Select only the necessary columns
selected_columns <- c("rsid", "chrom.x", "hg38.x", "ref.x", "risk.x")
count_columns <- grep("_count$", names(combined_data_frame), value = TRUE)
final_columns <- c(selected_columns, count_columns)

# Subset the data frame to keep only the necessary columns
final_data_frame <- combined_data_frame %>%
  select(all_of(final_columns))

# Step 6: Rename columns to remove '.x' from their names
colnames(final_data_frame) <- gsub("\\.x$", "", colnames(final_data_frame))

# Step 7: Save data frame as an intermediary file.
write_tsv(final_data_frame, "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/upset_plots/output_count_files/super_counts_interm_39_snps.txt")

# Step 8: Convert _count columns to binary (1 if >=1, otherwise 0)
final_data_frame <- final_data_frame %>%
  mutate(across(ends_with("_count"), ~ ifelse(. >= 1, 1, 0)))

# Remove the '_count' suffix from column names
colnames(final_data_frame) <- gsub("_count$", "", colnames(final_data_frame))

# Change "." in column names to "-"
colnames(final_data_frame) <- gsub("\\.", "-", colnames(final_data_frame))

# Rename "hoco" and "tffm" column names
final_data_frame <- final_data_frame %>%
  rename(TF_hoco = hoco, TF_tffm = tffm)


# Step 9: Write final data frame with binary values to text file
# This file will be used to make the upset plot.
write_tsv(final_data_frame, "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/upset_plots/output_count_files/final_binary_counts_39_snps.txt")
