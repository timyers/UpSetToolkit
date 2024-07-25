# Description: create a .bed file from a list of rsID's
# in a text file. The required output format is:

# chr15	66505154	66505154	rs3087660
# chr15	66404397	66404397	rs1549854

# Columns are "chrom", "chromStart", "chromEnd", "rsid"
# Genome build is GRCh38.p14

install.packages("biomaRt")

# Read in the list of SNP IDs from the text file
rsid_filename <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/TW_39-SNPs-List.txt"
snp_ids <- readLines(rsid_filename)

### Use `biomaRt` to get the chrom and position info, GRCh38.p14
# Connect to Ensembl database
snp_mart <- useMart("ENSEMBL_MART_SNP", dataset = "hsapiens_snp")

# Get SNP information
snp_info <- getBM(attributes = c("refsnp_id", "chr_name", "chrom_start", "chrom_end"),
                  filters = "snp_filter",
                  values = snp_ids,
                  mart = snp_mart)

# Filter out SNPs not found or with invalid chromosome names
snp_info <- snp_info[grepl("^\\d+$", snp_info$chr_name), ]

### Format the data
# format the retrieved data to match the BED file structure
bed_data <- data.frame(
  chrom = paste0("chr", snp_info$chr_name),
  chromStart = snp_info$chrom_start,
  chromEnd = snp_info$chrom_end,
  rsid = snp_info$refsnp_id
)

### Sort 'bed_data' by chrom number and start position
# Convert chromosome to numeric for sorting
# bed_data$chr_num <- as.numeric(gsub("chr", "", bed_data$chr))

# Sort the data by chromosome number and start position
# bed_data <- bed_data[order(bed_data$chr_num, bed_data$start), ]

# Remove the temporary column
# bed_data$chr_num <- NULL

### Write the 'bed_data' to the file, add comment line with genome build
# Get current date and time to use for unique filename
current_time <- format(Sys.time(), "%Y%m%d_%H%M%S")

# Create length of "snp_list" to use in "file_name" below
snp_list_length <- nrow(bed_data)

# Create a unique file name using the current date and time
file_name_path <- "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/chip-atlas/"
file_name <- paste0(file_name_path, "rcc_snps_",
                    snp_list_length, "_", current_time, ".bed")

# Write the comment line and data to the file
writeLines("# GRCh38.p14", con = file_name)
write.table(bed_data, file = file_name, 
            sep = "\t", quote = FALSE, 
            col.names = FALSE, row.names = FALSE,
            append = TRUE)
