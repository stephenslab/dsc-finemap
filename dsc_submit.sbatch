#!/bin/bash

#SBATCH --time=20:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=3000
#SBATCH --job-name=dsc_finemap_r_compare_susie_z
#SBATCH --mail-type=BEGIN,END,FAIL

# load the openmpi module
module load R

dsc r_compare.dsc --target susiez --host yuxin_midway.yml -c 40 &> dsc.finemap.r.compare.susiez.job.log
