########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: 20/09/21      ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amateur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)
library(readr)
library(gridExtra)

############### user input here!#########################
JOBID <- 626847
NODE <- as.numeric(Sys.getenv('PBS_ARRAY_INDEX'))
MODELTYPE <- "ODE"
OPTIMA <- "BOptLow"
S <- 2
REP <- 2
########################################################

### Set WD ####
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("/scratch/user/s4471959/", MODELTYPE, "_", OPTIMA, "/Mini", REP , "/state/partition1/pbs/tmpdir/pbs.", WD, ".tinmgr2")
setwd(workdirectory)

### Nested loops to set up this script ####
if (MODELTYPE == "ADD") {
        if (OPTIMA == "BOptHigh") {
          BOpt = 200
        } else if (OPTIMA == "BOptMed") {
          BOpt = 150
        } else if (OPTIMA == "BOptLow") {
          BOpt = 100
        } else if (OPTIMA == "Neutral") {
          BOpt = 0
        } else {
          print("Invalid Input for the Optima. Would you like to try again?")
        }
} else if (MODELTYPE == "ODE") {
        if (OPTIMA == "BOptHigh") {
          BOpt = 50
        } else if (OPTIMA == "BOptMed") {
          BOpt = 25
        } else if (OPTIMA == "BOptLow") {
          BOpt = 5
        } else if (OPTIMA == "Neutral") {
          BOpt = 0
        } else {
          print("Invalid Input for the Optima. Would you like to try again?")
        }
} else {
  print("I do not recognize that model type, did you spell something wrong?")
}

seeds <- read.csv("/home/s4471959/OutbackRuns/ODE/miniseeds.csv")
combos <-read.csv("/home/s4471959/OutbackRuns/ODE/minicombo.csv")



# ODE FILES ####

#test code only
#transseeds <- read.csv("C:/Users/sknie/github/honours/4_Analysis/transseeds.csv")
#transseeds <- transseeds[,1:2] #trim extra columns

## FILE ONLY LOOP ##
foreach(i=1: (length(combos))) %:%
  foreach(j= seeds$Seed) %do% {
    myFiles <- lapply(Sys.glob(paste0("Val_", j, "_generation_", i, "*.txt")), read.table) #ODE

    #Bigpopa, my hyuge shrimp, says hi
    BIGPOPA <- bind_rows(myFiles, .id = "Generation")
    colnames(BIGPOPA) <- BIGPOPA[1,] #column names
    colnames(BIGPOPA)[1] <- "Generation" #fix one label
    BIGPOPA <- subset(BIGPOPA, AAlpha!= "AAlpha") #remove the labels
    BIGPOPA <-   mutate_all(BIGPOPA, .funs = as.numeric) #turns characters into numerics

    #tetris, my beloved snail, says hi
    TETRIS <- BIGPOPA %>%
      group_by(BIGPOPA$Generation) %>%
      summarise(AAlpha = mean(AAlpha),
                ABeta = mean(ABeta),
                BAlpha = mean(BAlpha),
                BBeta = mean(BBeta),
                AConc = mean(AConc),
                BConc = mean(BConc)
      )
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
