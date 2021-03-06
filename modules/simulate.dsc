#---------------------------------------
# Simulation modules written by Gao Wang
# Used in SuSiE paper
# Implemented in Python
#---------------------------------------

# base_sim:
# - A base simulator of 2 independent multivariate effects
# - using MultivariateMixture
# original_Y：
# - do not simulate data, just use original

base_sim: lib_regression_simulator.py + \
                regression_simulator.py + \
                Python(res = simulate_main(dict(X=X,Y=Y), conf, conf['cache']))
  @CONF: python_modules = (seaborn, matplotlib, pprint)
  X: $X_sample
  Y: $Y
  n_signal: 3
  n_traits: 2
  amplitude: 1
  pve: 0.05, 0.1, 0.2, 0.4
  polygenic_pve: 0
  eff_mode: "simple_lm"
  residual_mode: "identity"
  swap_eff: False
  keep_ld: True
  center_data: True
  cache: file(sim)
  tag: "sim1"
  @ALIAS: conf = Dict(!X, !Y, !eff_mode)
  $Y: res['Y']
  $V: res['V']
  $meta: dict(true_coef=res['true_coef'], residual_variance=res['residual_variance'])

simple_lm(base_sim):
  n_signal: 1, 2, 3, 4, 5

lm_pve02(simple_lm):
  pve: 0.2

lm_pve02poly05(simple_lm):
  n_signal: 1, 2, 3
  pve: 0.2
  polygenic_pve: 0.05

lm_pve03(simple_lm):
  pve: 0.3
  n_signal: 10

original_Y(base_sim):
  eff_mode: "original"

#----------------------------------------
# Simulation modules written by Yuxin Zou
# Used for SuSiE RSS evaluations
#----------------------------------------

sim_gaussian: simulate.R + \
                R(res=sim_gaussian_multiple(X, pve, n_signal, effect_weight, n_traits))
  @CONF: R_libs = susieR
  X: $X_sample
  pve: 0.2
  n_signal: 1,2,3,4,5
  effect_weight: rep(1/n_signal, n_signal)
  n_traits: 2
  $Y: res$Y
  $meta: res$meta

sim_gaussian_null(sim_gaussian):
  pve: 0
  n_signal: 0
  effect_weight: rep(1/n_signal, n_signal)

sim_gaussian_large(sim_gaussian):
  n_signal: 200
