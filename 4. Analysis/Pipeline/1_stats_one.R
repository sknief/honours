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


#set da thing up
index <- 1:25
modelindex <- index[1]

transseeds <- read.csv("C:/Users/sknie/github/honours/4. Analysis/transseeds.csv")
transseeds <- transseeds[,1:2] #trim extra columns
seed <- transseeds$ï..Old.Seeds

#gonna make one loop for graphs and one loop for the new file sets i reckon

#FILES
foreach(i=1:2) %:%
  foreach(j= transseeds$Transseed) %do% {
    
    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("Val_", j, "_generation_", i, "_*.txt")), read.table)
    
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
    
}



#GRAPHS
foreach(i=1:2) %:%
  foreach(j= transseeds$Transseed) %do% {
    
    #read in all files based on specifications above for all generations
    myFiles <- lapply(Sys.glob(paste0("Val_", j, "_generation_", i, "_*.txt")), read.table)
    
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

      #### THE MAGIC 8 BALL of GRAPHS ####


      ## GRAPH 1: Mean Alpha(A) versus time (line plots and violin plots)
      #only points
      graph1base <- ggplot(data = TETRIS, aes(x = Generation, y = AAlpha))
      graph1base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(A)" )

      #ggsave(paste0("Mean_AlphaA_jitter_onerun",j, "_", i, ".png"), device = "png")

      #violin plots
      baseplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AAlpha))
      baseplot3 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(A)")

      #ggsave(paste0("Mean_AlphaA_violin_onerun",j, "_", i, ".png"), device = "png")


      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph1base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(A)")

      #ggsave(paste0("Mean_AlphaA_IQR_onerun",j, "_", i, ".png"), device = "png")


      ## GRAPH 2: Mean Beta(A) versus time (line plots and violin plots)

      #only points
      graph2base <- ggplot(data = TETRIS, aes(x = Generation, y = ABeta))
      graph2base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(A)")

      #ggsave(paste0("Mean_BetaA_jitter_onerun",j, "_", i, ".png"), device = "png")

      #violin plots
      violinplot2 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = ABeta))
      violinplot2 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(A)")

      #ggsave(paste0("Mean_BetaA_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph2base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(A)")

      #ggsave(paste0("Mean_BetaA_IQR_onerun",j, "_", i, ".png"), device = "png")

      ## GRAPH 3: Mean Alpha(B) versus time (line plots and violin plots)

      #only points
      graph3base <- ggplot(data = TETRIS, aes(x = Generation, y = BAlpha))
      graph3base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(B)" )

      #ggsave(paste0("Mean_AlphaB_jitter_onerun",j, "_", i), ".png", device = "png")

      #violin plots
      violinplot3 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BAlpha))
      violinplot3 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(B)")

      #ggsave(paste0("Mean_AlphaB_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph3base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Alpha(B)")

      #ggsave(paste0("Mean_AlphaB_IQR_onerun",j, "_", i, ".png"), device = "png")

      ## GRAPH 4: Mean Beta(B) versus time (line plots and violin plots)

      #only points
      graph4base <- ggplot(data = TETRIS, aes(x = Generation, y = BBeta))
      graph4base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(B)")

      #ggsave(paste0("Mean_BetaB_jitter_onerun",j, "_", i, ".png"), device = "png")

      #violin plots
      violinplot4 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BBeta))
      violinplot4 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(B)")

      #ggsave(paste0("Mean_BetaB_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph4base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean Beta(A)")

      #ggsave(paste0("Mean_BetaB_IQR_onerun",j, "_", i, ".png"), device = "png")

      ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)

      #only points
      graph5base <- ggplot(data = TETRIS, aes(x = Generation, y = AConc))
      graph5base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean ACONC")

      #ggsave(paste0("AConc_jitter_onerun",j, "_", i, ".png"), device = "png")


      #---stops working after here for some reason ----?


      #violin plots
      violinplot5 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = AConc))
      violinplot5 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean ACONC")

      #ggsave(paste0("AConc_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph5base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean ACONC")

      #ggsave(paste0("AConc_IQR_onerun",j, "_", i, ".png"), device = "png")

      ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)

      #only points
      graph6base <- ggplot(data = TETRIS, aes(x = Generation, y = BConc))
      graph6base +
        geom_point(position = "jitter") +
        theme_classic() +
        labs(x = "Generation", y = "Mean BCONC")

      #ggsave(paste0("BConc_jitter_onerun",j, "_", i, ".png"), device = "png")

      #violin plots
      violinplot6 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = BConc))
      violinplot6 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean BCONC")

      #ggsave(paste0("BConc_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph6base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean ACONC")

      #ggsave(paste0("BConc_IQR_onerun",j, "_", i, ".png"), device = "png")

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

      #ggsave(paste0("Fitness_jitter_onerun",j, "_", i, ".png"), device = "png")

      #violin plots
      violinplot7 <- ggplot(data = BIGPOPA, aes(x = factor(Generation), y = fitness))
      violinplot7 +
        geom_violin() +
        theme_classic() +
        labs(x = "Generation", y = "Mean Fitness")

      #ggsave(paste0("Fitness_violin_onerun",j, "_", i, ".png"), device = "png")

      #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
      graph7base +
        geom_quantile(color = "salmon") +
        geom_line(colour = "lightblue") +
        geom_smooth(colour = "lavender") +
        theme_classic() +
        labs(x = "Generation", y = "Mean ACONC")

      #ggsave(paste0("Fitness_IQR_onerun",j, "_", i, ".png"), device = "png")


      ## GRAPH 8: ODE samples from individual runs @ different time points


      #### Beyond the Super 8 Film ####

      #distance from the optima:

      BIGPOPA$distance <- BIGPOPA$BConc-BOpt

      #density plot
      distancebase <- ggplot(BIGPOPA, aes(x = distance, colour = factor(BIGPOPA$Generation)))
      distancebase +
        geom_density() +
        theme_classic() +
        labs(x = "Distance to the optima", y = "Individuals") +
        xlim(-41, -39) +
        theme(legend.position = "bottom")

      #ggsave(paste0("Distance_density_onerun",j, "_", i, ".png"), device = "png")

      #mean density?
      TETRIS$distance <- BIGPOPA %>%
        group_by(BIGPOPA$Generation, .add = FALSE) %>%
        summarise(distance = mean(distance)) %>%
        pull(distance)


      ###potential interfering for save data

      distancebase2 <- ggplot(TETRIS, aes(x =Generation, y = distance, colour = factor(TETRIS$Generation)))
      distancebase2 +
        geom_point() +
        theme_classic() +
        labs(x = "Generations", y = "Distance to the optima") +
        ylim(-41, -39) +
        theme(legend.position = "none")

      #ggsave(paste0("Fitness_jitter_onerun",j, "_", i, ".png"), device = "png")


#SAVE CODE

  #for the graphs is under the actual graph code

} #foreach closing bracket
