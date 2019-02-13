#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: random_data
    simulate: sim_gaussian
  run:
    default: random_data * simulate * get_sumstats * (susie_z_uniroot) * (score_susie, plot_susie)
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
