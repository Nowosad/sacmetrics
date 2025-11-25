# Tests for variogram_auc() function

# Test AUC calculation with simple model
vgm_model <- data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
auc_value <- variogram_auc(vgm_model, maxdist = 100)
expect_true(is.numeric(auc_value))
expect_true(auc_value > 0)

# Test AUC increases with larger maxdist
auc_short <- variogram_auc(vgm_model, maxdist = 50)
auc_long <- variogram_auc(vgm_model, maxdist = 200)
expect_true(auc_long > auc_short)

# Test warning when n is even (should increment to odd)
expect_warning(
  variogram_auc(vgm_model, maxdist = 100, n = 100),
  pattern = "odd"
)

# Test AUC with only nugget model (constant semivariance)
nug_only <- data.frame(model = c("Nug"), psill = c(1.0), range = c(0))
auc_nug <- variogram_auc(nug_only, maxdist = 100)
# For a constant function f(x)=1 from 0 to 100, AUC should be 100
expect_equal(auc_nug, 100, tolerance = 0.01)

# Test with default maxdist inference from range
model_with_range <- data.frame(model = c("Sph"), psill = c(1.0), range = c(100))
auc_inferred <- variogram_auc(model_with_range)
expect_true(is.numeric(auc_inferred))
expect_true(auc_inferred > 0)
