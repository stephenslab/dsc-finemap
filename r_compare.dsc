#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: small_data
    simulate: sim_gaussian_null, sim_gaussian
    susie_oracle: init_oracle * (susie_bhat_init, susie_z_init)
  run:
    default: data * sim_gaussian * get_sumstats * ((susie_bhat,susie_z, susie_oracle) * (score_susie, plot_susie), dap_z * (score_dap, plot_dap), finemap * (score_finemap, plot_finemap))
    null: data * sim_gaussian_null * get_sumstats * ((susie_z, susie_oracle) * (score_susie, plot_susie), dap_z*(score_dap, plot_dap), finemap * (score_finemap, plot_finemap))
    susie: data * simulate * get_sumstats * ((susie_bhat, susie_z, susie_oracle) * (score_susie, plot_susie))
    finemap: data * simulate * get_sumstats * (finemap * (score_finemap, plot_finemap))
    dap: data * simulate * get_sumstats * (dap_z * score_dap)
  exec_path: code
  global:
    data_file: data/gtex-manifest-full.txt
  output: output/r_compare_full_data_signal

