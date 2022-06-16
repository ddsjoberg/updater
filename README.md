
<!-- README.md is generated from README.Rmd. Please edit that file -->

# updater

<!-- badges: start -->

[![R-CMD-check](https://github.com/ddsjoberg/updater/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ddsjoberg/updater/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/updater)](https://CRAN.R-project.org/package=updater)
[![Codecov test
coverage](https://codecov.io/gh/ddsjoberg/updater/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ddsjoberg/updater?branch=main)
<!-- badges: end -->

The goal of updater is to ease the R update process. The package will
re-install packages available on your previous version of R into the
system library of your new installation. The package uses {renv} to
install the packages, adding each installation into your {renv} cache.

Importantly, the package *re-installs* the packages and does *not* copy
them from the previous R installation library. R packages for minor R
releases (e.g. R 4.1 to R 4.2) may *not* be compatible, which is why
it’s important to re-install the packages and not copy them.

## Usage

1.  Record location of current R system library

    -   Open your current version of R (before you update), and type
        `.libPaths()` into the console. The current R system library
        locations will print to the console: save these file locations,
        e.g. copy and past the locations into Notepad or TextEdit.
    -   It may be possible to skip this step and find the library
        location by calling `find_previous_library_loc()` from your
        updated R, but it’s recommended to use `.libPaths()` now to
        ensure accuracy.

2.  Install R

    -   Download and install the new version of R from
        <https://cran.r-project.org/>.

3.  Install packages

    -   Open your new version of R and install the {updater} package
        with `install.packages("updater")`.
    -   Run
        `updater::install_pkgs(lib.loc = c("<location(s) saved in Step 1>"))`.
        *As mentioned above, if you didn’t record the location, you may
        try to locate it with `find_previous_library_loc()`.*

    <img src = "https://github.com/ddsjoberg/updater/blob/main/man/figures/install_screenshot.png?raw=true">
