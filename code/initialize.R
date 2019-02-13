init_susie = function(true_coef) {
  p = nrow(true_coef)
  s = list()
  for (r in 1:ncol(true_coef)) {
    beta_idx = which(true_coef[,r] != 0)
    beta_val = true_coef[,r][beta_idx]
    if(length(beta_idx) == 0){
      s[[r]] = NA
    }else{
      s[[r]] = susieR::susie_init_coef(beta_idx, beta_val, p)
    }
  }
  return(s)
}