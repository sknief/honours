#!/bin/bash -l
#PBS -q workq
#PBS -A your-account-string
#PBS -N slim_eg
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=120G

cd $TMPDIR

~/SLiM/slim ~/scripts/NAR_ODE_V1.X.slim

mv -v ~/$TMPDIR/* ~/scratch/user/$USER/
