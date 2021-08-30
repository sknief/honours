########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amamteur Parallelisation ####

#1. Folders

#user input here!
JOBID <- 530888
NODE <- 2


WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/BOptMed/pbs.", WD , ".tinmgr2")

#to test
#workdirectory

#working directory
setwd(workdirectory)

#to test
#getwd()

#2. Files
#could put in a for loop to change these depending on the model type, for now ODE
seeds <- read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/seeds.csv")
combos <-read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/combo.csv") 

#okay, big brain move is making a for loop where it will read in the files based on the combos here
#so effectively need to partition the combos section based on node
#then let it run from index 1-25 (ie combos 1-25) with each loop going thru each seed (1-20)
#add this level of automation once the base code sits. but its noted here. 

index <- 1:25
seed <- seeds$Seed[1]
modelindex <- index[1]
transseed <- 861922731048828928
OPTIMA <- "BOptHigh"

#note: seeds need to be transformed to match the actual seed value within slim (manually generate a key)

#read in files using the values obtained above

Gen1Name <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/", OPTIMA, "/pbs.", WD, ".tinmgr2/Val_", transseed, "_generation_", modelindex, "_1.txt")
Gen1 <- read.table(Gen1Name, header = TRUE)
Gen2Name <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/", OPTIMA, "/pbs.", WD, ".tinmgr2/Val_", transseed, "_generation_", modelindex, "_2.txt")
Gen2 <- read.table(Gen2Name, header = TRUE)
Gen3Name <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/", OPTIMA, "/pbs.", WD, ".tinmgr2/Val_", transseed, "_generation_", modelindex, "_3.txt")
Gen3 <- read.table(Gen3Name, header = TRUE)
Gen4Name <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/", OPTIMA, "/pbs.", WD, ".tinmgr2/Val_", transseed, "_generation_", modelindex, "_4.txt")
Gen4 <- read.table(Gen4Name, header = TRUE)
Gen5Name <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/ODE/", OPTIMA, "/pbs.", WD, ".tinmgr2/Val_", transseed, "_generation_", modelindex, "_5.txt")
Gen5 <- read.table(Gen5Name, header = TRUE)

# expand for the non test ones

Gen1$Generation <- 1
Gen2$Generation <- 2
Gen3$Generation <- 3
Gen4$Generation <- 4
Gen5$Generation <- 5

BIGPOPA <- rbind(Gen1, Gen2, Gen3, Gen4, Gen5)

#### Rough plots for diagnostics ####

library(ggplot2)

#raw data: BConc
baseplot <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
baseplot + geom_violin()

baseplot2 <- ggplot(data = BIGPOPA, aes(x = Generation, y = BConc))
baseplot2 + geom_point(position = "jitter")

#raw data: AConc
baseplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AConc))
baseplot3 + geom_violin()

baseplot4 <- ggplot(data = BIGPOPA, aes(x = Generation, y = AConc))
baseplot4 + geom_point(position = "jitter")


#looking at means: 
Means <- NULL
Means$AConc <- rbind(mean(Gen1$AConc), mean(Gen2$AConc), mean(Gen3$AConc), mean(Gen4$AConc), mean(Gen5$AConc))
Means$BConc <- rbind(mean(Gen1$BConc), mean(Gen2$AConc), mean(Gen3$AConc), mean(Gen4$AConc), mean(Gen5$AConc))

colnames(Means) <- c("Gen", "AAlpha", "ABeta", "BAlpha", "BBeta", "AConc", "BConc")

#go back in and look at what you are actually meant to plot and work backwards - automation is an issue for friday onwards!
