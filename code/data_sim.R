data = readRDS(dataset)
n = nrow(data$X)
X.all = data$X[,get_center(subset, ncol(data$X))]
# Remove LD from data
if (remove_corr) X.all = apply(X.all, 2, sample)
if (subsample<1) {
    in_sample = sample(1:n, ceiling(n*subsample))
    X.sample = X.all[in_sample,]
    X.out = X.all[-in_sample,]
} else {
    X.sample = X.all
    X.out = NA
}
# Remove invariant sites
sample.index = apply(X.sample, 2, var, na.rm=TRUE) != 0
if (!is.na(X.out)) {
    out.index = apply(X.out, 2, var, na.rm=TRUE) != 0
} else {
    out.index = 1
}
choose.index = as.logical(sample.index * out.index)
X.sample = X.sample[, choose.index]
if (!is.na(X.out)) X.out = X.out[, choose.index]
# Apply MAF filter
maf.sample = apply(X.sample, 2, function(x) sum(x)/(2*length(x)))
if (!is.na(X.out)) {
    maf.out = apply(X.out, 2, function(x) sum(x)/(2*length(x)))
} else {
    maf.out = NA
}
if (maf_thresh > 0) {
    sample.idx = maf.sample > maf_thresh
    if (!is.na(X.out)) {
        out.idx = maf.out > maf_thresh
    } else {
        out.idx = 1
    }
    overlap.idx = as.logical(sample.idx*out.idx)
    X.sample = X.sample[, overlap.idx]
    maf.sample = maf.sample[overlap.idx]
    if (!is.na(X.out)) {
        X.out = X.out[, overlap.idx]
        maf.out = maf.out[overlap.idx]
    }
}
# Center & scale data
X.sample = center_scale(X.sample)
if (!is.na(X.out)) X.out = center_scale(X.out)
# Get LD (correlations)
r.sample = cor(X.sample)
if (!is.na(X.out)) {
    r.out = cor(X.out)
} else {
    r.out = NA
}
write.table(r.sample,ld_sample_file,quote=F,col.names=F,row.names=F)
write.table(r.out,ld_out_file,quote=F,col.names=F,row.names=F)