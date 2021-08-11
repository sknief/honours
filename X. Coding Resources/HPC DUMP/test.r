args <- commandArgs(trailingOnly = TRUE)
if ( length(args) < 2 ) {
  cat("Need 2 command line parameters i.e. SEED, PAR\n")
  q()
}

seed     <- as.numeric(args[1])
modelindex    <- as.numeric(args[2])

write.table(c(seed, modelindex), paste0("~/odeoutput_", seed, "_", modelindex, ".txt"))
print(seed)
print(modelindex)



###SLiM

cat(system(paste("Rscript ~/R/TestScripts/test.R", asString(getSeed()), modelindex)));
}
