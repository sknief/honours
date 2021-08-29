########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amamteur Parallelisation ####

#1. Folders

#user input here!
JOBID <- 530889
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

index <- 
seed <- 
