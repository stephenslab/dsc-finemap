#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: liter_data, full_data
  run:
    default: data * summarize_ld * lm_pve02 * get_sumstats * (susie * (score_susie, plot_susie), dap * plot_dap, caviar, finemap)
    susie: liter_data * simple_lm * susie * (score_susie, plot_susie)
    susie_v: liter_data * simple_lm * (susie_uniroot, susie_em, susie_optim) * (score_susie, plot_susie)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
