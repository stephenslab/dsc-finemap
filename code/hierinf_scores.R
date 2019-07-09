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

#' @param sets a list of susie CS info from susie fit
#' @param true_coef true regression coefficients
#' @return total the number of total CS
#' @return valid the number of CS that captures a true signal
#' @return size an array of size of CS
#' @return purity an array of purity of CS
hierinf_scores = function(sets, true_coef) {
  if (is.null(dim(true_coef))) beta_idx = which(true_coef!=0)
  else beta_idx = which(apply(true_coef, 1, sum) != 0)
  if(is.null(sets)){
    return(list(total=NA, valid=NA, size=NA, purity=NA, avgr2=NA, has_overlap=NA))
  }
  cs = sets$cs
  if (is.null(cs)) {
    size = 0
    total = 0
    purity = 0
    avgr2 = 0
  } else {
    size = sapply(cs,length)
    purity = as.vector(sets$purity[,1])
    avgr2 = as.vector(sets$purity[,2])^2
    total = length(cs)
  }
  valid = 0
  if (total > 0) {
    for (i in 1:total){
      if (any(cs[[i]]%in%beta_idx)) valid=valid+1
    }
  }
  return(list(total=total, valid=valid, size=size, purity=purity, avgr2=avgr2, has_overlap=check_overlap(cs)))
}

hierinf_scores_multiple = function(res, truth) {
  total = valid = overlap = vector()
  size = purity = avgr2 = list()
  for (r in 1:length(res)) {
    out = hierinf_scores(res[[r]]$sets, truth[,r])
    total[r] = out$total
    valid[r] = out$valid
    size[[r]] = out$size
    purity[[r]] = out$purity
    avgr2[[r]] = out$avgr2
    overlap[r] = out$has_overlap
  }
  return(list(total=total, valid=valid, size=size, purity=purity, avgr2=avgr2, overlap=overlap))
}