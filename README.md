# UpSetToolkit

<!-- badges: start -->
<!-- badges: end -->

`UpSetToolkit` is an R project used to create UpSet plots and was created exclusively for an internal renal cancer research project, 2023-2024. The R scripts are used to create files as input for the [`UpSetR`](https://github.com/hms-dbmi/UpSetR) R package. The data used for the files was downloaded from the [CHiP-Atlas](https://chip-atlas.org/peak_browser), output from [Fabian Variant](https://www.genecascade.org/fabian/) web app, and output from my [`MotifFindR` R project](https://github.com/timyers/MotifFindR/tree/master), that primarily used the R package [`motifbreakR`](https://bioconductor.org/packages/release/bioc/html/motifbreakR.html).

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

<br>

Additional details about the above scripts can be found in the comments at the beginning of each script.

## Reproducibility

- `UpSetToolkit` uses the `R` package [`renv`](https://rstudio.github.io/renv/index.html) to create a reproducible environment.  It records the exact package versions `UpSetToolkit` depends on in a lockfile, *renv.lock*, and ensures those exact versions get installed.

- After installation, when you open the project `renv` should automatically bootstrap itself, downloading and installing the appropriate version of `renv`.  It should also ask if you want to download and install all the packages `UpSetToolkit` needs by running `renv::restore()`.

  - **NOTE:** The `renv` package tracks but does not help with the version of `R` used (the version of `R` used can be found in the `renv.lock` file).  `renv` can't help with this because it runs inside of `R`.  However, there are other tools that can help.  Tools like [The R Installation Manager or `rig`](https://github.com/r-lib/rig) can help with switching between multiple versions of `R` on one computer.
