######################################################
#           R CODE FOR ODE MODELS AAAAAAA            #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

# 1. read in file, format and potentially clean ######
params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#Q: how will that read in work on tinaroo? whats the location or WD?
colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta")

# 2. calculate ODE values ###########################

Xstart = 1
Xstop = 6
#for this model, A had an ODE attached
#from Jan: dZ <- bZ * (t > Xstart && t <= Xstop) * 1/(1 + Z^Hilln) - aZ*Z
#Does my Z here take on the form of my INI values? Or like an initial Aconc? or is it X?
ANODE  <- function(Abeta, Aalpha, Ahillcoeff, Xstart, Xstop, A) {
  sylvia <- params$Abeta  * (t > Xstart && t <= Xstop) * 1/(1 + Z^Ahillcoeff) - params$Aalpha*A
}

#try the entirety of Jans snippet:

ODEs_FBA <- function(t, state, parameters) {
  with (as.list(c(state, parameters)), {
    # step function leads to numerical issues in lsoda:
    #dZ <- bZ * (t > Xstart && t <= Xstop & Z<1) - aZ*Z
    # use Hill function instead:
    dZ <- bZ * (t > Xstart && t <= Xstop) * 1/(1 + Z^Hilln) - aZ*Z
    dZnoFB <- aZ * (t > Xstart && t <= Xstop) - aZ*ZnoFB
    return(list(c(dZ, dZnoFB)))
  })
}

plotDynamics_NAR <- function(Xstart = 1,
                             Xstop = 6,
                             aZ = 1,
                             bZ = 0.5,
                             tmax = 10,
                             dt = 0.01) {

  params <- c(Xstart = Xstart, Xstop = Xstop, aZ = aZ, bZ = bZ)
  iniState <- c(Z=0, ZnoFB = 0)
  times <- seq(0,tmax,by=dt)
  solution <- ode(iniState, times, ODEs_FBA, params) %>%
    as.data.frame() %>%
    as_tibble() %>%
    mutate(X = ifelse(time > params["Xstart"] & time <= params["Xstop"], 1, 0)) %>%
    select(time, X, Z, ZnoFB)

}



#and B has a normal regulation mechanism
#From Jan: dZnoFB <- aZ * (t > Xstart && t <= Xstop) - aZ*ZnoFB


# 3. save that into MULTIPLE singleton files ########
