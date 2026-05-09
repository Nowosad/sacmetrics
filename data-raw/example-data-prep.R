library(simsam)
library(terra)
library(purrr)
library(tmap)
library(sf)
library(gstat)

# simulate covariates with different ranges
set.seed(2026-04-27)
rast_grid = rast(nrows = 200, ncols = 200, xmin = 0, xmax = 200, ymin = 0, ymax = 200)
r_list = map(c(10, 100), \(x) sim_covariates(rast_grid, n = 1, method = simulate_gaussian(range = x)))
r_list

two_rasters = rast(r_list)
names(two_rasters) = c("Range 10", "Range 100")
tm = tm_shape(two_rasters) +
  tm_raster(col.scale = tm_scale_continuous(values = "-red_green", limits = c(-4.1, 4.1)),
            col.legend = tm_legend(position = tm_pos_out("center", "bottom", "center"),
                                  orientation = "landscape",
                                  title = "",
                                  frame = FALSE
                                ),
            col.free = FALSE) +
  tm_facets(ncol = 2) +
  tm_layout(panel.label.size = 1.5, panel.label.bg = FALSE, panel.label.height = 2)

# sample points
set.seed(2026-05-09)
p_list = map(r_list, \(x) sam_field(x, size = 500, method = sample_random()))

names(p_list[[1]]) = c("values", "geometry")
names(p_list[[2]]) = c("values", "geometry")

# models
v1 = gstat::variogram(values ~ 1, p_list[[1]])
m1 = gstat::fit.variogram(v1, vgm(model = "Sph"))
vl1 = gstat::variogramLine(m1, maxdist = 120) |>
      tibble::as_tibble()

library(ggplot2)
ggplot(vl1, aes(x = dist, y = gamma)) +
  geom_line() +
    ggplot2::theme_minimal()

v2 = gstat::variogram(values ~ 1, p_list[[2]])
m2 = gstat::fit.variogram(v2, vgm(model = "Sph"))
vl2 = gstat::variogramLine(m2, maxdist = 120) |>
      tibble::as_tibble()

ggplot(vl2, aes(x = dist, y = gamma)) +
  geom_line() +
    ggplot2::theme_minimal()
