# Modules to evaluate various methods
# for finemapping

# Module input
# ============
# $fit: see fit.dsc
# $result: see fit.dsc

# Module output
# =============
# ? an object or plot for diagnosis

plot_finemap: plot_finemap.R
  @CONF: R_libs = (dplyr, ggplot2, cowplot)
  result: $posterior
  top_rank: 10
  $plot_file: file(png)

plot_caviar(plot_finemap): plot_caviar.R
plot_dap(plot_finemap): plot_dap.R

plot_susie: plot_susie.R
  @CONF: R_libs = susieR
  meta: $meta
  result: $fitted
  $plot_file: file(png)

score_susie: susie_scores.R + R(sc = susie_scores_multiple($(fitted), $(meta)$true_coef))
    $total: sc$total
    $valid: sc$valid
    $size: median(sc$size)
    $purity: median(sc$purity)
    $top: sc$top
    $objective: sc$objective
    $converged: sc$converged