# Additive Model Version Control #

Compiled here are notes on the different models found above. Included are descriptions, features, noted bugs and log entires of the progress made/staus of these models.

----

Version | Description | Build Status
------------- | ------------- | -------------
V1.0 | Stabilising Selection Only| ***Needs Bug Fixing***
V1.1 | Modified copy of V1.0, during meeting with Daniel | ***Retired, Used as Reference***
V2.0 | Burn-In, then Directional Selection | ***Presumed Functioning, Needs Testing***
WhackyNonWFVersion | a nonWF version with spatial selection & mating. Based on V1 | ***Regretted***

----

## Notes on the Different Models ##
### Additive Model V1.0 ###

*22/06/2021* - The simulation reliably raises the Mean B Concentration to the inputed B Optimum Concentraion; this usually occurs after the first 100 generations, then the phenotype remains table ---> evidence of successful stabilising selection at work! The only suspicious behaviour are the random and sudden very strong mutations, which have led to early termination of the simulation as all individuals had a negative fitness value. I am not sure if this is a bug or in line with the expected behaviour of a model like this.

Also, The code works both with `m1.convertToSubstitution = T;` and `m1.convertToSubstitution = F;` - only difference is the fitness population graph that SLiMgui produces (which only works with `m1.convertToSubstitution = T;`).

Fitness is derived from AConc (and therefore its components) and Balpha and Bbeta. Ahillcoeff is NOT included in this as it is directly implicit in the ODE approach and doesnt make sense in a reduced "null" version. The code for it is included regardless.

 <details>
   <summary>Possible Extensions</summary>
   <p> * A Concentration Live Graph Code</p>
   <p> * Write code for independent fitness graph so it can be exported easier?</p>
  </details>


### Additive Model V1.1 ###

*27/06/2021* - Modification of V1.0 that I worked on during a meeting with Daniel (Supervisor); ended up with exponential mutation samples and changed fitness functions - not functioning though; kept just as a reference and for historic reasons.

### Additive Model V1.2 ###

*28/06/2021* - Modification of V1.0 with bug fixes and additional plots; following e-mail correspondance with Daniel. The behaviour observed from the new plots lines up with the expected bahviour; A flucatuates around the initial value and [A] and [B] are not correlated.  

<details>
  <summary>Patch Notes</summary>
  <p> * Changed `Ahillcoeff` to `K`</p>
  <p> * Changed `K` colour block to lightblue</p>
  <p> * Additional Live Plot: [A]/t</p>
  <p> * Additional Live Plot: [A]/[B]</p>
 </details>


### Additive Model V1.3 ###

*28/06/2021* - Modification of V1.2 with new fitnessScaling statements - ATTEMPTED BUG FIX. Important info on the SLiM error message below (taken from [slim-discuss](https://groups.google.com/g/slim-discuss/c/06IeoXNo6F0/m/IBl9m6R9BgAJ))

> I ran this script under SLiMgui and got the "total fitness of all individuals is <= 0.0" error.  This seems to make sense; the behavior I saw was that the number of TE mutations was increasing without bound.  A quick check in R indicates that your fitness function, for the parameters a and b that you use, underflows to 0.0 when n equals 1575; the number becomes so small that it is indistinguishable from zero given the limited precision of floating-point numbers.  So when every individual has that many TE mutations, SLiM can no longer choose individuals to mate because every individual has a fitness of 0.

Now from the SLiM Manual:
>Note that these distributions can in principle produce selection coefficients smaller than -1.0. In that case, the mutations will be evaluated as “lethal” by SLiM, and the relative fitness of the individual will be set to 0.0. 

<details>
   <summary>Patch Notes</summary>
   <p> * Changed `Ahillcoeff` to `K`</p>
   <p> * Changed `K` colour block to lightblue</p>
   <p> * Additional Live Plot: [A]/t</p>
   <p> * Additional Live Plot: [A]/[B]</p>
</details>


### Additive Model V2.0 ###
*22/06/2021* - Added a burn-in section, which appears to work? Need to get more information on how other models handle burn-in; quasi-functional for now though.
