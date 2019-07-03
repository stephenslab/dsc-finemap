#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  run:
    #default: small_data * lm_pve02 * get_sumstats * (susie * score_susie, dap * score_dap, caviar_in_sample * score_caviar, finemap_in_sample * score_finemap, hierinf)
    default: small_data * lm_pve02 * get_sumstats * (susie * score_susie, dap * score_dap, finemap_in_sample * score_finemap, hierinf * score_hierinf)
    polygenic: small_data * lm_pve02poly05 * get_sumstats * (susie * score_susie, dap * score_dap, finemap_in_sample * score_finemap, caviar_in_sample * score_caviar)
    all_ten: full_data * lm_pve03 * get_sumstats * (susie10 * score_susie, dap * score_dap)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
    prop_samples: 1
  output: output/susie_paper
