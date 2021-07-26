#!/bin/bash -l
#PBS -q workq
#PBS -A your-account-string
#PBS -N slim_eg
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=120G

cd $TMPDIR

~/SLiM/slim ~/SLiM/Scripts/Tests/Example/SLiM/slim_example.slim

cat /$TMPDIR/slim_output.csv >> /scratch/user/$USER/slim_output.csv
