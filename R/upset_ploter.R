# https://dethwench.com/making-upset-plots-in-r-with-upsetr/

library(readr)
library(RColorBrewer)
library(dplyr)

# Option 1, for six priority SNPs
sum_table_chip_file <- "data/input/sum_table_six_SNPs.bed.txt"
sum_table_chip <- as.data.frame(read_delim(sum_table_chip_file, delim = "\t"))

# Option 2, all 39 SNPs
final_sum_file <- "data/output/upset_count_files/output/final_binary_counts_39_snps.txt"
final_sum_table <- as.data.frame(read_delim(final_sum_file, delim = "\t"))

# Option 3, 32 SNPs
final_sum_file <- "data/output/upset_count_files/output/final_binary_counts_32_snps_20240801_150840.txt"
final_sum_table <- as.data.frame(read_delim(final_sum_file, delim = "\t"))

# Decided to remove H3K4me3 from final upset plot (2024-07-31)
final_sum_table <- final_sum_table %>%
  select(-H3K4me3)

#######################################################
# Optional steps:  Combine Histone, TF, and ATAC/DNase#
#######################################################
# Create the new column "ATAC/DNase" by combining
# "ATAC-seq" and "DNase-seq"
final_sum_table <- final_sum_table %>%
  mutate(`ATAC/DNase` = ifelse((`ATAC-Seq` + `DNase-Seq`) >= 1, 1, 0)) %>%
  select(-`ATAC-Seq`, -`DNase-Seq`)


# Create the new column "H3K4me1_K27ac" by combining
# H3K4me1 & H3K27ac
final_sum_table <- final_sum_table %>%
  mutate(H3K4me1_K27ac = ifelse((H3K27ac + H3K4me1) >= 1, 1, 0)) %>%
  select(-H3K27ac, -H3K4me1)

# Create the new column "TFBS" by combining "TF_hoco" & "TF_tffm" 
final_sum_table <- final_sum_table %>%
  mutate(TFBS = ifelse((TF_hoco + TF_tffm) >= 1, 1, 0)) %>%
  select(-TF_hoco, -TF_tffm)
##################################################
# End optional steps                              #
##################################################


##### Define parameters for 'upset' function below #####
# Different text scale options
text_scale_options3 <- c(1.5, 1.25, 1.25, 1.25, 1.5, 1.5) #best

# setting colors
# this can also be done with hexadecimal
main_bar_col <- c("black")
# sets_col - color set dynamically by number of "sets", see below
matrix_col <- c("black")
shade_col <- c("wheat4")

# set ratio between matrix plot and main bar plot
mb_ratio3 <- c(0.67, 0.33) # best

# Count columns that contain binary values for `nset` parameter
# binary_cols <- sapply(sum_table_chip, function(col) all(col %in% c(0, 1)))
binary_cols <- sapply(final_sum_table, function(col) all(col %in% c(0, 1)))
count_binary_cols <- sum(binary_cols)

# Create a vector of colors, one for each set or `count_binary_cols`
sets_colors <- RColorBrewer::brewer.pal(count_binary_cols, "Paired")

# Dynamically set x-axis label with number of SNPs
x_label <- paste0("Number of SNPs (", 
                  nrow(final_sum_table), 
                  ")"
                  )

# pdf(file = "/Users/myersta/Library/CloudStorage/OneDrive-NationalInstitutesofHealth/Winter/plots/upset_plots/final_upset_20240724-142653.pdf",
#     width = 7,
#     height = 5
#     )

UpSetR::upset(final_sum_table,
              # empty.intersections = "on",
              # sets = set_vars,
              nsets = count_binary_cols,
              nintersects = NA, #set to count all intersections
              keep.order = FALSE,
              mb.ratio = mb_ratio3,
              sets.x.label = x_label,
              mainbar.y.label="Number of Intersection SNPs",
              show.numbers = "yes",
              point.size = 2,
              line.size = 1,
              text.scale=text_scale_options3,
              main.bar.color = main_bar_col,
              sets.bar.color = sets_colors,
              order.by = "degree",
              # order.by = c("freq", "degree"),
              matrix.color = matrix_col,
              matrix.dot.alpha = 1,
              # text.scale=c(1.5, 1.5, 1.5, 1.5, 1.5, 1.4),
              shade.color = shade_col
              )

# dev.off()


