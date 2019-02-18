#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: random_data
    simulate: sim_gaussian_null, sim_gaussian
    susie_oracle: init_oracle * susie_z_init
  run:
    default: data * simulate * get_sumstats * ((susie_z, susie_oracle) * (score_susie, plot_susie), dap_z * (socre_dap, plot_dap), finemap * (socre_finemap, plot_finemap))
    susie: data * simulate * get_sumstats * ((susie_z, susie, susie_oracle) * (score_susie, plot_susie))
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
  output: output/finemap_compare_random_data
