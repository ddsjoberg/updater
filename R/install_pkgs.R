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
  cli::cli_alert_info("Found {.val {nrow(df_pkgs_to_install)}} packages")

  print_repos_and_pkgs(df_pkgs_to_install)

  # print pkgs that will be installed ------------------------------------------
  cli::cli_h1("Installing Packages")

  # print information about install sources ------------------------------------
  print_install_sources(df_pkgs_to_install)

  # installing packages --------------------------------------------------------
  install_pkgs_with_renv_install(df_pkgs_to_install)

  cli::cli_alert_success("Installation Complete!")
  return(invisible())
}


print_repos_and_pkgs <- function(df_pkgs_to_install) {
  walk(
    unique(df_pkgs_to_install$install_from),
    function(x) cli::cli_alert("{x}: {.pkg {df_pkgs_to_install[df_pkgs_to_install$install_from %in% x, 'package', drop = TRUE]}}")
  )
  return(invisible())
}


print_install_sources <- function(df_pkgs_to_install) {
  repos <- getOption("repos")
  repo_names <-
    setdiff(
      unique(df_pkgs_to_install$install_from),
      c("BioConductor", "GitHub", "GitLab")
    )
  repo_names <- repo_names[!endsWith(repo_names, ".r-universe.dev")]

  if (is_named(repos)) {
    cli_repos <-
      ifelse(
        is_named(repos),
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
    cli::cli_alert_info(cli_repo_msg)
  }
  else {
    cli::cli_alert_info("Packages in repositories {.pkg {repo_names}} will be installed from {.url {repos}}")
  }
  cat("\n")
  return(invisible())
}

