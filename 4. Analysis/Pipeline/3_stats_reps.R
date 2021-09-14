########################################################
##      HONOURS ANALYIS CODE (ONE REP VERS)           ##
##           AUTHOR: STELLA MS KNIEF                  ##
##      START DATE: 29/08/2021 PUBLISH: TBD           ##
##       CITE WHAT YOU USE, KO-FI IF YOU'RE NICE      ##
########################################################

#######################################
#user input here!
MODELTYPE <- "ODE"
OPTIMA <- "BOptMed"
S <- 2
#######################################

#### Amamteur Parallelisation ####
library(dplyr)
library(ggplot2)
library(foreach)


##### the two loops to set up the params for the rest of the code ##### 

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


####  set WD to tank #####
workdirectory <- paste0("C:/Users/sknie/github/honours/4. Analysis/Test_files/", MODELTYPE, "/", OPTIMA, "/tank")
setwd(workdirectory)

#### foreach loops ####


#fix for test files
transseeds <- read.csv("C:/Users/sknie/github/honours/4. Analysis/transseeds.csv")
transseeds <- transseeds[,1:2] #trim extra columns
seed <- transseeds$Transseed

#test code

i <- 1 #combos (these follow the dimensions from the sublauncher)
l <- 1 #node  (see above)

#foreach(i=1:3) %:%
 # foreach(l = node) %do% {
    
    #this gives me all seeds (*) for a given combination of node and index  
    myBigPopas <- lapply(Sys.glob(paste0("BigPopa_onerun_*_", i, "_node_", l, ".csv")), read.table) #individual data
    myTetri <- lapply(Sys.glob(paste0("Tetris_onerun_*_", i, "_node_", l, ".csv")), read.table) #one entry per generation
    
    #shrimpmoult (might be made optional tbh)
    SHRIMPMOULT <- bind_rows(myBigPopas, .id = "File") #all individuals all reps for combinations
    colnames(SHRIMPMOULT) <- SHRIMPMOULT[1,] #column names
    colnames(SHRIMPMOULT)[1] <- "File" #fix one label
    SHRIMPMOULT <- subset(SHRIMPMOULT, AAlpha!= "AAlpha") #remove the labels
    SHRIMPMOULT <-   mutate_all(SHRIMPMOULT, .funs = as.numeric) #turns characters into numerics
    
  
    #pognoodle 
    POGNOODLE <- bind_rows(myTetri, .id = "Rep") #all reps for a node x index combination (params comb), one entry per generation
    colnames(POGNOODLE) <- POGNOODLE[1,] #column names
    colnames(POGNOODLE)[1] <- "Rep" #fix one label
    POGNOODLE <- subset(POGNOODLE, AAlpha!= "AAlpha") #remove the labels
    POGNOODLE <-   mutate_all(POGNOODLE, .funs = as.numeric) #turns characters into numerics
    
    #take the means across replicates (seeds) of the means across individuals (but via generation? yeah, cause each time point is unique data, and if i only want the end i still need to do it by generation)
    POGNOODLED <- POGNOODLE %>%
      group_by(POGNOODLE$Generation) %>%
      summarise(AAlpha = mean(AAlpha),
                ABeta = mean(ABeta),
                BAlpha = mean(BAlpha),
                BBeta = mean(BBeta),
                AConc = mean(AConc),
                BConc = mean(BConc),
                fitness = mean(fitness),
                distance = mean(distance)
      )
    
    colnames(POGNOODLED)[1] <- "Generation"
    
    ###generate the same graphs as before, but with overlay (need bigpopa files for that)
    ## GRAPH 1: Mean Alpha(A) versus time (line plots and violin plots)
    #only points 
    graph1base <- ggplot(data = POGNOODLE, aes(x = Generation, y = AAlpha))
    graph1base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$AAlpha, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(A)" )
    
    #violin plots
    violin1 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = AAlpha))
    violin1 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(A)")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph1base +
     # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(A)")

    
    ## GRAPH 2: Mean Beta(A) versus time (line plots and violin plots)
    #only points 
    graph2base <- ggplot(data = POGNOODLE, aes(x = Generation, y = ABeta))
    graph2base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$ABeta, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(A)" )
    
    #violin plots
    violin2 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = ABeta))
    violin2 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(A)")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph2base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(A)")
    
    
    ## GRAPH 3: Mean Alpha(B) versus time (line plots and violin plots)
    #only points 
    graph3base <- ggplot(data = POGNOODLE, aes(x = Generation, y = BAlpha))
    graph3base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$BAlpha, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(B)" )
    
    #violin plots
    violin3 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = BAlpha))
    violin3 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(B)")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph3base +
      # geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Alpha(B)")  
    
    ## GRAPH 4: Mean Beta(B) versus time (line plots and violin plots)
    #only points 
    graph4base <- ggplot(data = POGNOODLE, aes(x = Generation, y = BBeta))
    graph4base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$BBeta, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(B)" )
    
    #violin plots
    violin4 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = BBeta))
    violin4 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(B)")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph4base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Beta(B)")
    
    ## GRAPH 5: Mean Integral of A versus time (line plots and violin plots)
    #only points 
    graph5base <- ggplot(data = POGNOODLE, aes(x = Generation, y = AConc))
    graph5base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$AConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc" )
    
    #violin plots
    violin5 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = AConc))
    violin5 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph5base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean AConc")
    
    ## GRAPH 6: Mean Integral of B versus time (line plots and violin plots)
    #only points 
    graph6base <- ggplot(data = POGNOODLE, aes(x = Generation, y = BConc))
    graph6base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$BConc, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc" )
    
    #violin plots
    violin6 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = BConc))
    violin6 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph6base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean BConc")  
    
    ## GRAPH 7: Mean Population Fitness versus time (line plots and violin plots)
    graph7base <- ggplot(data = POGNOODLE, aes(x = Generation, y = fitness))
    graph7base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$fitness, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness" )
    
    #violin plots
    violin7 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin7 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph7base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Fitness") 
    
    ## GRAPH 8*: distance from the optima
    graph8base <- ggplot(data = POGNOODLE, aes(x = Generation, y = distance))
    graph8base +
      geom_point(color = "grey") +
      geom_point(data = POGNOODLED, x = POGNOODLED$Generation,  y = POGNOODLED$distance, color = "red") +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima" )
    
    #violin plots
    violin8 <- ggplot(data = POGNOODLE, aes(x = factor(Generation), y = fitness))
    violin8 +
      geom_violin() +
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")
    
    #interquartile range and lines (NOTE: i think this only makes sense with more data / on many model runs)
    graph8base +
      #geom_quantile(color = "salmon") + #this looks a bit ass ngl
      geom_line(data = POGNOODLED, colour = "lightblue") + #very similar to the below
      geom_smooth(colour = "lavender") + #very similar to the above
      theme_classic() +
      labs(x = "Generation", y = "Mean Distance to Optima")
    
    
    
    
    #facet code?
    
    #summary statistics too?

    #save the new collated data sets
    
    
    
