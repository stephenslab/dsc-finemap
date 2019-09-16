library(susieR)

susie_rss_analyze = function(z, R, L, lambda, s_init, estimate_residual_variance) {
  fit = tryCatch(susie_rss(z, R, L=L,
                           lambda=lambda,
                           s_init=s_init,
                           estimate_residual_variance = estimate_residual_variance,
                           max_iter = 200),
                 error = function(e) list(sets = NULL, pip=NULL))
  return(fit)
}

susie_rss_multiple = function(Z, R, L, lambda, s_init, estimate_residual_variance) {
  fitted = list()
  posterior = list()
  if (is.null(dim(Z))) Z = matrix(ncol=1, Z)
  for (r in 1:ncol(Z)) {
    if (is.na(s_init))
      fitted[[r]] = susie_rss_analyze(Z[,r], R, L,
                                      lambda, list(),
                                      estimate_residual_variance)
    else
      fitted[[r]] = susie_rss_analyze(Z[,r], R, L,
                                      lambda, s_init[[r]],
                                      estimate_residual_variance)
    if(is.null(fitted[[r]]$sets))
      posterior[[r]] = NULL
    else
      posterior[[r]] = summary(fitted[[r]])
  }
  return(list(fitted=fitted, posterior=posterior))
}

library(data.table);
z = sumstats$bhat/sumstats$shat;
r = as.matrix(fread(ld[[ld_method]]));
if (add_z) {
  if (ld_method == 'out_sample') {
    if (is.null(N_out)) stop("Cannot use add_z out sample LD when N_out is not available (NULL)")
    r = cov2cor(r*(N_out-1) + tcrossprod(z));
    r = (r + t(r))/2;
  }else{
    r = cov2cor(r*(N_in-1) + tcrossprod(z));
    r = (r + t(r))/2;
  }
}
res = susie_rss_multiple(z, r, L, lamb, s_init, estimate_residual_variance)
