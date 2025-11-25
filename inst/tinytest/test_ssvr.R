# Tests for ssvr() function

# Test basic ssvr calculation with simple model
expect_equal(
  ssvr(data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))),
  0.75
)

# Test ssvr with zero nugget (all spatially structured)
expect_equal(
  ssvr(data.frame(model = c("Sph"), psill = c(2.0), range = c(100))),
  1.0
)

# Test ssvr with all nugget (no spatial structure)
expect_equal(
  ssvr(data.frame(model = c("Nug"), psill = c(2.0), range = c(0))),
  0.0
)

# Test ssvr with "Nugget" spelled out
expect_equal(
  ssvr(data.frame(model = c("Nugget", "Sph"), psill = c(1.0, 1.0), range = c(0, 100))),
  0.5
)

# Test error when model is not a data.frame
expect_error(
  ssvr("not a data.frame"),
  pattern = "data.frame"
)

# Test error when required columns are missing
expect_error(
  ssvr(data.frame(foo = c(1, 2))),
  pattern = "psill"
)

# Test warning and NA return when total sill is zero
expect_warning(
  result <- ssvr(data.frame(model = c("Sph"), psill = c(0), range = c(100)))
)
expect_true(is.na(result))
