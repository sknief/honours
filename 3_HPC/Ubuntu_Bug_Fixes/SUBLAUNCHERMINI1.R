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


seeds <- read.csv(paste0("/home/",USER,"/OutbackRuns/ODE/miniseeds.csv"), header = T)
combos <- read.csv(paste0("/home/",USER,"/OutbackRuns/ODE/minicombo3.csv"), header = T)

# Set which runs to do according to node

switch (ARRAY_INDEX,
        { combos <- combos[1,] },
        { combos <- combos[2,] },
        { combos <- combos[3,] },
        { combos <- combos[4,] }
)



cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

#Run SLiM
foreach(i=1:nrow(combos)) %:%
  foreach(j=seeds$Number) %dopar% {
    # Use string manipulation functions to configure the command line args, feeding from a data frame of seeds
    # then run SLiM with system(),
    slim_out <- system(sprintf("/usr/bin/slim -s %s -d AalphaINI=%f -d AbetaINI=%f -d BalphaINI=%f -d BbetaINI=%f -d modelindex=%i ~/OutbackRuns/ODE/ODE_Test1.slim",
                               as.character(j), combos[i,]$Aalpha, combos[i,]$Abeta, combos[i,]$Balpha, combos[i,]$Bbeta, i, intern=T))
  }

stopCluster(cl)
