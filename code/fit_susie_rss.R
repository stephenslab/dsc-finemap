library(data.table);
z = sumstats$bhat/sumstats$shat;
r = as.matrix(fread(ld[[ld_method]]));
if (add_z) {
  if (ld_method == 'out_sample') {
    r = cov2cor(r*(N_out-1) + tcrossprod(z));
  }
}
res = susie_rss_multiple(z, r, L, lamb, s_init, estimate_residual_variance)
