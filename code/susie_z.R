library(susieR)
library(data.table)

susie_z_analyze = function(z, R, L, s_init, estimate_residual_variance) {
  fit = tryCatch(susie_z(z, R, L=L, s_init=s_init, estimate_residual_variance = estimate_residual_variance, max_iter = 1000), 
                 error = function(e) list(sets = NULL, pip=NULL))
  return(fit)
}

susie_z_multiple = function(Z, ld_file, L, s_init, estimate_residual_variance) {
  R = as.matrix(fread(ld_file))
  fitted = list()
  posterior = list()
  if (is.null(dim(Z))) Z = matrix(ncol=1, Z)
  for (r in 1:ncol(Z)) {
    if (is.na(s_init))
      fitted[[r]] = susie_z_analyze(Z[,r], R, L, list(), estimate_residual_variance)
    else
      fitted[[r]] = susie_z_analyze(Z[,r], R, L, s_init[[r]], estimate_residual_variance)
    if(is.null(fitted[[r]]$sets))
      posterior[[r]] = NULL
    else
      posterior[[r]] = summary(fitted[[r]])
  }
  return(list(fitted=fitted, posterior=posterior))
}
