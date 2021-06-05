#The Negative Autoregulation Motif #

## Overview ###

The negative autoregulation motif (NAR) is the simplest motif structure that exists within Pygmalion. It consists of only one node, node A, that is connected to one node of the following motif, node B. Whilst this motif is characterized by only one node, the succeeding node is included in this model as to demonstrate the effect of changes in node A and how these cascade through succeeding nodes. Node A is activated by a signal, here shown as signal X.

![NAR motif diagram](https://github.com/sknief/honours/blob/master/NAR/NAR.png)

In this model, it will be assumed that the activation signal (node X) is an environmental input such as the length of the observed photoperiod, and that node A represents a transcription factor (TF) that directly causes flowering in a hypothetical plant. The start of the activation signal (Xstart) will be a variable to be set before the simulation begins and the end point of that signal (Xstop) will be handled as a constant. The observed phenotype is here defined as the amount of protein B produced within a set time period.

This is the first out of four motif models to be developed this year, and the NAR is the perfect place to start developing the foundations that all in silico models operate under. These foundations include the generation of mutations, the translation of genotype to motif dynamics and the way in which motif dynamics determine the observed phenotype. T

## The Model Workflow ##

![Model workflow diagram](https://github.com/sknief/honours/blob/master/NAR/Workflow2.png)

Within each generation, eight processes occur:
1.	Generation of mutations
2.	Motif parameter values are changed by the new mutations
3.	The motif dynamics are modelled in R using differential equations
4.	The integral of the motif dynamics is taken
5.	This “motif value” is translated into the phenotype
6.	This phenotype is subjected to selection
7.	Mortality occurs
8.	New offspring is generated

This cycle then begins anew.

Ultimately, I will create two versions of this model, one with the NAR motif ODE functions and one that operates on a purely additive genetic architecture, which then serves as the null model (i.e. control model). The null model is also an ideal way to test that all underlying genetic principles operate as they should. For the ODE models, I will rely on lateral integration with R (see my [SLiM/R Integration works](https://github.com/sknief/honours/tree/master/SLiM_R_Intergration)).
