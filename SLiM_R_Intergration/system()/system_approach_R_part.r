y <- c(0.3, 0.5, 0.5, 0.6, 0.2, 0.5) #example set

#V1.0: easy simple code for within SliM
y <- as.data.frame(y)
y$ID <- 1:lengths(y) #might have to be swapped with "size(y)
y$value <- (y$y) + 0.5 #example for transforming value, ie adding to ini value
z <- y$value
write.table(y, file = "calc.txt", sep = "\t", dec = ".",
            row.names = FALSE, col.names = TRUE)
#or
write.table(z, file = "calc2.txt", sep = "\t", dec = ".",
            row.names = FALSE, col.names = TRUE)
write.table(y, file = "calc.txt", sep = "\t", dec = ".",
            row.names = FALSE, col.names = TRUE)

#i think my file name needs to be defined as a constant in the simulation earlier and then I can call it back? similar to PNG path
