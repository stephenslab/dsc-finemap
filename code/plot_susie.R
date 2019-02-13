
png(plot_file)
for (r in 1:length(result)) {
    susie_plot(result[[r]], y='PIP', b=data$true_coef[,r])
}
dev.off()