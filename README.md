# dsc-finemap
DSC for comparing fine-mapping methods.

## Modules

`data` modules
- input: none
- parameters: need to take a parameter of input X in RDS format
- output: 
	- $data: (key-value) contains matrix $X, and optionally matrix $Y
	- $ld_file: (file() object) filename for LD matrix

`get_sumstats` module
- input: $data
- output: $sumstats: (key-value) contains matrix $bhat and matrix $shat

`summarize_ld` module
- input: $data, $ld_file
- output: 
	- $ld_plot: (file()) filename of LD plot
	- $top_idx: index of SNPs having strongest LD with any other SNP

`simulate` modules:
- input: $data
- output:
	- $data: (key-value) contains centered matrix $X and matrix $Y, and matrix $true_coef

`fit` modules:
- input: $data or $sumstats
- output: 
	- $fitted: (key-value) fitted object
	- $posterior: (key-value) summary of fitted object, the posterior quantities

`score_susie` module:
- input: $data$true_coef and $fitted
- output:
	- $ ...

`plot_*` module:
- input: $posterior
- output:
	- $plot_file: (file() object) filename of plot
