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

#UBUNTU:params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#WINDOWS:
params <- read.csv(file = "/Users/sknie/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")

#debug note:
params$K <- runif(1000, 0, 3)

colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta", "K")

#### 2. calculate ODE values ###########################

#the ODE function (here based on a step function)
Sylvia <-function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dA <- (ThetaK * Aalpha - Abeta * A)
    dB <- (Balpha - Bbeta*B)
    list(c(dA, dB))
  })
}

#this is what defined your threshold
params$ThetaK <- 0

params$TK <- {
  for(i in 1:length(params$K)) {
  if (params$K[i] < 1) {
     params$ThetaK[i] = 1}
  else {
    params$ThetaK[i] = 0}
  }
}

#i think i gotta for loop this again:

params$ODEout <- 0

for(i in 1:nrow(params)){

  #time for actual ODE content
  para <- c(      id = 1:1000,
                  ThetaK = params$ThetaK,
                  Aalpha = params$Aalpha,
                  Abeta = params$Abeta,
                  Balpha = params$Balpha,
                  Bbeta = params$Bbeta)
  state <- c(A = 1, B = 1)
  times <- seq(0, 100, by = 1)

  #trying to write an organized file name(might be stuck in SLiM still)
  outputlist[[i]] <- ode(state, times, Sylvia, para[i, "ThetaK", "Aalpha", "Abeta", "Balpha", "Bbeta"])

}


#testing section
parameters <- c(ThetaK = params$ThetaK[3],
                Aalpha = params$Aalpha[3],
                Abeta = params$Abeta[3],
                Balpha = params$Balpha[3],
                Bbeta = params$Bbeta[3])
print(parameters)
ode(state, times, Sylvia, parameters)

#the inputs for the ODE solver




plot(out)



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
