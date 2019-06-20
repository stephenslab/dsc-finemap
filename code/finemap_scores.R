#' @title Compare finemap fits to truth
#' @param sets a list of susie CS info from finemap fit
#' @param pip probability for p variables
#' @param true_coef true regression coefficients
#' @return total the number of total CS
#' @return valid the number of CS that captures a true signal
#' @return size an array of size of CS
#' @return top the number of CS whose highest PIP is the true causal
finemap_scores = function(cs, pip, true_coef) {
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

finemap_scores_multiple = function(res, truth) {
  total = valid = size = 0
  signal_pip = list()
  pip = list()
  for (r in 1:length(res)) {
    set = res[[r]]$set
    snps = res[[r]]$snp
    n = sum(cumsum(set$config_prob) < 0.95) + 1
    if(n > nrow(set)){
      set = NULL
    }else{
      if (class(set$config) == "character") {
        set = apply(set[1:n,], 1, function(config) as.numeric(strsplit(config[2], ",")[[1]]))
        set = unique(as.vector(unlist(set)))
      } else {
        set = unique(set$config)
      }
    }
    snps = snps[order(as.numeric(snps$snp)),]

    out = finemap_scores(set, snps$snp_prob, truth[,r])
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    signal_pip[[r]] = out$signal_pip
    pip[[r]] = snps$snp_prob
  }
  return(list(total=total, valid=valid, size=size, signal_pip = do.call(cbind,signal_pip), pip = do.call(cbind,pip)))
}

finemap_v1.3_scores = function(cs, pip, true_coef) {
  if (is.null(dim(true_coef))) beta_idx = which(true_coef!=0)
  else beta_idx = which(apply(true_coef, 1, sum) != 0)

  if (is.null(cs)) {
    size = 0
    total = 0
  } else {
    size = sapply(cs,length)
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
  return(list(total=total, valid=valid, size=size, signal_pip = pip[beta_idx]))
}

finemap_v1.3_scores_multiple = function(res, truth) {
  total = valid = size = 0
  signal_pip = list()
  pip = list()
  for (r in 1:length(res)) {
    set = res[[r]]$set
    snps = res[[r]]$snp
    if(is.null(set)){
      out = list(total=NA, valid=NA, size=NA, signal_pip = NA)
      pip[[r]] = NULL
    }else{
      snps = snps[order(as.numeric(snps$snp)),]

      out = finemap_v1.3_scores(set, snps$snp_prob, truth[,r])
      pip[[r]] = snps$snp_prob
    }
    total = total + out$total
    valid = valid + out$valid
    size = size + out$size
    signal_pip[[r]] = out$signal_pip
  }
  return(list(total=total, valid=valid, size=size, signal_pip = do.call(cbind,signal_pip), pip = do.call(cbind,pip)))
}

