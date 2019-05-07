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
    default: data * simulate * ((method_susie * score_susie), (finemap * score_finemap), (caviar * (score_caviar, plot_caviar)))
    test: data * simulate * finemap
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
  output: output/r_compare_add_z_lambda_caviar

