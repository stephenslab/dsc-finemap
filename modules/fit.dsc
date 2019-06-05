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

caviar: fit_caviar.R
  @CONF: R_libs = (dplyr, magrittr)
  sumstats: $sumstats
  ld: $ld
  ld_method: "in_sample","out_sample"
  maf: $maf
  maf_thresh: 0, 0.05
  N_out: $N_out
  N_in: $N_in
  args: "-g 0.01 -c 2"
  add_z: FALSE, TRUE
  ld_out_z_file: file(out.z.ld)
  ld_in_z_file: file(in.z.ld)
  ld_maf_out_z_file: file(maf.out.z.ld)
  ld_maf_out_file: file(maf.out.ld)
  ld_maf_in_z_file: file(maf.in.z.ld)
  ld_maf_in_file: file(maf.in.ld)
  cache: file(CAVIAR)
  $posterior: posterior
  $idx: idx

caviar_add_z(caviar):
  ld_method: "out_sample"
  add_z: TRUE
  
finemap(caviar): fit_finemap_v3.R
  k: NULL
  method: 'sss'
  args: "n-causal-snps 5"
  cache: file(FM)

finemap_add_z(finemap):
  add_z: TRUE
  ld_method: "out_sample"

dap: fit_dap.py + Python(posterior = dap_batch(X, Y, cache, args))
  X: $X
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
  X: $X_in
  Y: $Y
  $posterior: posterior
  $fitted: fitted

susie_auto: fit_susie.R
  @CONF: R_libs = susieR
  X: $X
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

susie_rss: susie_rss.R + fit_susie_rss.R
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  L: 1, 2, 5
  ld: $ld
  ld_method: "in_sample", "out_sample"
  lamb: 0, 0.1, 1
  estimate_residual_variance: TRUE, FALSE
  add_z: FALSE, TRUE
  N_out: $N_out
  N_in: $N_in
  maf: $maf
  maf_thresh: 0, 0.05
  $fitted: res$fitted
  $posterior: res$posterior
  $idx: idx

susie_rss_add_z(susie_rss):
  add_z: TRUE
  ld_method: "out_sample"

susie_rss_large(susie_rss):
  L: 201

susie_rss_init(susie_rss):
  s_init: $s_init
  L: 10

susie_bhat: susie_bhat.R + fit_susie_bhat.R
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  n: $N_in
  L: 1, 2, 5
  ld: $ld
  ld_method: "in_sample", "out_sample"
  estimate_residual_variance: TRUE, FALSE
  add_z: FALSE, TRUE
  N_out: $N_out
  N_in: $N_in
  maf: $maf
  maf_thresh: 0, 0.05
  $fitted: res$fitted
  $posterior: res$posterior
  $idx: idx

susie_bhat_add_z(susie_bhat):
  add_z: TRUE
  ld_method: "out_sample"

susie_bhat_large(susie_bhat):
  L: 201

susie_bhat_init(susie_bhat):
  s_init: $s_init
  L: 10
