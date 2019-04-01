# Modules to provide data
# Real or simulated

# Module output
# =============
# $data: full data
# $sumstats: summary statistics

full_data: sim_utils.R + R(data =readRDS(dataset);
            in_sample = sample(1:nrow(data$X), ceiling(nrow(data$X)/2));
            X.all = data$X[,get_center(subset, ncol(data$X))];
            X = center_scale(X.all[in_sample,]);
            X_out = center_scale(X.all[-in_sample,]);
            r = cor(X);
            r_out = cor(X_out);
            write.table(r,ld_in_file,quote=F,col.names=F,row.names=F);
            write.table(r_out,ld_out_file,quote=F,col.names=F,row.names=F))
  tag: "full"
  dataset: Shell{head -150 ${data_file}}
  subset: NULL
  $X: X
  $X_out: X_out
  $Y: data$Y
  $N_in: nrow(X)
  $N_out: nrow(X_out)
  $meta: data$meta
  $ld_in_file: file(ld_in)
  $ld_out_file: file(ld_out)
        
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
  X: $X
  Y: $Y
  $sumstats: res
                                                   
summarize_ld: lib_regression_simulator.py + \
                regression_simulator.py + \
                Python(res = summarize_LD(X, ld_file, ld_plot))
  X: $X
  ld_file: $ld_file
  $ld_plot: file(png)
  $top_idx: res