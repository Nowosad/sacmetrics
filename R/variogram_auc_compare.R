#' Compare AUC of Two Variogram Models
#'
#' Compute the similarity between two variogram models based on the area under
#' their curves (AUC) up to a specified maximum distance.
#'
#' @param model1 A variogram model as a data.frame with columns 'model' and 'psill',
#' typically obtained from `gstat::vgm` or `gstat::fit.variogram`.
#' @param model2 A variogram model as a data.frame with columns 'model' and 'psill',
#' typically obtained from `gstat::vgm` or `gstat::fit.variogram`.
#' @param maxdist Maximum distance to consider for the variogram; if NULL, it will be inferred from the model.
#' @param n Number of points to use for numerical integration; must be odd (default is 101).
#'
#' @returns A numeric value between 0 and 1 representing the similarity of the two variogram models
#' @export
#'
#' @examples
#' vgm_model1 = data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
#' vgm_model2 = data.frame(model = c("Nug", "Exp"), psill = c(0.7, 1.3), range = c(0, 120))
#' similarity = variogram_auc_compare(vgm_model1, vgm_model2)
#' similarity
variogram_auc_compare = function(model1, model2, maxdist = NULL, n = 101) {
  if (n %% 2 == 0) {
    warning("n should be odd for Simpson's rule; incrementing n by 1")
    n = n + 1
  }

  # unified maxdist
  if (is.null(maxdist)) {
    rng = c(model1$range, model2$range)
    rng = rng[!is.na(rng) & rng > 0]
    maxdist = if (length(rng) > 0) 1.5 * max(rng) else 1
  }

  # common x-grid
  xgrid = seq(0, maxdist, length.out = n)

  # model1 curve
  c1 = get_variogram_curve(model1, maxdist, n)
  y1 = stats::approx(c1$dist, c1$gamma, xout = xgrid, rule = 2)$y
  a1 = simpson_equal(xgrid, y1)

  # model2 curve
  c2 = get_variogram_curve(model2, maxdist, n)
  y2 = stats::approx(c2$dist, c2$gamma, xout = xgrid, rule = 2)$y
  a2 = simpson_equal(xgrid, y2)

  # similarity in [0, 1]
  if (a1 == 0 && a2 == 0) {
    sim = 1
  } else {
    denom = max(a1, a2)
    sim = if (denom == 0) 0 else 1 - abs(a1 - a2) / denom
    sim = max(0, min(1, sim))
  }
  return(sim)
}
