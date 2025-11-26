simpson_equal = function(x, y) {
  # Simpson's rule for equally spaced x; x must be monotonic and equally spaced; npoints must be odd
  n = length(x)
  if (n < 3) {
    stop("Need at least 3 points for Simpson's rule")
  }
  # check spacing
  dxs = diff(x)
  if (max(abs(dxs - dxs[1])) > 1e-8 * max(1, abs(dxs[1]))) {
    stop("simpson_equal: x is not equally spaced")
  }
  if ((n - 1) %% 2 != 0) {
    stop(
      "simpson_equal requires an odd number of points (even number of intervals)"
    )
  }
  h = dxs[1]
  # Simpson composite rule
  I = y[1] + y[n]
  I = I + 4 * sum(y[seq(2, n - 1, by = 2)])
  I = I + 2 * sum(y[seq(3, n - 2, by = 2)])
  I = I * h / 3
  return(I)
}

get_variogram_curve = function(model, maxdist, n) {
  # already empirical variogram data
  if (is.data.frame(model) && all(c("dist", "gamma") %in% names(model))) {
    df = model[order(model$dist), ]
    return(data.frame(dist = df$dist, gamma = df$gamma))
  }

  # gstat model → use variogramLine
  model = recreate_variogram_model(model)

  df = gstat::variogramLine(model, maxdist = maxdist, n = n)
  data.frame(dist = as.numeric(df$dist), gamma = as.numeric(df$gamma))
}

recreate_variogram_model = function(model) {
  if (inherits(model, "variogramModel")) {
    return(model)
  } else {
    model$model = factor(model$model)
    model$kappa = ifelse(is.null(model$kappa), 0.5, model$kappa)
    model$ang1 = ifelse(is.null(model$ang1), 0, model$ang1)
    model$ang2 = ifelse(is.null(model$ang2), 0, model$ang2)
    model$ang3 = ifelse(is.null(model$ang3), 0, model$ang3)
    model$anis1 = ifelse(is.null(model$anis1), 1, model$anis1)
    model$anis2 = ifelse(is.null(model$anis2), 1, model$anis2)
    class(model) = c("variogramModel", "data.frame")
  }
  return(model)
}
