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
#' @return purity an array of purity of CS
#' @return top the number of CS whose highest PIP is the true causal
susie_scores = function(sets, pip, true_coef) {
  if (is.null(dim(true_coef))) beta_idx = which(true_coef!=0)
  else beta_idx = which(apply(true_coef, 1, sum) != 0)
  if(is.null(sets)){
    return(list(total=NA, valid=NA, size=NA, purity=NA, top=NA, has_overlap=NA,
              signal_pip = NA))
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
  top_hit = 0
  if (total > 0) {
    for (i in 1:total){
      if (any(cs[[i]]%in%beta_idx)) valid=valid+1
      set.idx = cs[[i]]
      highest.idx = which.max(pip[set.idx])
      if (set.idx[highest.idx]%in%beta_idx) top_hit=top_hit+1
    }
  }
  return(list(total=total, valid=valid, size=size, purity=purity, top=top_hit, has_overlap=check_overlap(cs),
              signal_pip = pip[beta_idx]))
}

susie_scores_multiple = function(res, truth) {
  total = valid = size = purity = top = overlap = 0
  signal_pip = list()
  pip = list()
  objective = vector()
  converged = vector()
  for (r in 1:length(res)) {
    out = susie_scores(res[[r]]$sets, res[[r]]$pip, truth[,r])
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    purity = purity + out$purity
    top = top + out$top
    overlap = overlap + out$has_overlap
    if(is.null(susieR::susie_get_objective(res[[r]]))){
      objective[r] = NA
      converged[r] = NA
    }else{
      objective[r] = susieR::susie_get_objective(res[[r]])
      converged[r] = res[[r]]$converged
    }
    signal_pip[[r]] = out$signal_pip
    pip[[r]] = res[[r]]$pip
  }
  return(list(total=total, valid=valid, size=size, purity=purity, top=top, objective=objective, converged=sum(converged),
              overlap=overlap, signal_pip = do.call(cbind, signal_pip), pip = do.call(cbind, pip)))
}
