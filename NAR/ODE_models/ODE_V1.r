######################################################
#           R CODE FOR ODE MODELS AAAAAAA            #
#    Author: SMS Knief       Date: 07/07/21          #
######################################################

# 1. read in file, format and potentially clean ######
params <- read.csv("/home/stella/Desktop/ODE_MODEL_OUTPUT1params.csv", header = FALSE, sep = ",", dec = ".")
#Q: how will that read in work on tinaroo? whats the location or WD?
colnames(params) <- c("ID", "Aalpha", "Abeta", "Balpha", "Bbeta")

# 2. calculate ODE values ###########################





# 3. save that into MULTIPLE singleton files ########
