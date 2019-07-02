library(hierinf)
res = list()
for (r in 1:ncol(Y)) {
    dendr <- cluster_var(x = X)
    res[[r]] <- test_hierarchy(x = X, y = Y[,r], dendr = dendr, family = "gaussian", alpha = 0.05)
    res[[r]]$sets = list()
    for (i in 1:length(res[[r]]$res.hierarchy$significant.cluster)) {
        res[[r]]$sets[[i]] = sort(match(res[[r]]$res.hierarchy$significant.cluster[[i]], colnames(X)))
    }
    res[[r]]$dendr = dendr
}