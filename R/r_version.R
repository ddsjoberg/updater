#' R Versions
#'
#' These functions return the current R version and the
#' the previously installed R version.
#' The format of the returned version matches the default folder name where R is installed.
#'
#' @return string of R version
#' @name r_version
#'
#' @examples
#' r_version()
#'
#' previous_r_version()
NULL

#' @rdname r_version
#' @export
r_version <- function() {
  paste0("R-", R.version$major, ".", R.version$minor)
}

#' @rdname r_version
#' @export
previous_r_version <- function() {
  # find the previous R installation folder and return the folder name ---------
  r_version <-
    getElement(
      sort(
        setdiff(
          list.files(
            dirname(
              R.home()
            )
          ),
          r_version()
        ),
        decreasing = TRUE
      ),
      1
    )

  # if couldn't find previous installation, return NULL ------------------------
  if (is_empty(r_version)) {
    cli::cli_alert_danger("Could not determine the last R version installed.")
    return(invisible())
  }
  if (!startsWith(tolower(r_version), "r-")) {
    cli::cli_alert_danger("Could not determine the last R version installed.")
    return(invisible())
  }

  r_version
}
