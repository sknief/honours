# for add
# 		
#GeneATotal = GeneA1 - GeneA2
#BGamma = GeneB1 - GeneB2 + GeneATotal
#BConc = BGamma * deltaT

comboADD <- comboADD[1:4]
colnames(comboADD) <- c("GeneA2", "GeneA1", "GeneB2", "GeneB1")
attach(comboADD)

comboADD$BCONC = (GeneB1 - GeneB2 + GeneA1 - GeneA2) * 6
plot(comboADD$BCONC)

#... oh no