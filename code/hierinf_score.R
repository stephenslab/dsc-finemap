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
    return(list(total=NA, valid=NA, size=NA, purity=NA, has_overlap=NA))
  }
  cs = sets$cs
  if (is.null(cs)) {
    size = 0
    total = 0
    purity = 0
  } else {
    size = sapply(cs,length)
    purity = as.vector(sets$purity[,1])
    total = length(cs)
  }
  valid = 0
  if (total > 0) {
    for (i in 1:total){
      if (any(cs[[i]]%in%beta_idx)) valid=valid+1
    }
  }
  return(list(total=total, valid=valid, size=size, purity=purity, has_overlap=check_overlap(cs)))
}

hierinf_scores_multiple = function(res, truth) {
  total = valid = size = purity = overlap = 0
  for (r in 1:length(res)) {
    out = susie_scores(res[[r]]$sets, truth[,r])
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    purity = purity + out$purity
    overlap = overlap + out$has_overlap
  }
  return(list(total=total, valid=valid, size=size, purity=purity, overlap=overlap))
}