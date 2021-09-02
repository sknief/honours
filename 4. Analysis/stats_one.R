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
#this can also be parallelized 

Means1 <- colMeans(Gen1) 
Means1 <- Means1[2:8]
Means1

Means2 <- colMeans(Gen2) 
Means2 <- Means2[2:8]
Means2

Means3 <- colMeans(Gen3) 
Means3 <- Means3[2:8]
Means3

Means4 <- colMeans(Gen4) 
Means4 <- Means4[2:8]
Means4

Means5 <- colMeans(Gen5) 
Means5 <- Means5[2:8]
Means5

TETRIS <- as.data.frame(rbind(Means1, Means2, Means3, Means4, Means5))

###  TL;DR: TETRIS is the means, BIGPOPA is the raw data

#Notes: 
#go back in and look at what you are actually meant to plot and work backwards - automation is an issue for friday onwards!
#also see if you can quantify variance

#### THE MAGIC 8 BALL ####

## GRAPH 1: Mean Alpha(A) versus time (line plots and violin plots)
#only points
graph1base <- ggplot(data = TETRIS, aes(x = Generation, y = AAlpha))
graph1base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(A)" )

#violin plots
baseplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AAlpha))
baseplot3 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(A)")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph1base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(A)")

## GRAPH 2: Mean Beta(A) versus time (line plots and violin plots)

#only points
graph2base <- ggplot(data = TETRIS, aes(x = Generation, y = ABeta))
graph2base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(A)")

#violin plots
violinplot2 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = ABeta))
violinplot2 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(A)")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph2base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(A)")


## GRAPH 3: Mean Alpha(B) versus time (line plots and violin plots)

#only points
graph3base <- ggplot(data = TETRIS, aes(x = Generation, y = BAlpha))
graph3base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(B)" )

#violin plots
violinplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BAlpha))
violinplot3 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(B)")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph3base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Alpha(B)")

## GRAPH 4: Mean Beta(B) versus time (line plots and violin plots)

#only points
graph4base <- ggplot(data = TETRIS, aes(x = Generation, y = BBeta))
graph4base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(B)")

#violin plots
violinplot4 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BBeta))
violinplot4 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(B)")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph4base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean Beta(A)")


## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)

#only points
graph5base <- ggplot(data = TETRIS, aes(x = Generation, y = AConc))
graph5base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#violin plots
violinplot5 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AConc))
violinplot5 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph5base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)

#only points
graph6base <- ggplot(data = TETRIS, aes(x = Generation, y = BConc))
graph6base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#violin plots
violinplot6 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
violinplot6 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph6base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
# this one is a two part deal: 
# first, calculate fitness: 

# then, do the plots
#only points
graph7base <- ggplot(data = TETRIS, aes(x = Generation, y = BConc))
graph7base + 
  geom_point(position = "jitter") + 
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#violin plots
violinplot7 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
violinplot7 + 
  geom_violin() +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")

#interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
graph7base + 
  geom_quantile(color = "salmon") + 
  geom_line(colour = "lightblue") +
  geom_smooth(colour = "lavender") +
  theme_classic() + 
  labs(x = "Generation", y = "Mean ACONC")


## GRAPH 8: ODE samples from individual runs @ different time points 


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ###left to do
  # fitness calculations
  # automation
  # SEED key (test ADD as well when you're at it)
  # save code for the graphs
  # unique save code for the data sets so that they can feed into larger analyses
  # rebuy a hardrive cord

