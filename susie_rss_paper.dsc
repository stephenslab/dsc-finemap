#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    method_susie: susie_bhat, susie_bhat_add_z, susie_rss, susie_rss_add_z
    method_finemap: finemap, finemap_add_z
    method_caviar: caviar, caviar_add_z
  run:
    default: small_data * lm_pve02 * get_sumstats * (method_susie * score_susie, method_finemap * score_finemap, method_caviar * score_caviar)
    polygenic: small_data * lm_pve02poly05 * get_sumstats * (method_susie * score_susie, method_finemap * score_finemap, method_caviar * score_caviar)
    all_ten: full_data * lm_pve03 * get_sumstats * (method_susie * score_susie, method_finemap * score_finemap, method_caviar * score_caviar)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
    prop_samples: 0.5
  output: output/rss_compare_add_z_lambda
