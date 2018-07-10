context("pkginspector_example")

test_that("Rejects bad input with informative message", {
  expect_error(pkginspector_example("bad"), "o file found")
})

test_that("Finds the example package 'viridisLite' in inst/extdata/", {
  pkg <- "viridisLite"
  expect_silent(path <- pkginspector_example(pkg))
  expect_equal(basename(path), pkg)
  expect_equal(basename(dirname(path)), "extdata")
  expect_equal(dir(path, pattern = "DESCRIPTION"), "DESCRIPTION")
})
  