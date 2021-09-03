########################################################
##      HONOURS ANALYIS CODE (ONE SIMULATION VERS)    ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#### Amamteur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)

#######################################
#user input here!
JOBID <- 530889
NODE <- 2
MODELTYPE <- "ODE"
OPTIMA <- "BOptMed"
S <- 2
#######################################

#First nested loop: setting BOpt depending on your input and model type
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
          BOpt = 100 
        } else if (OPTIMA == "BOptMed") {
          BOpt = 50 
        } else if (OPTIMA == "BOptLow") {
          BOpt = 10 
        } else if (OPTIMA == "Neutral") {
          BOpt = 0 
        } else {
          print("Invalid Input for the Optima. Would you like to try again?")
        }
} else {
  print("I do not recognize that model type, did you spell something wrong?")
}


#next, get your file locations right & tight
WD <- paste0(JOBID,"[", NODE, "]")
workdirectory <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/", MODELTYPE, "/", OPTIMA, "/pbs.", WD , ".tinmgr2")
setwd(workdirectory)

#second nested loop: get your seed / combo locations right depending on model type
if (MODELTYPE == "ADD") {
  seeds <- read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ADD/seeds.csv")
  combos <-read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ADD/combo.csv") 
} else if (MODELTYPE == "ODE") {
  seeds <- read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/seeds.csv")
  combos <-read.csv("C:/Users/sknie/github/honours/3. HPC/OutbackRuns/ODE/combo.csv") 
} else {
  print("Could not locate files - check your model type input!")
}


#okay, it's all running automated so now I just need to loop this stuff PER FOLDER


index <- 1:25
seed <- seeds$Seed[1]
modelindex <- index[1]

#this needs a key
transseed <- 861922731048828928


foreach(i=1:nrow(combos)) %:%
  foreach(j=seeds$Seed) %do% {
   
    #set the info
    seed <- j
    modelindex <- i
    transseed <- MATRIX GOES HERE
      
      #read in all files based on specifications above for all generations
      myFiles <- lapply(Sys.glob(paste0("Val_", transseed, "_generation_", modelindex, "_*.txt")), read.table)
      
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
        labs(x = "Generation", y = "Mean BCONC")
      
      #violin plots
      violinplot6 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
      violinplot6 + 
        geom_violin() +
        theme_classic() + 
        labs(x = "Generation", y = "Mean BCONC")
      
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
      
      BIGPOPA$fitness = exp(-((BIGPOPA$BConc-BOpt)/S)^2);
      
      TETRIS$fitness <- BIGPOPA %>%
        group_by(BIGPOPA$Generation, .add = FALSE) %>%
        summarise(fitness= mean(fitness)) %>%
        pull(fitness)
      
      # then, do the plots
      #only points
      graph7base <- ggplot(data = TETRIS, aes(x = Generation, y = fitness))
      graph7base + 
        geom_point(position = "jitter") + 
        theme_classic() + 
        labs(x = "Generation", y = "Mean Fitness")
      
      #violin plots
      violinplot7 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = fitness))
      violinplot7 + 
        geom_violin() +
        theme_classic() + 
        labs(x = "Generation", y = "Mean Fitness")
      
      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph7base + 
        geom_quantile(color = "salmon") + 
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() + 
        labs(x = "Generation", y = "Mean ACONC")
      
      
      ## GRAPH 8: ODE samples from individual runs @ different time points 
      
      
      #### Beyond the Super 8 Film ####
      
      #distance from the optima: 
      
      BIGPOPA$distance <- BIGPOPA$BConc-BOpt
      
      
      distancebase <- ggplot(BIGPOPA, aes(x = distance, colour = factor(BIGPOPA$Generation)))
      distancebase +
        geom_density() +
        theme_classic() + 
        labs(x = "Distance to the optima", y = "Individuals") +
        xlim(-41, -39) +
        theme(legend.position = "bottom")
      
      TETRIS$distance <- BIGPOPA %>%
        group_by(BIGPOPA$Generation, .add = FALSE) %>%
        summarise(distance = mean(distance)) %>%
        pull(distance)
      
      distancebase2 <- ggplot(TETRIS, aes(x =Generation, y = distance, colour = factor(TETRIS$Generation)))
      distancebase2 +
        geom_point() +
        theme_classic() + 
        labs(x = "Generations", y = "Distance to the optima") +
        ylim(-41, -39) +
        theme(legend.position = "none")
      
      #SAVE CODE FOR THE DATASETS

} #foreach closing bracket

$$$$$$$$$$$$$$$$$$ CODE GRAVEYARD $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
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




+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ###left to do
  # automation
  # SEED key (test ADD as well when you're at it)
  # save code for the graphs
  # unique save code for the data sets so that they can feed into larger analyses
  # rebuy a hardrive cord
  
  #test

