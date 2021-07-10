######################################################
#           R CODE FOR ODE MODELS AAAAAAA            #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

install.packages("deSolve")
install.packages("tidyverse")

library(deSolve)
library(tidyverse)

#### 1. read in file, format and potentially clean ######

#UBUNTU: params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#WINDOWS:
params <- read.csv(file = "/Users/sknie/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#Q: how will that read in work on tinaroo? whats the location or WD?
colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta")

#### 2. calculate ODE values ###########################

# THESE DESPERATELY NEED TO BE IMPROVED; FOR NOW ITS JUST
# A TEST OF MECHANICS AND NOTHING ELSE

#for this model, A had an ODE attached
#from Jan: dZ <- bZ * (t > Xstart && t <= Xstop) * 1/(1 + Z^Hilln) - aZ*Z
#Does my Z here take on the form of my INI values? Or like an initial Aconc? or is it X?
ANODE  <- function(Abeta, Aalpha, Ahillcoeff, K, A) {
  with (as.list(c(Abeta, Aalpha, Ahillcoeff, Xstart, Xstop, A)), {
  sylvia <- (Abeta /(1 + (A/K)^Ahillcoeff)) - Aalpha*A
  return((sylvia))
  })
}

#test: it works!
ANODE(20, 10, 10, 5, 5) #simple return
outputA <- ANODE(params$Abeta, params$Aalpha, 10, 5, 5)

#two possibilities: I get rid of A entirely (as I am only doing one time step, one generation at a time, so I dont have a continous Y variable, OR)
#OR: I get an indicator of a current concentration from my model: like A conc and B conc
#realistically, think about what your model is doing again and what makes more sense (talk it thru?)
#the hill function is a function of change over time, so maybe standardize time?
#-----------------------------------------------------------------------------------
#and B has a normal regulation mechanism
#From Jan: dZnoFB <- aZ * (t > Xstart && t <= Xstop) - aZ*ZnoFB

BNODE  <- function(Bbeta, Balpha, B) {
    with (as.list(c(Bbeta, Balpha, B)), {
      luna <- (Bbeta - Balpha*B)
      return((luna))
    })
}

#test: it works!
BNODE(10, 20, 5) #simple return
outputB <-BNODE(params$Bbeta, params$Balpha, 20)


##### 3. save that into MULTIPLE singleton files ########

individualid <- params$ID
outputA <- as.matrix(outputA)
outputA <- data.frame(cbind(individualid, outputA))
NodeAOutput <- write.csv(outputA, "NodeAoutput.csv")

outputB <- as.matrix(outputB)
outputB <- data.frame(cbind(individualid, outputB))
NodeBOutput <- write.csv((c(individualid, outputB)), "NodeBoutput.csv")
#note: make output code tighter, plus trim header, just internet is down atm
