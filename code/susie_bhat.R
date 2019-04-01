library(susieR)
library(data.table)

susie_bhat_analyze = function(bhat, shat, R, n, L, s_init, estimate_residual_variance) {
  fit = tryCatch(susie_bhat(bhat, shat, R, n=n, L=L, s_init=s_init, estimate_residual_variance = estimate_residual_variance, max_iter = 1000), 
                 error = function(e) list(sets = NULL, pip=NULL))
  return(fit)
}

susie_bhat_multiple = function(Bhat,Shat,ld_file, n, L, s_init, estimate_residual_variance) {
  R = as.matrix(fread(ld_file))
  fitted = list()
  posterior = list()
  if (is.null(dim(Bhat))) Bhat = matrix(ncol=1, Bhat)
  if (is.null(dim(Shat))) Shat = matrix(ncol=1, Shat)
  for (r in 1:ncol(Bhat)) {
    if (is.na(s_init))
      fitted[[r]] = susie_bhat_analyze(Bhat[,r],Shat[,r], R, n[r], L=L, list(), estimate_residual_variance)
    else
      fitted[[r]] = susie_bhat_analyze(Bhat[,r],Shat[,r], R, n[r], L, s_init[[r]], estimate_residual_variance)
    if(is.null(fitted[[r]]$sets))
      posterior[[r]] = NULL
    else
      posterior[[r]] = summary(fitted[[r]])
  }
  return(list(fitted=fitted, posterior=posterior))
}
