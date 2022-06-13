
get_installed_pkgs <- function(lib.loc = NULL) {
  df_pkgs <-
    utils::installed.packages(
      lib.loc = lib.loc,
      fields = c("Repository", "RemoteType", "RemoteHost", "RemoteUsername",
                 "RemoteRepo", "RemoteRef", "git_url")
    ) %>%
    dplyr::as_tibble() %>%
    filter(!.data$Package %in% .env$base_pkgs) %>% # remove Base R packages
    dplyr::mutate(
      install_from =
        dplyr::case_when(
          .data$RemoteType %in% "github" ~ "GitHub",
          .data$RemoteType %in% "gitlab" ~ "GitLab",
          grepl(pattern = "bioconductor.org", x = .data$git_url, fixed = TRUE) ~
            "BioConductor",
          !is.na(.data$Repository) ~ .data$Repository,
          TRUE ~ "Unknown"
        ),
      renv_install_pkg_arg =
        dplyr::case_when(
          .data$install_from %in% c("GitHub", "GitLab") ~
            paste0(.data$RemoteType, "::",
                   .data$RemoteUsername, "/",
                   .data$RemoteRepo, "@", RemoteRef),
          .data$install_from %in% "BioConductor" ~ paste0("bioc::", .data$Package),
          !is.na(.data$install_from) ~ .data$Package
        )
    )

  # return df of pkgs that will be installed -----------------------------------
  package_name_width <- df_pkgs$Package %>% nchar() %>% max()
  df_pkgs %>%
    dplyr::select(install_from, package = Package, renv_install_pkg_arg) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      package_name_same_length =
        paste0(.data$package, paste(rep_len(" ", .env$package_name_width - nchar(.data$package)), collapse = "")),
    ) %>%
    dplyr::ungroup()
}

install_pkgs_with_renv_install <- function(df_pkgs_to_install) {
  cli::cli_progress_bar(
    format = "Installing {.pkg {df_pkgs_to_install$package_name_same_length[i]}}| {cli::pb_bar} ETA {cli::pb_eta}",
    total = nrow(df_pkgs_to_install)
  )

  for (i in seq_len(nrow(df_pkgs_to_install))) {
    tryCatch(
      invisible(utils::capture.output(
        renv::install(df_pkgs_to_install$renv_install_pkg_arg[i])
      )),
      error = function(e) {
        cli::cli_alert_danger("{.pkg {df_pkgs_to_install$package[i]}} could not be installed.")
      }
    )
    cli::cli_progress_update()
  }
  cli::cli_progress_done()
}

base_pkgs <- c(
  "base", "compiler", "datasets", "graphics", "grDevices", "grid",
  "methods", "parallel", "splines", "stats", "stats4", "tools", "tcltk",
  "utils"
)
