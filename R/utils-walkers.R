# NOTE these aren't 100% equivalent to the purrr walkers but cover very common use-cases
#
# NOTE formula function (e.g. ~{}) are 100% supported

# walk(LETTERS, ~cat(tolower(.x)))
walk <- function(.x, .f, ...) {
  # if (inherits(.f, "formula")) {
  #   .body <- dimnames(attr(stats::terms(.f), "factors"))[[1]]
  #   .f <- function(.x, . = .x) {}
  #   body(.f) <- as.expression(parse(text=.body))
  # }

  if (inherits(.f, "function")) {
    for (idx in seq_along(.x)) .f(.x[[idx]], ...)
  } else {
    stop("I'm not sure indexing by name or number makes sense for walk().")
  }

  invisible(.x)
}
