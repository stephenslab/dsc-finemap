# dsc-finemap
DSC for comparing genetic fine-mapping methods.

## Benchmarks

### SuSiE manuscript benchmark

Please use command 

```
dsc susie_paper.dsc -h
```

to view available runs, and 

```
dsc susie_paper.dsc
dsc susie_paper.dsc --target all_ten
```

to run the benchmark.

### SuSiE RSS benchmark

Please use command 

```
dsc susie_rss.dsc -h
```

to view available runs, and 

```
dsc susie_rss.dsc
```

to run the benchmark.

## Organize benchmark results

See folder `analysis`. It contains some pipelines, mostly written in [SoS workflow](https://vatlab.github.io/sos-docs/workflow.html#content) and uses [`dscrutils` package](https://github.com/stephenslab/dsc/tree/master/dscrutils), to make various benchmark plots.