#' FINEMAP I/O
write_finemap_sumstats_v1.3 <- function(bhat, se, allele_freq, LD_file, n, k, prefix) {
  cfg = list(z=paste0(prefix,".z"),
             ld=LD_file,
             snp=paste0(prefix,".snp"),
             config=paste0(prefix,".config"),
             k=paste0(prefix,".k"),
             log=paste0(prefix,".log"),
             meta=paste0(prefix,".master"),
             cred=paste0(prefix, '.cred'))
  # get dataset.z
  J = length(bhat)
  # FIXME: using minor allele frequency does not make sense
  z = cbind(1:J, rep(1,J), rep(1,J), rep('A',J), rep('C',J),
            pmin(allele_freq, 1-allele_freq), bhat, se)
  colnames(z) = c('rsid', 'chromosome', 'position', 'allele1', 'allele2',
                  'maf', 'beta', 'se')
  write.table(z,cfg$z,quote=F,col.names=T, row.names=F)
  if (!is.null(k)) {
      write.table(t(k),cfg$k,quote=F,col.names=F,row.names=F)
      write("z;ld;snp;config;k;log;cred;n_samples",file=cfg$meta)
      write(paste(cfg$z, cfg$ld, cfg$snp, cfg$config, cfg$k, cfg$log, cfg$cred, n, sep=";"),
        file=cfg$meta,append=TRUE)
  } else {
      write("z;ld;snp;config;log;cred;n_samples",file=cfg$meta)
      write(paste(cfg$z, cfg$ld, cfg$snp, cfg$config, cfg$log, cfg$cred, n, sep=";"),
            file=cfg$meta,append=TRUE)
  }
  return(cfg)
}

#' Run FINEMAP version 1.3
#' http://www.christianbenner.com
## FIXME: read the finemapr implementation for data sanity check.
## Can be useful as a general data sanity checker (in previous modules)

run_finemap_v1.3 <- function(bhat, se, allele_freq, LD_file, n, k, method,args = "", prefix="data")
{
  cfg = write_finemap_sumstats_v1.3(bhat, se, allele_freq, LD_file, n, k, prefix)
  if(method == 'sss'){
    cmd = paste("finemap_v1.3.1 --sss --log", "--in-files", cfg$meta, args)
  }else{
    cmd = paste("finemap_v1.3.1 --cond --log", "--in-files", cfg$meta, args)
  }

  out <- dscrutils::run_cmd(cmd, timeout=900, quit_on_error=FALSE)
  if (out != 0) {
    return(list(snp=NULL, config=NULL, set=NULL, ncausal=NULL))
  }

  # read output tables
  snp = read.table(cfg$snp,header=TRUE,sep=" ")[, c("rsid", "prob", "log10bf")]
  colnames(snp) = c("snp", "snp_prob", "snp_log10bf")
  snp$snp = as.character(snp$snp)

  snp = rank_snp_v1.3(snp)
  config = read.table(cfg$config,header=TRUE,sep=" ")[, 1:4]
  colnames(config) = c('rank', 'config', 'config_prob', 'config_log10bf')

  # Only keep configurations with cumulative 95% probability
  config = within(config, config_prob_cumsum <- cumsum(config_prob))
  config = config[config$config_prob_cumsum <= 0.95,]

  cred = read.table(cfg$cred,header = T, sep='')
  cred = cred[,grep('cred_set_',colnames(cred)), drop=FALSE]
  cs = lapply(1:ncol(cred), function(i) cred[,i][!is.na(cred[,i])] )

  # extract number of causal
  if(method == 'sss'){
    ncausal = finemap_extract_ncausal_v1.3(paste0(cfg$log, '_sss'))
  }else{
    ncausal = finemap_extract_ncausal_v1.3(paste0(cfg$log, '_cond'))
  }

  return(list(snp=snp, config=config, set=cs, ncausal=ncausal))
}

rank_snp_v1.3 <- function(snp) {
  snp <- arrange(snp, -snp_prob) %>%
    mutate(
        rank = seq(1, n()),
        snp_prob_cumsum = cumsum(snp_prob) / sum(snp_prob)) %>%
    select(rank, snp, snp_prob, snp_prob_cumsum, snp_log10bf)
  return(snp)
}

finemap_extract_ncausal_v1.3 <- function(logfile)
{
  lines <- grep("->", readLines(logfile), value = TRUE)
  lines <- gsub("\\(|\\)|>", "", lines)
  splits <- strsplit(lines, "\\s+")
  tab <- data.frame(
    ncausal_num = sapply(splits, function(x) as.integer(x[2])),
    ncausal_prob = sapply(splits, function(x) as.double(x[4])))
  tab <- mutate(tab, type = ifelse(duplicated(ncausal_num), "post", "prior"))
  return(tab)
}

finemap_mvar_v1.3 <- function(bhat, se, allele_freq, LD_file, n, k, method, args, prefix,
                         parallel = TRUE) {
  if (is.null(dim(bhat))) {
      bhat = matrix(ncol=1,bhat)
  }
  if (is.null(dim(se))) {
      se = matrix(ncol=1,se)
  }
  single_core = function(r)
      run_finemap_v1.3(bhat[,r], se[,r], allele_freq, LD_file, n, k, method, args,
                  paste0(prefix, '_condition_', r))
  if (parallel)
      return(parallel::mclapply(1:ncol(bhat), function(r) single_core(r),
                                mc.cores = min(8, ncol(bhat))))
  else
      return(lapply(1:ncol(bhat), function(r) single_core(r)))
}

## MAIN
z = sumstats$bhat / sumstats$shat;
library(data.table);
if(add_z){
  r = as.matrix(fread(ld[[ld_method]]));
  if(ld_method == 'out_sample'){
    r = cov2cor(r*(N_out-1) + tcrossprod(z));
    r = (r + t(r))/2;
    write.table(r,ld_out_z_file,quote=F,col.names=F,row.names=F);
    ld_file = ld_out_z_file;
  }else{
    r = cov2cor(r*(N_in-1) + tcrossprod(z));
    r = (r + t(r))/2;
    write.table(r,ld_in_z_file,quote=F,col.names=F,row.names=F);
    ld_file = ld_in_z_file;
  }
} else { ld_file = ld[[ld_method]] }
posterior = finemap_mvar_v1.3(sumstats$bhat, sumstats$shat, maf[[maf_method]],
                              ld_file, N_in, k, method, args, prefix=cache)
