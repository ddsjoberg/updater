
get_installed_pkgs <- function(lib.loc = NULL) {
  df_pkgs <-
    as.data.frame(
      utils::installed.packages(
        lib.loc = lib.loc,
        fields = c("Repository", "RemoteType", "RemoteHost", "RemoteUsername",
                   "RemoteRepo", "RemoteRef", "git_url")
      ),
      stringsAsFactors = FALSE
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
    lapply(
      seq_len(nrow(df_pkgs)),
      function(i) {
        switch(
          df_pkgs$install_from[i] %in% c("GitHub", "GitLab"),
          list(
            packages =
              paste0(df_pkgs$RemoteType[i], "::",
                     df_pkgs$RemoteUsername[i], "/",
                     df_pkgs$RemoteRepo[i], "@", df_pkgs$RemoteRef[i])
          )
        ) %||%
          switch(
            df_pkgs$install_from[i] %in% "BioConductor",
            list(packages = paste0("bioc::", df_pkgs$Package[i]))
          ) %||%
          switch(
            endsWith(df_pkgs$install_from[i], "r-universe.dev"),
            list(packages = df_pkgs$Package[i], repos = c(df_pkgs$Repository[i], "https://cloud.r-project.org"))
          ) %||%
          list(packages = df_pkgs$Package[i])
      }
    )


  # return df of pkgs that will be installed -----------------------------------
  package_name_width <- max(nchar(df_pkgs$Package))
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
        do.call(
          what = renv::install,
          args = c(df_pkgs_to_install$renv_install_pkg_arg[[i]], list(prompt = FALSE))
        )
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

`%||%` <- function(x, y) {
  if (is.null(x)) return(y)
  else x
}
