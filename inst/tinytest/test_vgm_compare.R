# Tests for vgm_compare() function

# Test similarity of identical models
vgm_model = data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
sim_identical = vgm_compare(vgm_model, vgm_model, maxdist = 100)
expect_equal(sim_identical, 1.0)

# Test similarity is in [0, 1]
vgm_model1 = data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
vgm_model2 = data.frame(model = c("Nug", "Exp"), psill = c(0.7, 1.3), range = c(0, 120))
sim_value = vgm_compare(vgm_model1, vgm_model2, maxdist = 150)
expect_true(sim_value >= 0)
expect_true(sim_value <= 1)

# Test similarity of different models is less than 1
vgm_small = data.frame(model = c("Sph"), psill = c(0.5), range = c(50))
vgm_large = data.frame(model = c("Sph"), psill = c(2.0), range = c(200))
sim_different = vgm_compare(vgm_small, vgm_large, maxdist = 200)
expect_true(sim_different < 1)

# Test warning when n is even
expect_warning(
  vgm_compare(vgm_model1, vgm_model2, maxdist = 100, n = 100),
  pattern = "odd"
)

# Test with default maxdist inference
vgm_a = data.frame(model = c("Sph"), psill = c(1.0), range = c(100))
vgm_b = data.frame(model = c("Sph"), psill = c(1.0), range = c(100))
sim_inferred = vgm_compare(vgm_a, vgm_b)
expect_equal(sim_inferred, 1.0)
