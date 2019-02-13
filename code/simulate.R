#' @title sim_gaussian simulates a normal y from given data matrix X
#' @param X an n by p matrix, centered and scaled
#' @param pve a scalar percentage variance explained
#' @param effect_num a scalar number of true nonzero effects
#' @param effect_weight
#' @return train_n a scalar number of trainning samples
#' @return sim_y an n vector simulated gaussian y
#' @return beta a p vector of effects
#' @return mean_corX mean of correlations of X (lower triangular entries of correlation matrix of X)
sim_gaussian = function(X.cs, pve, effect_num, effect_weight){
  n = dim(X.cs)[1]
  p = dim(X.cs)[2]

  beta.idx = sample(p, effect_num)
  beta = rep(0,p)
  beta.values = numeric(0)

  if(effect_num > 0){
    perpve = effect_weight * pve
    beta.values = sqrt(perpve)
    beta[beta.idx] = beta.values
  }

  if (effect_num==1){
    mean_corX = 1
  } else {
    effectX = X.cs[,beta.idx]
    corX = cor(effectX)
    mean_corX = mean(abs(corX[lower.tri(corX)]))
  }
  if(effect_num==0){
    sigma = 1
    sim.y = rnorm(n, 0, 1)
    Y = (sim.y - mean(sim.y))/sd(sim.y)
  } else {
    y = X.cs %*% beta
    sigma = sqrt(var(y)*(1-pve)/pve)
    epsilon = rnorm(n, mean = 0, sd = sigma)
    sim.y = y + epsilon
    Y = (sim.y - mean(sim.y))/sd(sim.y)
  }

  return(list(Y = Y, sigma = sigma, sigma_std = sigma/sd(sim.y),
              beta = beta, mean_corX = mean_corX))
}

# A wrapper for simulating multiple Y's
sim_gaussian_multiple = function(data, pve, effect_num, effect_weight, n_traits=1) {
  X = as.matrix(data$X)
  dat = list(X = susieR:::set_X_attributes(X, center=TRUE, scale = TRUE))
  dat$sigma_std = vector()
  for (r in 1:n_traits) {
    res = sim_gaussian(dat$X, pve, effect_num, effect_weight)
    if (is.null(dat$Y)) dat$Y = as.matrix(res$Y)
    else dat$Y = cbind(dat$Y, as.matrix(res$Y))
    if (is.null(dat$true_coef)) dat$true_coef = as.matrix(res$beta)
    else dat$true_coef = cbind(dat$true_coef, as.matrix(res$beta))
    dat$sigma_std[r] = res$sigma_std
  }
  return(dat)
}