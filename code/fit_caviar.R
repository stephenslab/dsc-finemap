#' CAVIAR I/O
write_caviar_sumstats <- function(z, prefix) {
  cfg = list(z=paste0(prefix,".z"),
             set=paste0(prefix,"_set"),
             post=paste0(prefix,"_post"),
             log=paste0(prefix,".log"))
  write.table(z,cfg$z,quote=F,col.names=F)
  return(cfg)
}

#' Run CAVIAR
#' https://github.com/fhormoz/caviar

run_caviar <- function(z, LD_file, args = "", prefix="data")
{
  cfg = write_caviar_sumstats(z, prefix)
  cmd = paste("CAVIAR", "-z", cfg$z, "-l", LD_file, "-o", prefix, args)
  dscrutils::run_cmd(cmd)
  if(!all(file.exists(cfg$post, cfg$set, cfg$log))) {
      stop("Cannot find one of the post, set, and log files")
  }
  
  # remove unused files
  file.remove(cfg$z)
  
  log <- readLines(cfg$log)

  # read output tables
  snp <- read.delim(cfg$post)  
  stopifnot(ncol(snp) == 3)
  names(snp) <- c("snp", "snp_prob_set", "snp_prob")
  snp$snp <- as.character(snp$snp)
  snp <- rank_snp(snp)

  # `set` of snps
  set <- readLines(cfg$set)
  set_ordered <- left_join(data_frame(snp = set), snp, by = "snp") %>% 
    arrange(rank) %$% snp
  return(list(snp=snp, set=set_ordered))
}

rank_snp <- function(snp) {
  snp <- arrange(snp, -snp_prob) %>%
    mutate(
        rank = seq(1, n()),
        snp_prob_cumsum = cumsum(snp_prob) / sum(snp_prob)) %>%
    select(rank, snp, snp_prob, snp_prob_cumsum, snp_prob_set)
  return(snp)    
}

finemap_mcaviar <- function(zscore, LD_file, args, prefix, parallel = FALSE) {
  if (is.null(dim(zscore))) {
      zscore = matrix(ncol=1,zscore)
  }

  single_core = function(r) 
      run_caviar(zscore[,r], LD_file, args, 
                  paste0(prefix, '_condition_', r))
  if (parallel)
      return(parallel::mclapply(1:ncol(zscore), function(r) single_core(r),
                                mc.cores = min(8, ncol(zscore))))
  else
      return(lapply(1:ncol(zscore), function(r) single_core(r)))
}

## MAIN
library(data.table);
z = sumstats$bhat / sumstats$shat;
r = as.matrix(fread(ld[[ld_method]]));
idx = which(maf[[ld_method]] > maf_thresh)
z = z[idx]
r = r[idx, idx]
if(maf_thresh > 0){
  if(ld_method == 'out_sample'){
    if(add_z){
      r = cov2cor(r*(N_out-1) + tcrossprod(z));
      r = (r + t(r))/2;
      write.table(r,ld_maf_out_z_file,quote=F,col.names=F,row.names=F);
      ld_file = ld_maf_out_z_file;
    }else{
      write.table(r,ld_maf_out_file,quote=F,col.names=F,row.names=F);
      ld_file = ld_maf_out_file;
    }
  }else{
    if(add_z){
      r = cov2cor(r*(N_in-1) + tcrossprod(z));
      r = (r + t(r))/2;
      write.table(r,ld_maf_in_z_file,quote=F,col.names=F,row.names=F);
      ld_file = ld_maf_in_z_file;
    }else{
      write.table(r,ld_maf_in_file,quote=F,col.names=F,row.names=F);
      ld_file = ld_maf_in_file;
    }
  }
}else if(maf_thresh == 0){
  if(add_z){
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
  }else { ld_file = ld[[ld_method]] }
}
posterior = finemap_mcaviar(z,ld_file, args, prefix=cache)
if(maf_thresh > 0 || add_z == TRUE){
  if(file.exists(ld_file)){
    file.remove(ld_file)
  }
}
