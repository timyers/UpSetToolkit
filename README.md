# UpSetToolkit

<!-- badges: end -->

`UpSetToolkit` is an R project used to create UpSet plots and was created exclusively for an **internal** renal cancer research project, 2023-2024. The R scripts are used to create files as input for the [`UpSetR`](https://github.com/hms-dbmi/UpSetR) R package. The data used for the files was downloaded from the [CHiP-Atlas](https://chip-atlas.org/peak_browser), output from [FABIAN-Variant](https://www.genecascade.org/fabian/) web app, and output from my [`MotifFindR` R project](https://github.com/timyers/MotifFindR/tree/master), that primarily used the R package [`motifbreakR`](https://bioconductor.org/packages/release/bioc/html/motifbreakR.html).

## Installation

- **Install Git:** If you haven't already, download and install Git from [git-scm.com](https://git-scm.com/).
- **Open a Terminal or Command Prompt:** Access your command line interface. On Windows, you can use Command Prompt or PowerShell. On macOS or Linux, open the Terminal.
- **Navigate to the Directory:** Use the `cd` command to navigate to the directory where you want to clone the repository.
- **Clone the Repository:** Use the git clone command followed by the URL of the repository.  See below:

``` 
git clone https://github.com/timyers/UpSetToolkit
```

<br>

## Available Scripts
| Script Name| Description|
|:-------|:-----------|
|`bed_parser.R` |Accept as input a .bed file downloaded from the [ChIP-Atlas](https://chip-atlas.org/peak_browser) and parses it into a more human readable format.  The output is used as input for the script`snp_overlap_counter.R`.|
|`snp_overlap_counter.R` |Counts the overlaps between a list of snps of interest and the **parsed** .bed file downloaded form [ChIP-Atlas](https://chip-atlas.org/peak_browser).|
|`fabian_tffm_counter.R` | Counts the number of predicted effects of DNA variants on transcription factor binding in results output file from the [FABIAN-variant](https://www.genecascade.org/fabian/) web tool (transcription factor flexible models (TFFMs) only).|
|`hoco_pwm_counter.R` | Counts the number of predicted effects of DNA variants on transcription factor binding in results output file from the [`motifbreakR`](https://bioconductor.org/packages/release/bioc/html/motifbreakR.html) `R` package (HOCOMOCO position weigh matrices (pwm) model).|
|`super_combiner.R` |Read in each output result files from the "counter" scripts above, combine them into a super data frame, and generate a binary count file for input in creating an UpSet plot.|
|`upset_ploter` | Use the binary count file created by `super_combiner.R` to generate an UpSet plot.|

<br>

## Utility Scripts
| Utility Name| Description|
|:-------|:-----------|
|`fabian_format_maker.R` |Creates required input format (e.g. chr17:19437135G>A) used by Fabian-variant from multiple types of input.|
|`fabian_format_maker2.R` | Reformatting for script "fabian_tffm_counter.R".|
|`bed_maker.R` |Create a .bed file from a list of rsID's in a text file.|

Additional details about the above scripts can be found in the comments at the beginning of each script.

<br>

## Notes about Usage

1. Download genome-wide BED files from [ChIP-Atlas](https://chip-atlas.org/peak_browser) using the following parameters:
     + H. sapiens (hg38)
     + Select track type class: for this project we were interested in, ATAC-Seq, DNase-seq, and ChIP Histone track types H3K27ac, H3K4me1, H3K4me3.  These are large files.
     + Cell type class "Kidney" with cell type "All" selected.
     + A threshold of significance of 100.
2. Parse each of these downloaded large BED files using script `bed_parser.R`.
3. Count the overlaps in these files by comparing them to a list of SNPs of interest using script `snp_overlap_counter.R`.  The script will save these output files with counts for later use.
4. Use [FABIAN-Variant](https://www.genecascade.org/fabian/) web tool to analyze SNPs of interest to predict the effect of variants on transcription factor binding sites (TFBS). From list of SNPs to analyze, generate required variant input format using the utility script `fabian_format_maker.R`.  This script uses the default format (e.g. chr17:19437135G>A). See list below for parameters selected for this project.  Download and save the results file.
     + Genome build -> GRCh38/hg38
     + Transcription Factors -> All
     + Filter by model -> TFFM detailed and TFFM first-order
     + Filter by source -> JASPAR2022
5. The script `fabian_tffm_counter.R` is then used to set thresholds and count the effect of variants on TFBS.
6. Analyze the list of SNPs of interest using the `R` package `motifbreakR`. My `R` project `MotifFindeR` is written to facilitate this analysis. It includes code with pval threshold set, data source used is HOCOMOCO only.
7. The output from `MotifFindeR` is counted using the script `hoco_pwm_counter`.  Only TFBS designed as having a 'strong' effect are counted.
8. The script `super_combiner.R` will read in all seven count files created by `snp_overlap_counter.R` (5), `fabian_tffm_counter.R` (1) and `hoco_pwm_counter.R` (1) and created a binary count file by replacing counts >=1 to 1. All zero counts remain zero.  This binary count file will serve as input to `upset_ploter.R`.
9. `upset_ploter.R` will generate an UpSet plot from the output of step 8 using the `R` package `UpSetR`.
     



<br>

## Reproducibility

- `UpSetToolkit` uses the `R` package [`renv`](https://rstudio.github.io/renv/index.html) to create a reproducible environment.  It records the exact package versions `UpSetToolkit` depends on in a lockfile, *renv.lock*, and ensures those exact versions get installed.

- After installation, when you open the project `renv` should automatically bootstrap itself, downloading and installing the appropriate version of `renv`.  It should also ask if you want to download and install all the packages `UpSetToolkit` needs by running `renv::restore()`.

  - **NOTE:** The `renv` package tracks but does not help with the version of `R` used (the version of `R` used can be found in the `renv.lock` file).  `renv` can't help with this because it runs inside of `R`.  However, there are other tools that can help.  Tools like [The R Installation Manager or `rig`](https://github.com/r-lib/rig) can help with switching between multiple versions of `R` on one computer.
