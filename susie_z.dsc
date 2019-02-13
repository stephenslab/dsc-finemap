#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: tiny_data
    simulate: sim_gaussian_null, sim_gaussian
  run:
    default: data * simulate * get_sumstats * ((fit_susie_z, fit_susie) * (score_susie, plot_susie), fit_dap * plot_dap, fit_caviar * plot_caviar, fit_finemap * plot_finemap)
    susie: data * simulate * get_sumstats * ((fit_susie_z, fit_susie) * (score_susie, plot_susie))
  exec_path: code
  global:
    data_file: data/yuxin-toy.txt