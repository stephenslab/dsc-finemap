#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: small_data
    simulate: sim_gaussian * get_sumstats
    method_susie: susie_bhat, susie_rss
  run:
    default: data * simulate * ((method_susie * score_susie), (finemap * score_finemap), (finemapv3 * score_finemapv3), (caviar * score_caviar))
    test: data * simulate * finemap
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
    prop_samples: 0.5
  output: output/r_compare_add_z_lambda_caviar_maf
