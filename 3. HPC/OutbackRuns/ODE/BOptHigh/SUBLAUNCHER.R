##############################################################################################################
#  Run SLiM in parallel
##############################################################################################################

#  Parallel script modified from SLiM-Extras example R script, info at
#  the SLiM-Extras repository at https://github.com/MesserLab/SLiM-Extras.

# Environment variables

USER <- Sys.getenv('USER')
ARRAY_INDEX <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))

# Parallelisation libraries

library(foreach)
library(doParallel)
library(future)


seeds <- read.csv(paste0("/home/",USER,"/OutbackRuns/ODE/seeds.csv"), header = T)
combos <- read.csv(paste0("/home/",USER,"/OutbackRuns/ODE/combo.csv"), header = T)

# Set which runs to do according to node

switch (ARRAY_INDEX,
        { combos <- combos[1:25,] },
        { combos <- combos[26:50,] },
        { combos <- combos[51:75,] },
        { combos <- combos[76:100,] }
)


cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

#Run SLiM
foreach(i=1:nrow(combos)) %:%
  foreach(j=seeds$Seed) %dopar% {
    # Use string manipulation functions to configure the command line args, feeding from a data frame of seeds
    # then run SLiM with system(),
    slim_out <- system(sprintf("/usr/bin/slim -s %s -d AalphaINI=%f -d AbetaINI=%f -d BalphaINI=%f -d BbetaINI=%f -d modelindex=%i ~/OutbackRuns/ODE/BOptHigh/Model.slim",
                               as.character(j), combos[i,]$Aalpha, combos[i,]$Abeta, combos[i,]$Balpha, combos[i,]$Bbeta, i, intern=T))
  }

stopCluster(cl)
