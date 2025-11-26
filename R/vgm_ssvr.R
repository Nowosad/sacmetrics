#' Spatially Structured Variance Ratio (SSVR)
#'
#' Calculates the Spatially Structured Variance Ratio (SSVR) from a variogram model
#' (the result of `gstat::vgm`, `gstat::fit.variogram, or a data.frame like gstat vgm).
#' The SSVR quantifies the proportion of variance that is spatially structured:
#' SSVR = 1 - (nugget / sill), where "sill" is total sill (sum of psill components).
#' The output is a single numeric value between 0 and 1, where values closer to 1 indicate
#' a higher proportion of the data explained by the spatial component.
#'
#' @param model A variogram model as a data.frame with columns 'model' and 'psill',
#' typically obtained from `gstat::vgm` or `gstat::fit.variogram`.
#'
#' @returns A numeric value between 0 and 1 representing the SSVR.
#' @export
#'
#' @references Kerry, R., & Oliver, M. A. (2008). Determining nugget: sill ratios of standardized variograms from aerial photographs to krige sparse soil data. Precision Agriculture, 9(1), 33-56.
#' @references Vaysse, K., & Lagacherie, P. (2015). Evaluating digital soil mapping approaches for mapping GlobalSoilMap soil properties from legacy data in Languedoc-Roussillon (France). Geoderma Regional, 4, 20-30.
#'
#' @examples
#' vgm_model = data.frame(model = c("Nug", "Sph"), psill = c(0.5, 1.5), range = c(0, 100))
#' ssvr_value = vgm_ssvr(vgm_model)
#' ssvr_value
vgm_ssvr = function(model) {
  if (!is.data.frame(model)) {
    stop(
      "'model' must be a vgm-like data.frame with columns 'model' and 'psill'"
    )
  }

  if (!all(c("model", "psill") %in% names(model))) {
    stop("'model' must contain columns 'model' and 'psill'")
  }

  nugget_rows = which(
    tolower(as.character(model$model)) %in% c("nug", "nugget")
  )
  nugget_psill = if (length(nugget_rows) > 0) {
    sum(model$psill[nugget_rows])
  } else {
    0
  }
  total_sill = sum(model$psill)

  if (total_sill == 0) {
    warning("Total sill is zero; returning NA for SSVR")
    return(NA)
  }

  ssvr_val = 1 - (nugget_psill / total_sill)
  ssvr_val = max(0, min(1, ssvr_val))
  return(ssvr_val)
}
