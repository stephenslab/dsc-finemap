#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: small_data, full_data
  run:
    default: data * summarize_ld * lm_pve02 * get_sumstats * (susie * (score_susie, plot_susie), dap * plot_dap, caviar, finemap)
    susie: small_data * simple_lm * susie * (score_susie, plot_susie)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
