#' @title Compare finemap fits to truth
#' @param sets a list of susie CS info from finemap fit
#' @param pip probability for p variables
#' @param true_coef true regression coefficients
#' @return total the number of total CS
#' @return valid the number of CS that captures a true signal
#' @return size an array of size of CS
#' @return top the number of CS whose highest PIP is the true causal
caviar_scores = function(cs, pip, true_coef) {
  if (is.null(dim(true_coef))) beta_idx = which(true_coef!=0)
  else beta_idx = which(apply(true_coef, 1, sum) != 0)
  
  if (is.null(cs)) {
    size = 0
    total = 0
    valid = 0
  } else {
    size = length(cs)
    total = 1
    valid = sum(beta_idx%in%cs)
  }
  return(list(total=total, valid=valid, size=size, signal_pip = pip[beta_idx]))
}

caviar_scores_multiple = function(res, truth) {
  total = valid = size = 0
  signal_pip = list()
  pip = list()
  for (r in 1:length(res)) {
    set = res[[r]]$set
    snps = res[[r]]$snp
    snps = snps[order(as.numeric(snps$snp)),]
    
    out = caviar_scores(set, snps$snp_prob, truth[,r])
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    signal_pip[[r]] = out$signal_pip
    pip[[r]] = snps$snp_prob
  }
  return(list(total=total, valid=valid, size=size, signal_pip = do.call(cbind, signal_pip), pip = do.call(cbind, pip)))
}