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
  ld: $ld
  ld_method: "all", "in_sample", "out_sample"
  args: "-g 0.001 -c 1", "-g 0.001 -c 2", "-g 0.001 -c 3"
  cache: file(CAVIAR)
  $posterior: posterior

finemap(caviar): fit_finemap.R + \
             R(z = sumstats$bhat / sumstats$shat;
               library(data.table);
               if(add_z){
                 r = as.matrix(fread(ld[[ld_method]]));
                 if(ld_method == 'out_sample'){
                    r = cov2cor(r*(N_out-1) + tcrossprod(z));
                    write.table(r,ld_out_z_file,quote=F,col.names=F,row.names=F);
                    ld_file = ld_out_z_file;
                  } else if(ld_method == 'all'){
                    r = cov2cor(r*(N_all-1) + tcrossprod(z));
                    write.table(r,ld_all_z_file,quote=F,col.names=F,row.names=F);
                    ld_file = ld_all_z_file;
                  }
               } else { ld_file = ld[[ld_method]] }
               posterior = finemap_mvar(z,
                                        ld_file, N, k,
                                        args, prefix=cache))
  N: $N_in
  N_out: $N_out
  N_all: $N_all
  add_z: FALSE
  k: NULL
  args: "--n-causal-max 5"
  ld_all_z_file: file(all.z.ld)
  ld_out_z_file: file(out.z.ld)
  cache: file(FM)

finemap_add_z(finemap):
  add_z: TRUE
  ld_method: "all", "out_sample"

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
  ld_method: "all", "in_sample", "out_sample"
  args: "-ld_control 0.20 --all"
  cache: file(DAP)
  $posterior: posterior

susie: fit_susie.R
  # Prior variance of nonzero effects.
  @CONF: R_libs = susieR
  maxI: 200
  maxL: 1, 5
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

susie_rss: susie_rss.R + \
                       R(library(data.table);
                         z = sumstats$bhat/sumstats$shat;
                         r = as.matrix(fread(ld[[ld_method]]));
                         if(add_z){
                           if(ld_method == 'out_sample'){
                             r = cov2cor(r*(N_out-1) + tcrossprod(z));
                           } else if(ld_method == 'all'){
                             r = cov2cor(r*(N_all-1) + tcrossprod(z));
                           }
                         }
                         res = susie_rss_multiple(z, r, L, s_init, estimate_residual_variance))
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  L: 1, 5
  ld: $ld
  ld_method: "all", "in_sample", "out_sample"
  estimate_residual_variance: TRUE
  add_z: FALSE
  N_all: $N_all
  N_out: $N_out
  $fitted: res$fitted
  $posterior: res$posterior

susie_rss_add_z(susie_rss):
  add_z: TRUE
  ld_method: "all", "out_sample"

susie_rss_large(susie_rss):
  L: 201

susie_rss_init(susie_rss):
  s_init: $s_init
  L: 10

susie_bhat: susie_bhat.R + \
              R(library(data.table);
                z = sumstats$bhat/sumstats$shat;
                r = as.matrix(fread(ld[[ld_method]]));
                if(add_z){
                  if(ld_method == 'out_sample'){
                    r = cov2cor(r*(N_out-1) + tcrossprod(z));
                  } else if(ld_method == 'all'){
                    r = cov2cor(r*(N_all-1) + tcrossprod(z));
                  }
                }
                res = susie_bhat_multiple(sumstats$bhat, sumstats$shat, r, n, L, s_init, estimate_residual_variance))
  @CONF: R_libs = (susieR, data.table)
  sumstats: $sumstats
  s_init: NA
  n: $N_in
  L: 1, 5
  ld: $ld
  ld_method: "all", "in_sample", "out_sample"
  estimate_residual_variance: TRUE
  add_z: FALSE
  N_all: $N_all
  N_out: $N_out
  $fitted: res$fitted
  $posterior: res$posterior

susie_bhat_add_z(susie_bhat):
  add_z: TRUE
  ld_method: "all", "out_sample"

susie_bhat_large(susie_bhat):
  L: 201

susie_bhat_init(susie_bhat):
  s_init: $s_init
  L: 10
