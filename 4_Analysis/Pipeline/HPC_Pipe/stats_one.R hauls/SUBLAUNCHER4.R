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

combos <- read.csv(paste0("/home/",USER,"/Analysis/numbers.csv"), header = T)

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
foreach(i=1:nrow(combos)) %dopar% {
    # Use string manipulation functions to configure the command line args, feeding from a data frame of seeds
    # then run SLiM with system(),
    R_out <- system(sprintf("R -f /home/s4471959/Analysis/stats1_ODENeutral3.R"))
  }
stopCluster(cl)
