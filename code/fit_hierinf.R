library(hierinf)
res = list()
for (r in 1:ncol(Y)) {
    dendr <- cluster_var(x = X)
    res[[r]] <- test_hierarchy(x = X, y = Y[,r], dendr = dendr, family = "gaussian", alpha = alpha)
    res[[r]]$sets = list(cs = list(), purity = list())
    for (i in 1:length(res[[r]]$res.hierarchy$significant.cluster)) {
        res[[r]]$sets$cs[[i]] = sort(match(res[[r]]$res.hierarchy$significant.cluster[[i]], colnames(X)))
    }
    res[[r]]$sets$purity = data.frame(do.call(rbind, lapply(1:length(res[[r]]$sets$cs), function(i) susieR:::get_purity(res[[r]]$sets$cs[[i]], X, NULL))))
    colnames(res[[r]]$sets$purity) = c('min.abs.corr', 'mean.abs.corr', 'median.abs.corr')
    res[[r]]$dendr = dendr
}