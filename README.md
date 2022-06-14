
<!-- README.md is generated from README.Rmd. Please edit that file -->

# updater

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/updater)](https://CRAN.R-project.org/package=updater)
<!-- badges: end -->

The goal of updater is to ease the R update process. The package will
re-install packages available on your previous version of R into the
system library of your new installation. The package uses {renv} to
install the packages, adding each installation into your {renv} cache.

Importantly, the package *re-installs* the packages and does *not* copy
them from the previous R installation library. R packages for minor R
releases (e.g. R 4.1 to R 4.2) may *not* be compatible, which is why
it’s important to re-install the packages and not copy them.

## Installation

You can install the development version of updater from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ddsjoberg/updater")
```

## Usage

1.  Record location of current R system library.

    -   Open your current R (before you update), and type `.libPaths()`
        into the console. The current R system library locations will
        print to the console: save these file locations to separate
        file, e.g. copy and past the locations into Notepad or TextEdit.

2.  Install R

    -   Download and install the new version of R from
        <https://cran.r-project.org/>.

3.  For Windows users, install RTools.

    -   Download and install the latest version of RTools (if not
        already installed) from
        <https://cran.r-project.org/bin/windows/Rtools/>.

4.  Install packages.

    -   Open your new version of R and install the {updater} package.
    -   Run
        `updater::install_pkgs(lib.loc = "<location of previous R installation system library saved in step 1>")`
