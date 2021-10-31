########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: 20/09/21      ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amateur Parallelisation ####
library(plyr)
library(dplyr)
library(foreach)
library(readr)
library(ggplot2)


############### user input here!#########################
JOBID <- 626504
NODE <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))
MODELTYPE <- "ADD"
OPTIMA <- "BOptHigh"
S <- 2
REP <- 22
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/state/partition1/pbs/tmpdir/pbs.", WD, ".tinmgr2")
setwd(workdirectory)

      if (OPTIMA == "BOptHigh") {
          BOpt = 150
        } else if (OPTIMA == "BOptMed") {
          BOpt = 100
        } else if (OPTIMA == "BOptLow") {
          BOpt = 50
        } else if (OPTIMA == "Neutral") {
          BOpt = 0
        } else {
          print("Invalid Input for the Optima. Would you like to try again?")
        }

seeds <- read.csv("/home/s4471959/OutbackRuns/ADD/miniseeds.csv")
combos <-read.csv("/home/s4471959/OutbackRuns/ADD/minicombo.csv")


# ADD FILES ONLY (experimental) ####
foreach(i=1:4) %:%
  foreach(j= seeds$Seed) %do% {
    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("SLiM-output_ADD_", j, "_", i, "*.csv")), read.csv, header = FALSE)

    #Bigpopa, my hyuge shrimp, says hi (alot of the modifyers comes from ODE files, need separate loops again! )
    BIGPOPA <- bind_rows(myFiles, .id = "File")
    colnames(BIGPOPA) <- c("File", "ID", "GeneA1", "GeneA2", "GeneB1", "GeneB2", "AConc", "BGamma", "BConc", "Generation", "Seed") #column names
    BIGPOPA <-   mutate_all(BIGPOPA, .funs = as.numeric) #turns characters into numerics

    #Tetris, my beloved snail, says hi
    TETRIS <- BIGPOPA %>%
      group_by(BIGPOPA$Generation) %>%
      summarise(GeneA1 = mean(GeneA1),
                GeneA2 = mean(GeneA2),
                GeneB1 = mean(GeneB1),
                GeneB2 = mean(GeneB2),
                AConc = mean(AConc),
                BGamma = mean(BGamma),
                BConc = mean(BConc))

    colnames(TETRIS)[1] <- "Generation"
    TETRIS$SEED <- j
    TETRIS$Index <- i


    #for the datasets

    #fitness
    BIGPOPA$fitness = exp(-((BIGPOPA$BConc-BOpt)/S)^2);

    TETRIS$fitness <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(fitness= mean(fitness)) %>%
      pull(fitness)

    #distance
    BIGPOPA$distance <- BIGPOPA$BConc-BOpt

    TETRIS$distance <- BIGPOPA %>%
      group_by(BIGPOPA$Generation, .add = FALSE) %>%
      summarise(distance = mean(distance)) %>%
      pull(distance)


    #Tetris
    teddy <- as.character(paste0("Tetris_onerun_", j, "_", i,  "_node_", NODE,  ".csv"))

    Tetris <- as.data.frame(TETRIS)

    write.table(Tetris, teddy,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #BigPopa
    BigPop <- as.character(paste0("BigPopa_onerun_", j, "_", i, "_node_", NODE,  ".csv"))

    write.table(BIGPOPA, BigPop,
                append = FALSE,
                row.names = FALSE,
                col.names = TRUE)

    #mutation data stuff would go here

    
}
