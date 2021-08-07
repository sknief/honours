
JOBID <- as.character(Sys.getenv('PBS_JOBID'))
TMP <- as.character(Sys.getenv('TMPDIR'))
wd <- (getwd())

print(TMP)
print(JOBID)
print(wd)

write.table(c(wd, JOBID), "TESTOUTPUT")
