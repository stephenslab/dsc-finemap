#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  run:
    default: small_data * summarize_ld * lm_pve02 * get_sumstats * (susie * score_susie, dap * score_dap, caviar * score_caviar, finemap * score_finemap)
    hard_case: full_data * lm_pve03 * get_sumstats * (susie10 * score_susie, dap * score_dap)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
    prop_samples: 1
  output: output/susie_paper