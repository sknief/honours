# Null Model Version Control #

Compiled here are notes on the different models found above. Included are descriptions, features, noted bugs and log entires of the progress made/staus of these models.

----

Version | Description | Build Status
------------- | ------------- | -------------
V1 | Stabilising Selection Only| ***Presumed Functioning, Needs Testing***
V2 | Burn-In, then Directional Selection | ***Presumed Functioning, Needs Testing***
WhackyNonWFVersion | a nonWF version with spatial selection & mating. Based on V1 | ***Regretted***

----

## Notes on the Different Models ##
### Null Model V1 ###

*22/06/2021* - The simulation reliably raises the Mean B Concentration to the inputed B Optimum Concentraion; this usually occurs after the first 100 generations, then the phenotype remains table ---> evidence of successful stabilising selection at work! The only suspicious behaviour are the random and sudden very strong mutations, which have led to early termination of the simulation as all individuals had a negative fitness value. I am not sure if this is a bug or in line with the expected behaviour of a model like this.

Also, The code works both with `m1.convertToSubstitution = T;` and `m1.convertToSubstitution = F;` - only difference is the fitness population graph that SLiMgui produces (which only works with `m1.convertToSubstitution = T;`).

Fitness is derived from AConc (and therefore its components) and Balpha and Bbeta. Ahillcoeff is NOT included in this as it is directly implicit in the ODE approach and doesnt make sense in a reduced "null" version. The code for it is included regardless.

 <details>
   <summary>Possible Extensions</summary>
   <p> * A Concentration Live Graph Code</p>
   <p> * Write code for independent fitness graph so it can be exported easier?</p>
  </details>

### Null Model V2 ###
*22/06/2021* - Added a burn-in section, which appears to work? Need to get more information on how other models handle burn-in; quasi-functional for now though.
