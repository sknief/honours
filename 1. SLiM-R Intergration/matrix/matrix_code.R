######################################################
#           R CODE FOR MY MATRIX APPROACH            #
#    Author: SMS Knief       Date: 28/05/21          #
######################################################

#install.packages("dplyr")
library(dplyr)


#### Section 1: Code to generate barcode matrix  ####
x <- c(0,1)
BM <- expand.grid(list(x)[rep(1, 5)]) #where 5 is the number of columns needed

#here I am using only 5 because I am assigning once loci to each parameter
#for some reason it does not like going above 10 columns reliably, maybe
#i just have to do three BM matrices and then combine them for a big "node"
#matrix? but thats an issue for the future



#### Section 2: Code to generate mutation matrix ####
M <- BM #copy the barcode matrix
y <- length(which(M == 1)) #check the number of values to be replaced
draw <- rnorm(y, mean = 0, sd =1) #generate the matching normal distrib values
BM[BM == 1] <- draw #replace 1 with draw values

#time to clean up the BM (this will have be done manually depending on your set-up)
BM <- rename(BM, Aalpha = Var1, Abeta = Var2, Ahill = Var3, Balpha = Var4, Bbeta = Var5)


#### Section 3: Code to calculate parameter values ####


#if there is more than one bp per loci, then use and modify this code (run per node X)
XalphaSum <- cumsum(BM$Xalpha1 + BM$Xalpha2)
XbetaSum <- cumsum(BM$beta1 + BM$Xbeta2)
XhillSum <- cumsum(BM$hill1 + BM$hill2)
#then once you have all nodes:
SumBM <- c(XalphaSum, XbetaSum, XhillSum)
#which gives you a dataframe that has the total additive effect sizes per loci




dZ <- bZ * (t > Xstart && t <= Xstop) * 1/(1 + Z^Hilln) - aZ*Z
dZnoFB <- aZ * (t > Xstart && t <= Xstop) - aZ*ZnoFB
