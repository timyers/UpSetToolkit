# UpSetToolkit

<!-- badges: start -->
<!-- badges: end -->

`UpSetToolkit` is an R project used to create UpSet plots and was created exclusively for an internal renal cancer research project, 2023-2024. The R scripts are used to create files as input for the UpSetR R package. The data used for the files was downloaded from the [CHiP-Atlas](https://chip-atlas.org/peak_browser), output from [Fabian Variant](https://www.genecascade.org/fabian/) web app, and output from my [`MotifFindR` R project](https://github.com/timyers/MotifFindR/tree/master), that primarily used the R package [`motifbreakR`](https://bioconductor.org/packages/release/bioc/html/motifbreakR.html). The R package [`UpSetR`](https://github.com/hms-dbmi/UpSetR) is used to generate
UpSet plots.

## Installation

- **Install Git:** If you haven't already, download and install Git from [git-scm.com](https://git-scm.com/).
- **Open a Terminal or Command Prompt:** Access your command line interface. On Windows, you can use Command Prompt or PowerShell. On macOS or Linux, open the Terminal.
- **Navigate to the Directory:** Use the `cd` command to navigate to the directory where you want to clone the repository.
- **Clone the Repository:** Use the git clone command followed by the URL of the repository.  See below:

``` 
git clone https://github.com/timyers/UpSetToolkit
```
## Reproducibility

- `UpSetToolkit` uses the `R` package [`renv`](https://rstudio.github.io/renv/index.html) to create a reproducible environment.  It records the exact package versions `UpSetToolkit` depends on in a lockfile, *renv.lock*, and ensures those exact versions get installed.

- After installation, when you open the project `renv` should automatically bootstrap itself, downloading and installing the appropriate version of `renv`.  It should also ask if you want to download and install all the packages `UpSetToolkit` needs by running `renv::restore()`.

  - **NOTE:** The `renv` package tracks but does not help with the version of `R` used (the version of `R` used can be found in the `renv.lock` file).  `renv` can't help with this because it runs inside of `R`.  However, there are other tools that can help.  Tools like [The R Installation Manager or `rig`](https://github.com/r-lib/rig) can help with switching between multiple versions of `R` on one computer.
