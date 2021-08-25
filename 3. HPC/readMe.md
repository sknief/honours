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


 /opt/pbs/bin/qstat -t -aw1n

 s4471959@tinaroo1:~> qstat -t
Job id            Name             User              Time Use S Queue
----------------  ---------------- ----------------  -------- - -----
560082[].tinmgr2  ODE_Neutral      s4471959                 0 Q Long
560082[1].tinmgr2 ODE_Neutral      s4471959                 0 Q Long
560082[2].tinmgr2 ODE_Neutral      s4471959                 0 Q Long
560082[3].tinmgr2 ODE_Neutral      s4471959                 0 Q Long
560082[4].tinmgr2 ODE_Neutral      s4471959                 0 Q Long
560084[].tinmgr2  ODE_BOptLow      s4471959                 0 Q Long
560084[1].tinmgr2 ODE_BOptLow      s4471959                 0 Q Long
560084[2].tinmgr2 ODE_BOptLow      s4471959                 0 Q Long
560084[3].tinmgr2 ODE_BOptLow      s4471959                 0 Q Long
560084[4].tinmgr2 ODE_BOptLow      s4471959                 0 Q Long
560085[].tinmgr2  ODE_BOptMed      s4471959                 0 Q Long
560085[1].tinmgr2 ODE_BOptMed      s4471959                 0 Q Long
560085[2].tinmgr2 ODE_BOptMed      s4471959                 0 Q Long
560085[3].tinmgr2 ODE_BOptMed      s4471959                 0 Q Long
560085[4].tinmgr2 ODE_BOptMed      s4471959                 0 Q Long
560086[].tinmgr2  ODE_BOptHigh     s4471959                 0 Q Long
560086[1].tinmgr2 ODE_BOptHigh     s4471959                 0 Q Long
560086[2].tinmgr2 ODE_BOptHigh     s4471959                 0 Q Long
560086[3].tinmgr2 ODE_BOptHigh     s4471959                 0 Q Long
560086[4].tinmgr2 ODE_BOptHigh     s4471959                 0 Q Long
560087[].tinmgr2  ADD_BoptHigh     s4471959                 0 Q Long
560087[1].tinmgr2 ADD_BoptHigh     s4471959                 0 Q Long
560087[2].tinmgr2 ADD_BoptHigh     s4471959                 0 Q Long
560087[3].tinmgr2 ADD_BoptHigh     s4471959                 0 Q Long
560087[4].tinmgr2 ADD_BoptHigh     s4471959                 0 Q Long
560088[].tinmgr2  ADD_BoptMed      s4471959                 0 Q Long
560088[1].tinmgr2 ADD_BoptMed      s4471959                 0 Q Long
560088[2].tinmgr2 ADD_BoptMed      s4471959                 0 Q Long
560088[3].tinmgr2 ADD_BoptMed      s4471959                 0 Q Long
560088[4].tinmgr2 ADD_BoptMed      s4471959                 0 Q Long
560089[].tinmgr2  ADD_BoptLow      s4471959                 0 Q Long
560089[1].tinmgr2 ADD_BoptLow      s4471959                 0 Q Long
560089[2].tinmgr2 ADD_BoptLow      s4471959                 0 Q Long
560089[3].tinmgr2 ADD_BoptLow      s4471959                 0 Q Long
560089[4].tinmgr2 ADD_BoptLow      s4471959                 0 Q Long
560091[].tinmgr2  ADD_Neutral      s4471959                 0 Q Long
560091[1].tinmgr2 ADD_Neutral      s4471959                 0 Q Long
560091[2].tinmgr2 ADD_Neutral      s4471959                 0 Q Long
560091[3].tinmgr2 ADD_Neutral      s4471959                 0 Q Long
560091[4].tinmgr2 ADD_Neutral      s4471959                 0 Q Long
