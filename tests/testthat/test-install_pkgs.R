test_that("install_pkgs() works", {
  expect_error(r_version(), NA)
  expect_error(previous_r_version(), NA)
  expect_error(find_previous_library_loc(), NA)
  expect_error(get_installed_pkgs(), NA)

  expect_true(is_named(list(one = 1, two = 2)))
  expect_false(is_named(list(one = 1, 2)))
  expect_false(is_named(list(1, 2)))
  expect_true(is_empty(NULL))
  expect_true(is_empty(character(0L)))
})
