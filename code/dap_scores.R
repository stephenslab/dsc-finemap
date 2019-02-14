#' @title Check if produced confidence sets have overlaps
#' @param cs a list a susie confidence sets from susie fit
#' @return a boolean 1 if overlap, 0 otherwise
check_overlap = function(cs) {
  if (length(cs) == 0) {
    return(0)
  } else {
    overlaps = 0
    for (i in 1:length(cs)) {
      for (j in 1:i) {
        if (i == j) next
        overlaps = overlaps + length(intersect(cs[[i]], cs[[j]]))
      }
    }
    return(overlaps)
  }
}


#' @title Compare SuSiE fits to truth
#' @param sets a list of susie CS info from susie fit
#' @param pip probability for p variables
#' @param true_coef true regression coefficients
#' @return total the number of total CS
#' @return valid the number of CS that captures a true signal
#' @return size an array of size of CS
#' @return angr2 an array of average R^2 of CS
#' @return top the number of CS whose highest PIP is the true causal
dap_scores = function(sets, pip, true_coef) {
  if (is.null(dim(true_coef))) beta_idx = which(true_coef!=0)
  else beta_idx = which(apply(true_coef, 1, sum) != 0)
  cs = apply(sets, 1, function(cluster) as.numeric(strsplit(cluster[4], ",")[[1]]))

  if (is.null(cs)) {
    size = 0
    total = 0
    purity = 0
  } else {
    size = sapply(cs,length)
    avgr2 = as.vector(sets$cluster_avg_r2)
    total = nrow(sets)
  }
  valid = 0
  top_hit = 0
  if (total > 0) {
    for (i in 1:total){
      if (any(cs[[i]]%in%beta_idx)) valid=valid+1
      set.idx = cs[[i]]
      highest.idx = which.max(pip[set.idx])
      if (set.idx[highest.idx]%in%beta_idx) top_hit=top_hit+1
    }
  }
  return(list(total=total, valid=valid, size=size, avgr2=avgr2, top=top_hit,
              has_overlap=check_overlap(cs), signal_pip = pip[beta_idx]))
}

dap_scores_multiple = function(res, truth) {
  total = valid = size = avgr2 = top = overlap = 0
  signal_pip = list()
  for (r in 1:length(res)) {
    set = res[[r]]$set
    snps = res[[r]]$snp
    snps = snps[order(snps$snp),]
    set = set[which(set$cluster_prob > 0.95),]
    out = dap_scores(set, snps$snp_prob, truth[,r])
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    avgr2 = avgr2 + out$avgr2
    top = top + out$top
    overlap = overlap + out$has_overlap
    signal_pip[[r]] = out$signal_pip
  }
  return(list(total=total, valid=valid, size=size, avgr2=avgr2, top=top, overlap=overlap, signal_pip = unlist(signal_pip)))
}
