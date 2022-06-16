#' Find Package Library
#'
#' The function searches the system paths to find the location of the
#' previous R version's system library location.
#' It is _not_ recommended to use this function!
#' Rather, we recommend that a user simply opens the previous version of R
#' and runs `.libPaths()` to find the library location(s).
#'
#' @return package library location
#' @export
#'
#' @examples
#' find_previous_library_location()

find_previous_library_location <- function() {
  # stop if can't find the previous R version ----------------------------------
  if (is.null(previous_r_version())) {
    cli::cli_alert_danger(give_up_msg)
    return(invisible())
  }

  # get current library locations ----------------------------------------------
  current_lib_loc <- .libPaths()

  # keep libraries that reference the current R version ------------------------
  current_lib_loc <-
    current_lib_loc[grepl(pattern = r_version(), current_lib_loc)]

  # give up if not found -------------------------------------------------------
  if (is_empty(current_lib_loc)) {
    cli::cli_alert_danger(give_up_msg)
    return(invisible())
  }

  # guess the folder location --------------------------------------------------
  previous_lib_loc <-
    sub(pattern = r_version(), replacement = previous_r_version(),
        x = current_lib_loc)

  # remove any guesses that are not folder that exist --------------------------
  previous_lib_loc <-
    previous_lib_loc[file.exists(previous_lib_loc)]

  if (is_empty(previous_lib_loc)) {
    cli::cli_alert_danger(give_up_msg)
    return(invisible())
  }

  previous_lib_loc
}

give_up_msg <- "Couldn't locate previous R version's package library."
