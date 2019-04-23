#!/usr/bin/env dsc

%include modules/data
%include modules/simulate
%include modules/fit
%include modules/evaluate

DSC:
  define:
    data: small_data
    simulate: sim_gaussian_null, sim_gaussian
    susie_oracle: init_oracle * (susie_bhat_init, susie_rss_init)
  run:
    default: data * sim_gaussian * get_sumstats * ((susie, susie_bhat, susie_bhat_add_z, susie_rss, susie_rss_add_z) * (score_susie, plot_susie), (finemap, finemap_add_z) * (score_finemap, plot_finemap))
    null: data * sim_gaussian_null * get_sumstats * ((susie, susie_bhat, susie_bhat_add_z, susie_rss, susie_rss_add_z) * (score_susie, plot_susie), (finemap, finemap_add_z) * (score_finemap, plot_finemap))
    susiez: data * sim_gaussian * get_sumstats * (susie_rss * (score_susie, plot_susie))
    susieb: data * sim_gaussian * get_sumstats * (susie_bhat * (score_susie, plot_susie))
    susie_null: data * sim_gaussian_null * get_sumstats * ((susie_bhat, susie_rss) * (score_susie, plot_susie))
    finemap: data * sim_gaussian * get_sumstats * (finemap * (score_finemap, plot_finemap))
    finemap_null: data * sim_gaussian_null * get_sumstats * (finemap * (score_finemap, plot_finemap))
  exec_path: code
  global:
    data_file: data/gtex-manifest.txt
  output: output/r_compare_add_z

