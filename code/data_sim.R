data = readRDS(dataset)
n = nrow(data$X)
in_sample = sample(1:n, ceiling(n/2))
X.all = data$X[,get_center(subset, ncol(data$X))]
# Remove LD from data
if (remove_corr) X.all = apply(X.all, 2, sample)
X.sample = X.all[in_sample,]
X.out = X.all[-in_sample,]

sample.index = apply(X.sample, 2, var, na.rm=TRUE) != 0
out.index = apply(X.out, 2, var, na.rm=TRUE) != 0
choose.index = as.logical(sample.index*out.index)
X.sample = X.sample[, choose.index]
X.out = X.out[, choose.index]

maf.sample = apply(X.sample, 2, function(x) sum(x)/(2*length(x)))
maf.out = apply(X.out, 2, function(x) sum(x)/(2*length(x)))
sample.idx = maf.sample > maf_thresh
out.idx = maf.sample > maf_thresh
overlap.idx = as.logical(sample.idx*out.idx)
X.sample = X.sample[, overlap.idx]
X.out = X.out[, overlap.idx]
maf.sample = maf.sample[overlap.idx]
maf.out = maf.out[overlap.idx]

X.sample = center_scale(X.sample)
X.out = center_scale(X.out)

r.sample = cor(X.sample)
r.out = cor(X.out)
write.table(r.sample,ld_sample_file,quote=F,col.names=F,row.names=F)
write.table(r.out,ld_out_file,quote=F,col.names=F,row.names=F)
