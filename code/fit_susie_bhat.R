library(susieR)

susie_bhat_analyze = function(bhat, shat, R, n, L, s_init, estimate_residual_variance) {
  fit = tryCatch(susie_bhat(bhat, shat, R, n=n,
                            L=L, s_init=s_init,
                            estimate_residual_variance = estimate_residual_variance,
                            max_iter = 200),
                 error = function(e) list(sets = NULL, pip=NULL))
  return(fit)
}

susie_bhat_multiple = function(Bhat,Shat,R, n, L, s_init, estimate_residual_variance) {
  fitted = list()
  posterior = list()
  if (is.null(dim(Bhat))) Bhat = matrix(ncol=1, Bhat)
  if (is.null(dim(Shat))) Shat = matrix(ncol=1, Shat)
  for (r in 1:ncol(Bhat)) {
    if (is.na(s_init))
      fitted[[r]] = susie_bhat_analyze(Bhat[,r],Shat[,r], R, n[r],
                                       L=L, list(),
                                       estimate_residual_variance)
    else
      fitted[[r]] = susie_bhat_analyze(Bhat[,r],Shat[,r], R, n[r],
                                       L=L, s_init[[r]],
                                       estimate_residual_variance)
    if(is.null(fitted[[r]]$sets))
      posterior[[r]] = NULL
    else
      posterior[[r]] = summary(fitted[[r]])
  }
  return(list(fitted=fitted, posterior=posterior))
}

library(data.table)
z = sumstats$bhat/sumstats$shat;
r = as.matrix(fread(ld[[ld_method]]));
if(add_z){
  if(ld_method == 'out_sample'){
    if (is.null(N_out)) stop("Cannot use add_z out sample LD when N_out is not available (NULL)")
    r = cov2cor(r*(N_out-1) + tcrossprod(z));
    r = (r + t(r))/2;
  }else{
    r = cov2cor(r*(n-1) + tcrossprod(z));
    r = (r + t(r))/2;
  }
}
res = susie_bhat_multiple(sumstats$bhat, sumstats$shat, r, n, L, s_init, estimate_residual_variance)
