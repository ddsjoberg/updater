# updater (development version)

* In the release of {renv} v1.0.0 release, `renv::install()` prompts users by default about the installation of each function. This default behavior has now been silenced. (#9)

# updater 0.1.1

* The `install_pkgs()` function can now re-install packages from the R-Universe. (#3)

* Added a condition in `previous_r_version()` that the R version returned must begin with `"R-"`. Previously, an incorrect value could be returned that was _not_ an R version. (#2)

# updater 0.1.0

* First release.
