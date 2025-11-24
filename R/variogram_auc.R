#' AUC of Variogram Model
#'
#' Computes the area under the curve (AUC) of a variogram model using Simpson's rule.
#'
#' @param model A variogram model, either as a gstat model object or a data.frame with 'dist' and 'gamma' columns.
#' @param maxdist Maximum distance to consider for the variogram; if NULL, it will be inferred from the model.
#' @param n Number of points to use for numerical integration; must be odd (default is 101).
#'
#' @returns A numeric value representing the AUC of the variogram model.
#' @export
#'
#' @examples
#' vgm_model = data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
#' auc_value = variogram_auc(vgm_model)
#' auc_value
variogram_auc = function(model, maxdist = NULL, n = 101) {
  if (n %% 2 == 0) {
    warning("n must be odd for Simpson's rule; incrementing n by 1")
    n = n + 1
  }

  # infer maxdist if not given, using range column if present
  if (is.null(maxdist)) {
    if (is.data.frame(model) && "range" %in% names(model)) {
      ranges = as.numeric(model$range)
      ranges = ranges[!is.na(ranges) & ranges > 0]
      if (length(ranges) > 0) {
        maxdist = 1.5 * max(ranges)
      } else {
        maxdist = 1
      }
    } else {
      maxdist = 1
    }
  }

  # common grid
  xgrid = seq(0, maxdist, length.out = n)

  # extract curve and interpolate onto grid
  curve = get_variogram_curve(model, maxdist, n)
  ygrid = stats::approx(curve$dist, curve$gamma, xout = xgrid, rule = 2)$y

  result = simpson_equal(xgrid, ygrid)
  return(result)
}

