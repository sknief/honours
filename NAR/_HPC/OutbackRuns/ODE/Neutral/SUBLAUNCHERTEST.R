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

seeds <- read.csv(paste0("/home/",USER,"/OutbackRuns/ADD/testseeds.csv"), header = T)
combos <- read.csv(paste0("/home/",USER,"/OutbackRuns/ADD/testcombo.csv"), header = T)

# Set which runs to do according to node

switch (ARRAY_INDEX,
        { combos <- combos[1:3,] },
        { combos <- combos[4:5,] },
        { combos <- combos[6:8,] },
        { combos <- combos[9:10,] }
)


cl <- makeCluster(future::availableCores())
registerDoParallel(cl)

#Run SLiM
foreach(i=1:nrow(combos)) %:%
  foreach(j=seeds$Seed) %dopar% {
    # Use string manipulation functions to configure the command line args, feeding from a data frame of seeds
    # then run SLiM with system(),
    slim_out <- system(sprintf("/home/$USER/SLiM/build/slim -s %s -d AalphaINI=%f -d AbetaINI=%f -d BalphaINI=%f -d BbetaINI=%f -d modelindex=%i ~/OutbackRuns/ODE/Neutral/TestModel.slim",
                               as.character(j), combos[i,]$Aalpha, combos[i,]$Abeta, combos[i,]$Balpha, combos[i,]$Bbeta, i, intern=T))
  }

stopCluster(cl)
