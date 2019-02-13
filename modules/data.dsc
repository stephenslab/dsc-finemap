# Modules to provide data
# Real or simulated

# Module output
# =============
# $data: full data
# $sumstats: summary statistics

full_data: sim_utils.R + R(data =readRDS(dataset);
            data$X = as.matrix(data$X[,get_center(subset, ncol(data$X))]);
            r = round(cor(data$X), 4);
            write.table(r,ld_file,quote=F,col.names=F,row.names=F))
  tag: "full"
  dataset: Shell{head -150 ${data_file}}
  subset: NULL
  $data: data
  $top_idx: NA
  $ld_file: file(ld)
        
lite_data(full_data):
  tag: "2k"
  subset: 2000
             
liter_data(full_data):
  tag: "1k"
  subset: 1000

tiny_data(full_data):
  tag: "300"
  subset: 300

get_sumstats: regression.R + R(res = mm_regression(as.matrix(data$X), 
                                                   as.matrix(data$Y), data$Z))
  @CONF: R_libs = abind
  data: $data
  $sumstats: res
                                                   
summarize_ld: lib_regression_simulator.py + \
                regression_simulator.py + \
                Python(res = summarize_LD(data['X'], ld_file, ld_plot))
  data: $data
  ld_file: $ld_file
  $ld_plot: file(png)
  $top_idx: res