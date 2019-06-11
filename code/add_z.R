library(data.table);
z = sumstats$bhat / sumstats$shat;
if(add_z){
  r = as.matrix(fread(ld[[ld_method]]));
  if(ld_method == 'out_sample'){
    if (is.null(N_out)) stop("Cannot use add_z out sample LD when N_out is not available (NULL)")
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