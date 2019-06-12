# workhorse(s) for finemapping

# Module input
# ============
# $X, $Y: full data; or
# $sumstats: summary statistics; or / and
# $ld: LD information

# Module output
# =============
# $fitted: for diagnostics
# $posterior: for inference

caviar: fit_caviar.R + add_z.R + R(posterior = finemap_mcaviar(z,ld_file, args, prefix=cache))
  @CONF: R_libs = (dplyr, magrittr, data.table)
  sumstats: $sumstats
  ld: $ld
  N_out: $N_out
  N_in: $N_sample
  args: "-g 0.01 -c 2"
  ld_method: "in_sample","out_sample"
  add_z: FALSE, TRUE
  ld_out_z_file: file(out.z.ld)
  ld_in_z_file: file(in.z.ld)
  cache: file(CAVIAR)
  $posterior: posterior

caviar_add_z(caviar):
  ld_method: "out_sample"
  add_z: TRUE

caviar_in_sample(caviar):
  ld_method: "in_sample"
  add_z: FALSE

finemap(caviar): fit_finemap.R + add_z.R + R(posterior = finemap_mvar(z,ld_file, N_in, k, args, prefix=cache))
  k: NULL
  args: "n-causal-snps 5"
  cache: file(FM)

finemap_add_z(finemap):
  add_z: TRUE
  ld_method: "out_sample"

finemap_in_sample(finemap):
    ld_method: "in_sample"
    add_z: FALSE

finemapv3(caviar): fit_finemap_v3.R + add_z.R + R(posterior = finemap_mvar_v1.3(sumstats$bhat, sumstats$shat, 
                                                  maf[[ld_method]], ld_file, N_in, k, method, args, prefix=cache))
  k: NULL
  maf: $maf
  method: 'sss'
  args: "n-causal-snps 5"
  cache: file(FM)

finemapv3_in_sample(finemapv3):
    ld_method: "in_sample"
    add_z: FALSE

dap: fit_dap.py + Python(posterior = dap_batch(X, Y, cache, args))
  X: $X_sample
  Y: $Y
  args: "-ld_control 0.20 --all"
  cache: file(DAP)
  $posterior: posterior

dap_z: fit_dap.py + Python(z = sumstats['bhat']/sumstats['shat'];
                           numpy.nan_to_num(z, copy=False);
                           posterior = dap_batch_z(z, ld[ld_method], cache, args))
  sumstats: $sumstats
  ld: $ld
  ld_method: "in_sample", "out_sample"
  args: "-ld_control 0.20 --all"
  cache: file(DAP)
  $posterior: posterior

susie: fit_susie.R
  # Prior variance of nonzero effects.
  @CONF: R_libs = susieR
  maxI: 200
  maxL: 5
  null_weight: 0
  prior_var: 0
  X: $X_sample
  Y: $Y
  $posterior: posterior
  $fitted: fitted

susie_auto: fit_susie.R
  @CONF: R_libs = susieR
  X: $X_sample
  Y: $Y
  prior_var: "auto"
  $posterior: posterior
  $fitted: fitted

susie01(susie):
  null_weight: 0
  maxL: 1

susie10(susie):
  maxL: 15

#------------------------------
# SuSiE with summary statistics
#------------------------------

init_oracle: initialize.R + R(s_init=init_susie($(meta)$true_coef))
  @CONF: R_libs = susieR
  $s_init: s_init

susie_rss: fit_susie_rss.R
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  L: 2, 5
  ld: $ld
  ld_method: "in_sample", "out_sample"
  lamb: 0, 0.1, 1
  estimate_residual_variance: TRUE, FALSE
  add_z: FALSE, TRUE
  N_out: $N_out
  N_in: $N_sample
  $fitted: res$fitted
  $posterior: res$posterior

susie_rss_add_z(susie_rss):
  add_z: TRUE
  ld_method: "out_sample"

susie_rss_large(susie_rss):
  L: 201

susie_rss_init(susie_rss):
  s_init: $s_init
  L: 10

susie_bhat: fit_susie_bhat.R
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  n: $N_sample
  L: 2, 5
  ld: $ld
  ld_method: "in_sample", "out_sample"
  estimate_residual_variance: TRUE, FALSE
  add_z: FALSE, TRUE
  N_out: $N_out
  N_in: $N_sample
  $fitted: res$fitted
  $posterior: res$posterior

susie_bhat_add_z(susie_bhat):
  add_z: TRUE
  ld_method: "out_sample"

susie_bhat_large(susie_bhat):
  L: 201

susie_bhat_init(susie_bhat):
  s_init: $s_init
  L: 10