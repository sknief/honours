yewwwww

qsub -I -A qris-uq -q Special -l select=1:ncpus=24:mem=120GB -l walltime=1:00:00


if (BConc < 0) {
  print("EEK");
  ind.tag = 0;
  }

  quality control for the ode models ^


  GNU nano 2.3.1                        File: ODE_TEST.o530649.1                                                        
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.

>
> JOBID <- as.character(Sys.getenv('PBS_JOBID'))
> TMP <- as.character(Sys.getenv('TMPDIR'))
> wd <- (getwd())
>
> print(TMP)
[1] ""
> print(JOBID)
[1] "530649[1].tinmgr2"
> print(wd)
[1] "/state/partition1/pbs/tmpdir/pbs.530649[1].tinmgr2"
>
> write.table(c(wd, JOBID), "TESTOUTPUT")
>
