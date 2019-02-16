png(plot_file)
for (r in 1:length(result)) {
    susie_plot(result[[r]], y='PIP', b=meta$true_coef[,r])
}
dev.off()
