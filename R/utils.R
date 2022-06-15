
get_installed_pkgs <- function(lib.loc = NULL) {
  df_pkgs <-
    as.data.frame(
      utils::installed.packages(
        lib.loc = lib.loc,
        fields = c("Repository", "RemoteType", "RemoteHost", "RemoteUsername",
                   "RemoteRepo", "RemoteRef", "git_url")
      )
    )

  df_pkgs <- df_pkgs[!df_pkgs$Package %in% base_pkgs, ]
  df_pkgs$install_from <-
    ifelse(
      df_pkgs$RemoteType %in% "github", "GitHub",
      ifelse(
        df_pkgs$RemoteType %in% "gitlab", "GitLab",
        ifelse(
          grepl(pattern = "bioconductor.org", x = df_pkgs$git_url, fixed = TRUE), "BioConductor",
          ifelse(
            !is.na(df_pkgs$Repository), df_pkgs$Repository, "Unknown"
          )
        )
      )
    )

  df_pkgs$renv_install_pkg_arg <-
    ifelse(
      df_pkgs$install_from %in% c("GitHub", "GitLab"),
      paste0(df_pkgs$RemoteType, "::",
             df_pkgs$RemoteUsername, "/",
             df_pkgs$RemoteRepo, "@", df_pkgs$RemoteRef),
      ifelse(
        df_pkgs$install_from %in% "BioConductor", paste0("bioc::", df_pkgs$Package),
        df_pkgs$Package
      )
    )

  # return df of pkgs that will be installed -----------------------------------
  package_name_width <- max(nchar(as.character(df_pkgs$Package)))
  df_return <-
    stats::setNames(
      df_pkgs[c("install_from", "Package" , "renv_install_pkg_arg")],
      c("install_from", "package" , "renv_install_pkg_arg")
    )

  df_return$package_name_same_length <-
    unlist(
      lapply(
        df_return$package,
        function(x) {
          paste0(x, paste(rep_len(" ", package_name_width - nchar(x)), collapse = ""))
        }
      )
    )

  df_return
}

install_pkgs_with_renv_install <- function(df_pkgs_to_install) {
  cli::cli_progress_bar(
    format = "Installing {.pkg {df_pkgs_to_install$package_name_same_length[i]}}| {cli::pb_bar}| ETA {cli::pb_eta}",
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

is_empty <- function(x) length(x) == 0

is_named <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    return(FALSE)
  }
  if (any(nms == "")) {
    return(FALSE)
  }
  TRUE
}

base_pkgs <- c(
  "base", "compiler", "datasets", "graphics", "grDevices", "grid",
  "methods", "parallel", "splines", "stats", "stats4", "tools", "tcltk",
  "utils"
)
