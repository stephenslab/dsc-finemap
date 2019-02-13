# dsc-finemap
DSC for comparing fine-mapping methods.

## Benchmarks

### SuSiE paper benchmark

Please use command 

```
dsc susie_paper.dsc -h
```

to view available runs, and 

```
dsc susie_paper.dsc
```

to run the benchmark.

### SuSiE z-score benchmark

Please use command 

```
dsc susie_z.dsc -h
```

to view available runs, and 

```
dsc susie_z.dsc
```

to run the benchmark.

To query DSC results, please run in R
```
library(dscrutils)

dscout <- dscquery(dsc.outdir='susie_v', targets="simple_lm.pve simple_lm.n_signal score_susie.total score_susie.size score_susie.valid score_susie.purity score_susie.top score_susie.objective score_susie.converged method", groups="method: susie_uniroot, susie_em, susie_optim", omit.file.columns=T)
```



