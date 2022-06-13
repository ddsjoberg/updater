#' Re-install Packages from Previous Installation
#'
#' @description
#' Provided the location of the previous R installation's package
#' library, the function will attempt to re-install each of the
#' packages found. Packages are installed with `renv::install()`
#' and will be added to the 'renv' package cache.
#'
#' Packages can be installed from GitHub, GitLab, BioConductor, and
#' any repository listed in `getOption("repos")`. This would typically
#' be from CRAN and any other secondary repositories that may be set.
#'
#' @param lib.loc character vector describing the location of R library
#' trees to search through
#'
#' @return NULL
#' @export
#'
#' @examples
#' if (interactive()) {
#'   install_pkgs()
#' }
install_pkgs <- function(lib.loc = NULL) {
  cli::cli_h1("Importing Package Information")
  # get data frame of all pkgs that will be installed --------------------------
  df_pkgs_to_install <- get_installed_pkgs(lib.loc = lib.loc)

  # print pkgs that will be installed ------------------------------------------
  cli::cli_h1("Installing {.val {nrow(df_pkgs_to_install)}} Packages")

  cli::cli_h2("Packages to be installed")
  df_pkgs_to_install %>%
    dplyr::group_by(.data$install_from) %>%
    dplyr::group_walk(~cli::cli_alert("{.y$install_from}: {.pkg {.x$package}}"))
  cat("\n")

  # print information about install sources ------------------------------------
  repos <- getOption("repos")
  repo_names <-
    unique(df_pkgs_to_install$install_from) %>%
    setdiff(c("BioConductor", "GitHub", "GitLab"))

  if (!rlang::is_empty(repo_names)) {
    cli_repos <-
      ifelse(
        rlang::is_named(repos),
        paste0(
          "{.pkg ", names(repos), "} ",
          "({.url ", repos, "})",
          collapse = ", "
        ),
        paste0(
          "{.url ", repos, "}",
          collapse = ", "
        )
      )
    cli_repo_msg <-
      paste("Packages in repositories {.pkg {repo_names}} will be installed from", cli_repos)
    cli::cli_h2("Packages installed sources")
    cli::cli_alert_info(cli_repo_msg)
    cat("\n")
  }

  # installing packages --------------------------------------------------------
  cli::cli_h2("Installing packages")
  install_pkgs_with_renv_install(df_pkgs_to_install)

  cli::cli_alert_success("Installation Complete!")
  return(invisible())
}
