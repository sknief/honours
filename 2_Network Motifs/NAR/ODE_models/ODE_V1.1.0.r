######################################################
# R CODE FOR ODE MODELS [Step version a la Daniel]   #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################
# The functions used here are those given by Daniel in his e-mail "ODE evolution"

#install.packages("deSolve")
#install.packages("tidyverse")

library(deSolve)
library(tidyverse)

#### 1. read in file, format and potentially clean ######

#UBUNTU:
params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#WINDOWS: params <- read.csv(file = "/Users/sknie/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")

colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta", "K")

#### 2. calculate ODE values ###########################

###RIGHT NOW THESE ARE SINGLE TIME POINT; NEED TO TURN INTO A RANGE


#step-based function
ODEforA <- function(Abeta, Aalpha, K, A) {
    if (K >= 2) {
      ThetaK <- 0}
    else{
      ThetaK <- 1}
    sylvia <- (ThetaK * Aalpha - Abeta * A)
    return((sylvia))
}

ODEforA(20, 10, 10, 5) #simple return
outputA <- ANODE(params$Abeta, params$Aalpha, 10, 5, 5)


#simple regulation for Node B
BNODE  <- function(Bbeta, Balpha, B) {
    luna <- (Balpha - Bbeta*B)
    return((luna))
}

BNODE(10, 20, 5) #simple return
outputB <-BNODE(params$Bbeta, params$Balpha, 20)

#NEXT UP: ODE solver

#THEN: integration


##### 3. save that into MULTIPLE singleton files ########

#This sections needs to be modified with the actual output content, rn its just the functional skeleton
# ie change the variable names thats all.

individualid <- params$ID
outputA <- as.matrix(outputA)
outputA <- data.frame(cbind(individualid, outputA))
NodeAOutput <- write.csv(outputA, "NodeAoutput.csv")

outputB <- as.matrix(outputB)
outputB <- data.frame(cbind(individualid, outputB))
NodeBOutput <- write.csv((c(individualid, outputB)), "NodeBoutput.csv")
#note: make output code tighter, plus trim header, just internet is down atm
