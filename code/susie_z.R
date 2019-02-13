library(susieR)

susie_z_analyze = function(z, R, L, s_init, estimate_residual_variance) {
  fit = susie_z(z, R, r_tol = 1E-3, L=L, s_init=s_init, estimate_residual_variance = estimate_residual_variance, max_iter = 1000)
  return(fit)
}

susie_z_multiple = function(Z, R, L, s_init, estimate_residual_variance) {
  fitted = list()
  posterior = list()
  if (is.null(dim(Z))) Z = matrix(Z)
  for (r in 1:ncol(Z)) {
    if (is.na(s_init))
      fitted[[r]] = susie_z_analyze(Z[,r], R, L, list(), estimate_residual_variance)
    else
      fitted[[r]] = susie_z_analyze(Z[,r], R, L, s_init[[r]], estimate_residual_variance)
    posterior[[r]] = summary(fitted[[r]])
  }
  return(fitted=fitted, posterior=posterior)
}