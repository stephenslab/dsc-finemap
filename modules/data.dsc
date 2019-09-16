# Modules to provide data
# Real or simulated

# Module output
# =============
# $data: full data
# $sumstats: summary statistics

full_data: sim_utils.R + data_sim.R
  tag: "full"
  dataset: Shell{head -250 ${data_file}}
  subset: NULL
  subsample: ${prop_samples}
  ld_sample_file: file(sample.ld)
  ld_out_file: file(out.ld)
  maf_thresh: 0.05
  remove_corr: FALSE
  $X_sample: X.sample
  $X_out: X.out
  $Y: data$Y
  $N_sample: nrow(X.sample)
  $N_out: nrow(X.out)
  $maf: list(in_sample=maf.sample, out_sample=maf.out)
  $meta: data$meta
  $ld: list(in_sample=ld_sample_file, out_sample=ld_out_file)

lite_data(full_data):
  tag: "2k"
  subset: 2000

small_data(full_data):
  tag: "1k"
  subset: 1000

tiny_data(full_data):
  tag: "300"
  subset: 300

random_data: sim_utils.R + R(set.seed(seed);
              X = center_scale(matrix(rnorm(n*p), n, p));
              r = cor(X);
              write.table(r,ld_file,quote=F,col.names=F,row.names=F))
  @CONF: R_libs = susieR
  tag: "random"
  n: 1200
  p: 1000
  seed: -9
  $X_sample: X
  $Y: matrix(0,n,1)
  $N: nrow(X)
  $meta: list()
  $ld: file(ld)

get_sumstats: regression.R + R(res = mm_regression(as.matrix(X), as.matrix(Y)))
  @CONF: R_libs = abind
  X: $X_sample
  Y: $Y
  $sumstats: res

summarize_ld: lib_regression_simulator.py + \
                regression_simulator.py + \
                Python(res = summarize_LD(X, ld_file['in_sample'], ld_plot))
  X: $X_sample
  ld_file: $ld
  $ld_plot: file(png)
  $top_idx: res
