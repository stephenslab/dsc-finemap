#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: small_data
    simulate: sim_gaussian * get_sumstats
    method_susie: susie_bhat, susie_bhat_add_z, susie_rss, susie_rss_add_z
    method_finemap: finemap, finemap_add_z
    method_caviar: caviar, caviar_add_z
  run:
    default: data * simulate * ((method_susie * score_susie), (method_finemap * score_finemap), (method_caviar * score_caviar))
    test: data * simulate * caviar
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
    prop_samples: 0.5
  output: output/r_compare_add_z_lambda_caviar_maf
