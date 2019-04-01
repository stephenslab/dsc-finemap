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

caviar: fit_caviar.R + \
             R(posterior = finemap_mcaviar(sumstats$bhat/sumstats$shat,
                                            ld[[ld_method]], args, prefix=cache))
  @CONF: R_libs = (dplyr, magrittr)
  sumstats: $sumstats
  ld: list(in_sample = $ld_in_file, out_sample = $ld_out_sample)
  ld_method: "in_sample", "out_sample"
  args: "-g 0.001 -c 1", "-g 0.001 -c 2", "-g 0.001 -c 3"
  cache: file(CAVIAR)
  $posterior: posterior

finemap(caviar): fit_finemap.R + \
             R(posterior = finemap_mvar(sumstats$bhat / sumstats$shat,
                                        ld[[ld_method]], N, k,
                                        args, prefix=cache))
  N: $N_in
  k: NULL
  args: "--n-causal-max 5"
  cache: file(FM)

dap: fit_dap.py + Python(posterior = dap_batch(X, Y, cache, args))
  X: $X
  Y: $Y
  args: "-ld_control 0.20 --all"
  cache: file(DAP)
  $posterior: posterior

dap_z: fit_dap.py + Python(posterior = dap_batch_z(sumstats['bhat']/sumstats['shat'],
                                                       ld[[ld_method]], cache, args))
  sumstats: $sumstats
  ld: list(in_sample = $ld_in_file, out_sample = $ld_out_sample)
  ld_method: "in_sample", "out_sample"
  args: "-ld_control 0.20 --all"
  cache: file(DAP)
  $posterior: posterior

susie: fit_susie.R
  # Prior variance of nonzero effects.
  @CONF: R_libs = susieR
  maxI: 200
  maxL: 10
  null_weight: 0, 0.5, 0.9, 0.95
  prior_var: 0, 0.1, 0.4
  X: $X
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

susie_z: susie_z.R + \
              R(res = susie_z_multiple(sumstats$bhat/sumstats$shat,
                ld[[ld_method]], L, s_init, estimate_residual_variance))
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  L: 5
  ld: list(in_sample = $ld_in_file, out_sample = $ld_out_sample)
  ld_method: "in_sample", "out_sample"
  estimate_residual_variance: TRUE
  $fitted: res$fitted
  $posterior: res$posterior

susie_z_large(susie_z):
  L: 201

susie_z_init(susie_z):
  s_init: $s_init
  L: 10

susie_bhat: susie_bhat.R + \
              R(res = susie_bhat_multiple(sumstats$bhat, sumstats$shat,
                ld[[ld_method]], n, L, s_init, estimate_residual_variance))
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  n: $N_in
  L: 5
  ld: list(in_sample = $ld_in_file, out_sample = $ld_out_sample)
  ld_method: "in_sample", "out_sample"
  estimate_residual_variance: TRUE
  $fitted: res$fitted
  $posterior: res$posterior

susie_bhat_large(susie_bhat):
  L: 201

susie_bhat_init(susie_bhat):
  s_init: $s_init
  L: 10
