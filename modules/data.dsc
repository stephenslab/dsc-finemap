# Modules to provide data
# Real or simulated

# Module output
# =============
# $data: full data
# $sumstats: summary statistics

full_data: sim_utils.R + R(data = readRDS(dataset);
            in_sample = 1:ceiling(nrow(data$X)/2);
            X.all = data$X[,get_center(subset, ncol(data$X))];
            X.in = center_scale(X.all[in_sample,]);
            X.out = center_scale(X.all[-in_sample,]);
            X.all = center_scale(X.all);

            in.index = apply(X.in, 2, var, na.rm=TRUE) != 0;
            out.index = apply(X.out, 2, var, na.rm=TRUE) != 0;
            choose.index = as.logical(in.index*out.index)
            X.all = X.all[, choose.index];
            X.in = X.in[, choose.index];
            X.out = X.out[, choose.index];

            r.all = cor(X.all);
            r.in = cor(X.in);
            r.out = cor(X.out);
            write.table(r.all,ld_all_file,quote=F,col.names=F,row.names=F);
            write.table(r.in,ld_in_file,quote=F,col.names=F,row.names=F);
            write.table(r.out,ld_out_file,quote=F,col.names=F,row.names=F))
  tag: "full"
  dataset: Shell{head -150 ${data_file}}
  subset: NULL
  ld_all_file: file(all.ld)
  ld_in_file: file(in.ld)
  ld_out_file: file(out.ld)
  $X_all: X.all
  $X_in: X.in
  $X_out: X.out
  $Y: data$Y
  $N_all: nrow(X.all)
  $N_in: nrow(X.in)
  $N_out: nrow(X.out)
  $meta: data$meta
  $ld: list(all = ld_all_file, in_sample=ld_in_file, out_sample=ld_out_file)

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
  $X: X
  $Y: matrix(0,n,1)
  $N: nrow(X)
  $meta: list()
  $ld_file: file(ld)

get_sumstats: regression.R + R(res = mm_regression(as.matrix(X), as.matrix(Y)))
  @CONF: R_libs = abind
  X: $X_in
  Y: $Y
  $sumstats: res

summarize_ld: lib_regression_simulator.py + \
                regression_simulator.py + \
                Python(res = summarize_LD(X, ld_file, ld_plot))
  X: $X
  ld_file: $ld_file
  $ld_plot: file(png)
  $top_idx: res
