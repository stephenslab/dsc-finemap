pdf(plot_file)
for (r in 1:length(result)) {
    if(is.null(result[[r]]$sets)){
      plot(meta$true_coef[,r], main='Error')
    }else{
      susie_plot(result[[r]], y='PIP', b=meta$true_coef[,r])
    }
}
dev.off()
