# Description: Produce a binary count file for CRISPRi &
# CRISPRa screen to be used as input for the creating
# the UpSet plot.

library(readxl)
library(dplyr)

crispri_achn <- read_xlsx("ANOVA results - CRISPRi - ACHN - 2024-07-08.xlsx")
crispri_hek293t <- read_xlsx("ANOVA results - CRISPRi - HEK293T - 2024-07-08.xlsx")
crispra_achn <- read_xlsx("ANOVA results - CRISPRa - ACHN - 2024-07-08.xlsx")
crispra_hek293t <- read_xlsx("ANOVA results - CRISPRa - HEK293T - 2024-07-08.xlsx")

crispri_achn
sigi <- function(df_name) {
  # Convert the df_name to a symbol and evaluate it to get the actual data frame
  df <- get(df_name)
  
  # Perform filtering operations
  df_filtered <- df %>%
    filter(pvalues <= 0.05) %>%
    filter(coefficients < -0.25)
  
  # Create the new name with "sig" appended
  new_name <- paste0(df_name, "sig")
  
  # Assign the filtered data frame to the global environment with the new name
  assign(new_name, df_filtered, envir = .GlobalEnv)
}
siga <- function(df_name) {
  # Convert the df_name to a symbol and evaluate it to get the actual data frame
  df <- get(df_name)
  
  # Perform filtering operations
  df_filtered <- df %>%
    filter(pvalues <= 0.05) %>%
    filter(coefficients >= 0.25)
  
  # Create the new name with "sig" appended
  new_name <- paste0(df_name, "sig")
  
  # Assign the filtered data frame to the global environment with the new name
  assign(new_name, df_filtered, envir = .GlobalEnv)
}

sigi("crispri_achn")
sigi("crispri_hek293t")

siga("crispra_achn")
siga("crispra_hek293t")

snp_list <- read_xlsx("SNP list.xlsx", col_names = FALSE) #Reads in a list of the 32 SNPs
snp_list <- rep(snp_list$...1, each = 3) #Repeats each SNP three times because there are 3 gRNAs per SNP

well_position <- paste0(rep(LETTERS[1:8], each = 12), 1:12) #Makes a character vector of all well positions (A1 - H12)
snp_list <- data.frame(snp_list, well_position) #Makes a df with each well position alongside its corresponding SNP (each SNP has 3 well positions)
names(snp_list) <- c("rsid", "grna")  #Names the second column (well position) 'gRNA'



addrsid <- function(df){
  df$grna <- sub(".*_vs_", "", df$comparison)
  df <- left_join(df, snp_list, by = "grna")
  return(df)
}

crispri_achnsig <- addrsid(crispri_achnsig)
crispri_hek293tsig <- addrsid(crispri_hek293tsig)
crispra_achnsig <- addrsid(crispra_achnsig)
crispra_hek293tsig <- addrsid(crispra_hek293tsig)

combined_df <- rbind(crispri_achnsig, crispri_hek293tsig, crispra_achnsig, crispra_hek293tsig)
snps39 <- read_xlsx("SNP list.xlsx", col_names = FALSE) #Reads in a list of the 32 SNPs
names(snps39) <- "rsid"

snps39$crispr <- ifelse(snps39$rsid %in% combined_df$rsid, 1, 0)
write.csv(snps39, "binary CRISPRa CRISPRi file for 32 variants.csv")


