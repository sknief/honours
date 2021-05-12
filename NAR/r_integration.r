library(slimr)


#Version as of 12/05/21
slim_script(
  slim_block(
    initialize(), {

      #section A: constants
      #defineConstant("K", value); #comment
      #for the mutations
      defineConstant("DelRatio", 0.40); #proportion of deleterious mutations
      defineConstant("BenRatio", 0.10); #proportion of beneficial mutations
      defineConstant("NeuRatio", 0.5); #proportion of neutral mutations
      #for the initial parameter values
      defineConstant("Abeta", 0.5); #values from Jans model
      defineConstant("Aalpha", 1); #see above
      defineConstant("Ahillcoeff", 1000); #see above
      defineConstant("Bbeta", 0.5); #see above
      defineConstant("Balpha", 1); #see above

      #Section AA: Recombination
      # do i need any recombination? i got the code in here just in case but hmm, up for discussion
      ends = c(6250, 6251, 10999);
      rates = c(1e-8, 0.5, 1e-8);
      initializeRecombinationRate(rates, ends);

      #section B: mutations
      initializeMutationRate(1e-7);
      #neutral
      initializeMutationType("m1", 0.5, "f", 0.0);
      m1.color = "yellow";
      m1.convertToSubstitution = T;
      #deleterious
      initializeMutationType("m2", 0.5, "g", -0.2, 0.2); #updated according to manual
      m2.convertToSubstitution = T;
      m2.color = "red";
      #beneficial
      initializeMutationType("m3", 0.5, "e", 0.2); #see page 137
      m3.convertToSubstitution = T;
      m3.color = "green";

      #section C: genomic elements
      initializeGenomicElementType("g1", m1, 1.0); #non-coding
      initializeGenomicElementType("g2", c(m1,m2,m3), c(NeuRatio, DelRatio, BenRatio)); #Abeta
      initializeGenomicElementType("g3", c(m1,m2,m3), c(NeuRatio, DelRatio, BenRatio)); #Aalpha
      initializeGenomicElementType("g4", c(m1,m2,m3), c(NeuRatio, DelRatio, BenRatio)); #Ahillcoeff
      initializeGenomicElementType("g5", c(m1,m2,m3), c(NeuRatio, DelRatio, BenRatio)); #Bbeta
      initializeGenomicElementType("g6", c(m1,m2,m3), c(NeuRatio, DelRatio, BenRatio)); #Balpha

      #section D: chromosome structure
      initializeGenomicElement(g1, 0, 1999);
      initializeGenomicElement(g2, 2000, 2999); #Abeta
      initializeGenomicElement(g1, 3000, 3499); #spacer
      initializeGenomicElement(g3, 3500, 4499); #Aalpha
      initializeGenomicElement(g1, 4500, 4999); #spacer
      initializeGenomicElement(g4, 5000, 5999); #Ahillcoeff
      initializeGenomicElement(g1, 6000, 6499); #spacer
      initializeGenomicElement(g5, 6500, 7499); #Bbeta
      initializeGenomicElement(g1, 7500, 7999); #spacer
      initializeGenomicElement(g6, 8000, 8999); #Balpha
      initializeGenomicElement(g1, 9000, 10999); #end spacer

      #section DD: colorcoding
      g1.color = "darkgrey";
      g2.color = "firebrick";
      g3.color = "firebrick";
      g4.color = "firebrick";
      g5.color = "tan3";
      g6.color = "tan3";

      #section E: advanced behaviour / mechanics

    }
    #initialize command bracket ends here
  ),

  slim_block(
    1, early(), {
      sim.addSubpop("p1", 2000);
    }
  ),

  slim_block(
    early(), {
      for (ind in sim%.%SLiMSim$subpopulations%.%Subpop$individuals) {

        #Node A, alpha value
        AAD = ind.sumOfMutationsOfType(m2);
        ind.setValue("aad", AAD);
        AAB = ind.sumOfMutationsOfType(m3);
        ind.setValue("aab", AAB);
        AAT = (Aalpha - AAD + AAB);
        ind.setValue("aat", AAT);

        #Node A, beta value
        ABD = ind.sumOfMutationsOfType(m2);
        ind.setValue("abd", ABD);
        ABB = ind.sumOfMutationsOfType(m3);
        ind.setValue("abb", ABB);
        ABT = (Abeta - ABD + ABB);
        ind.setValue("abt", ABT);

        #Node A, hill coeff
        AHD = ind.sumOfMutationsOfType(m2);
        ind.setValue("ahd", AHD);
        AHB = ind.sumOfMutationsOfType(m3);
        ind.setValue("ahb", AHB);
        AHT = (Ahillcoeff - AHD + AHB);
        ind.setValue("aht", AHT);

        #Node B, alpha value
        BAD = ind.sumOfMutationsOfType(m2);
        ind.setValue("bad", BAD);
        BAB = ind.sumOfMutationsOfType(m3);
        ind.setValue("bab", BAB);
        BAT = (Balpha - BAD + BAB);
        ind.setValue("bat", BAT);


        #Node B, beta value
        BBD = ind.sumOfMutationsOfType(m2);
        ind.setValue("bbd", BBD);
        BBB = ind.sumOfMutationsOfType(m3);
        ind.setValue("bbb", BBB);
        BBT = (Bbeta - BBD + BBB);
        ind.setValue("bbt", BBT);

      }
    }
  ),

  slim_block(
    late(), {

      if (sim%.%SLiMSim$generation <= 1000) return;

      inds = sim%.%SLiMSim$subpopulations%.%Subpop$individuals;
      #Node A, alpha values
      test1 = mean(inds.getValue("aad"));
      test2 = mean(inds.getValue("aab"));
      test3 = mean(inds.getValue("aat"));

      #Node A, beta values
      test4 = mean(inds.getValue("abd"));
      test5 = mean(inds.getValue("abb"));
      test6 = mean(inds.getValue("abt"));

      #Node A, hill coeff values
      test7 = mean(inds.getValue("ahd"));
      test8 = mean(inds.getValue("ahb"));
      test9 = mean(inds.getValue("aht"));

      #Node B, alpha values
      test10 = mean(inds.getValue("bad"));
      test11 = mean(inds.getValue("bab"));
      test12 = mean(inds.getValue("bat"));

      #Node B, beta values
      test13 = mean(inds.getValue("bbd"));
      test14 = mean(inds.getValue("bbb"));
      test15 = mean(inds.getValue("bbt"));

      catn();
      catn("Node A, Alpha:");
      catn("Mean AAD equals" + test1);
      catn("Mean AAB equals" + test2);
      catn("Mean AAT equals" + test3);
      catn();
      catn("Node A, Beta:");
      catn("Mean ABD equals" + test4);
      catn("Mean ABB equals" + test5);
      catn("Mean ABT equals" + test6);
      catn();
      catn("Node A, Hill Coeff:");
      catn("Mean AHD equals" + test7);
      catn("Mean AHB equals" + test8);
      catn("Mean AHT equals" + test9);
      catn();
      catn("Node B, Alpha:");
      catn("Mean BAD equals" + test10);
      catn("Mean BAB equals" + test11);
      catn("Mean BAT equals" + test12);
      catn();
      catn("Node B, Beta:");
      catn("Mean BBD equals" + test13);
      catn("Mean BBB equals" + test14);
      catn("Mean BBT equals" + test15);
      catn();
      catn("100 GENERATIONs HAVE PASSED!!");
      catn("SO MUCH OUTPUT AAAAAAAAAAAA");
      catn();
      catn();
    }
  ),

  slim_block(
    20000, late(), {
      sim.outputFull();
    }
  ),
) -> script_test


#### Print The Script to check for errors

script_test
