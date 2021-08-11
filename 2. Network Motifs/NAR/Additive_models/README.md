# Additive Model Version Control #

Compiled here are notes on the different models found above. Included are descriptions, features, noted bugs and log entires of the progress made/staus of these models.

----

Version | Description | Build Status
------------- | ------------- | -------------
V1.0 | Stabilising Selection Only| ***Succeeded***
V1.1 | Modified copy of V1.0, during meeting with Daniel | ***Retired, Used as Reference***
V1.2 | Modified copy of V1.0, Enhancement (Plots + Genotypes) | ***Succeeded***
V1.3.0 | Successor to V1.2, Begin of Bug Fixing | ***Succeeded***
V1.3.1 | WIP Bug Fix, successor to V1.3.0  | ***Succeeded**
V2.0 | Initial Release! Functioning Model! | ***Passed Testing***
V2.1 | Alternative Version with only node A | ***Passed Testing***
V2.2 | Alternative Version with an intitial B Conc and A Conc | ***Succeeded***
V2.3 | Revised additive structure | ***CURRENT MODEL***
V3.0 | HPC Worthy Model | ***Work in Progress***
WhackyNonWFVersion | a nonWF version with spatial selection & mating. Based on V1.0 | ***Regretted***

Essentially: V1 = Barebone Coding, V2 = Functioning Models + Variations, V3 = HPC-appropriate versions of V2 models
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


### Additive Model V1.3.0 ###

*28/06/2021* - Modification of V1.2 with new fitnessScaling statements - ATTEMPTED BUG FIX. Important info on the SLiM error message below (taken from [slim-discuss](https://groups.google.com/g/slim-discuss/c/06IeoXNo6F0/m/IBl9m6R9BgAJ))

> I ran this script under SLiMgui and got the "total fitness of all individuals is <= 0.0" error.  This seems to make sense; the behavior I saw was that the number of TE mutations was increasing without bound.  A quick check in R indicates that your fitness function, for the parameters a and b that you use, underflows to 0.0 when n equals 1575; the number becomes so small that it is indistinguishable from zero given the limited precision of floating-point numbers.  So when every individual has that many TE mutations, SLiM can no longer choose individuals to mate because every individual has a fitness of 0.

Now from the SLiM Manual:
>Note that these distributions can in principle produce selection coefficients smaller than -1.0. In that case, the mutations will be evaluated as “lethal” by SLiM, and the relative fitness of the individual will be set to 0.0.

Lots of insight, little improvement.

<details>
   <summary>Patch Notes</summary>
   <p> * Added more `fitness` callbacks</p>
</details>

### Additive Model V1.3.1 ###

*29/06/2021* - Modification of V1.3.1 with attempted bug fixed: script based fitness to avoid sampling selection coefficients smaller than or equal to -1.0 (addressing the second blockquote above). This has not fixed it entirely, so reworking fitness callbacks still. If I cannot get it to work, I might text Ben again and move onto the ODE models.

<details>
   <summary>Patch Notes</summary>
   <p> * New `fitness(NULL)` callback to avoid fitnessScaling going -1</p>
   <p> * Script based fitness call that appears to function like the original code</p>
   <p> * Deleted old vestigial code</p>
</details>

*29/06/2021* Second update: I looked at all mutations of three seperate model runs before they crashed and evaluated the mutations - all of them had a bery large effect size positive mutation (>1) in an alpha region (which is responsible for the deletion of protein). You can see how an increase in Aalpha leads to a massive drop in AConc which then leads to a big drop in BConc and failure of the model.

![Aconc](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/bugfixlog3A.png)

![Bconc](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/bugfixlog3B.png)

The corresponding output log can be found [here](/home/stella/github/honours/NAR/Additive_models/BUG_FIX/Log3.txt).

This makes sense - so I need to bound the mutations from both sides to avoid freakishly large effect sizes. However, my script for that does not work, so I might actually e-mail Ben about this, cause I am at a loss of what to do.

<details>
   <summary>Patch Notes</summary>
   <p> * NEW Script based fitness call that should bound the range but does not</p>
</details>


*30/06/2021* After correspondance with Ben, I found why my coefficients weren't sampled properly...

>Hi Stella!
>OK, so first let's cover why the script-based MutationType you made didn't protect you the way you expected it to.  It is:
>if ((rnorm (1, 0, 0.5)) <=-1) return -0.1; else return (rnorm (1,0,0.5));
>So this draws a random deviate from a normal distribution, and if it's <= -1 it returns -0.1.  Otherwise, it draws a *new* random deviate from the same distribution, and returns that.  One issue here is that you compare the first draw to -1, but then you return -0.1; is that intentional?  I would think that if you wanted a lower bound of -1 you'd return -1, whereas if you wanted a lower bound of -0.1 you'd return -0.1.  But setting that aside, the big issue here is that the second random deviate could be anything; just because you checked for the lower bound on the *first* draw doesn't mean that the *second* draw won't be below the lower bound.  So, assuming you want to enforce a lower bound of -1, better logic would be:
>x = rnorm(1, 0, 0.5); if (x <= -1) return -1.0; else return x;
>That will clip the drawn number to a lower bound of -1.

The full correspondance is found on [slim-discuss](https://groups.google.com/g/slim-discuss/c/jqXEwgtJs0E).

After I fixed that, my code was still throwing the same error message, so the next thing I tried was using tags to change the bounds of AConc and BConc but that didn't work either. Digging deeper into the mutation output and the underlying genetics, I discovered that the likely cause of my error message is when the collective mutations drive the phenotype to *either* extreme, including too high. The fitness function I was working with effectively rendered all individuals as unfit if they start out too far removed from the optimum or end up there due to mutations changing the params driving the phenotype.

This observation was largely backed by the graphs produced by the simulations right before they crashed and the output logs (found [here](https://github.com/sknief/honours/tree/master/NAR/Additive_models/BUG_FIX)). Most notably, this one made me realize its a matter of the fitness function rather than just the mutations as they are sampled:

![too high](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/evidence%201.png)

I will attempt to fix all of that tomorrow.

<details>
   <summary>Patch Notes</summary>
   <p> * NEW NEW Script based fitness call that returns values between 1 and -1 </p>
   <p> * Better nested if-else loops and associated code cleaning</p>
</details>

*01/07/21*  So, there are two main components to fixing this:
1. Easing selection by adding a variable selection coefficient ("S") (this effectively widens the fitness distribution to allow more lenience in the population to attain the optimum)
2. Implementing a "failsafe" so that if the fitnessScaling callback returns a "0", it gets promoted to a 0.01 for the sake of that callback, and the affected individual gets manually removed using a tag-based lethal callback. The outcome remains the same, only SLiM does not throw a techincal error due to the fitnessScaling value being 0. I also realized that previous attempt at this silently failed.

Both work like a charm:
![fitness plot](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/evidence%202.pdf)

Models started running to completion now.

![Bconc](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/evidence3.png)

And they have survived the Bug Fix Testing check! The next version will the the "release" version of this model, i.e. cleaned-up and hopefully suitable for running on the HPC.

<details>
   <summary>Patch Notes</summary>
   <p> * fitness function is now `fitnessfunction = exp(-((BConc-BOpt)/S)^2);`</p>
   <p> * fitness(NULL) callback changed to targetting `ind.tag == 0` and `return 0.0`</p>
   <p> * changed `(fitnessfunction > 0)` to `(fitnessfunction == 0)` (game changer!!) </p>
</details>

### Additive Model V2.0 ###

***INITIAL RELEASE VERSION***

<details>
   <summary>Release Notes</summary>
   <p> * Code has been cleaned (vestigial code removed)</p>
   <p> * Survived 67 test runs without fail </p>
   <p> * Added useful annotations </p>
   <p> * Options to include extreme optimum models </p>
</details>

The only notable feature/aspect is the potential to expand the range of optima at the cost of a little biological realism (or when using a different framework, the underlying genetic principles remain the same even when not working with concentrations).

The code section responsible for this is:
```
// individuals tagged have fitnessScaling = 0, which will cause SLiM to throw a fit;
// give them either minimal fitness (0.1) to push them beyond extreme bounds, or
// give them lethal fitness (0), to make sure that anything beyond the fitness function counts as lethal
// biologically speaking i'd prefer lethal ftiness, but ask Jan which one is better
fitness(NULL) {
	if (individual.tag == 0)
		return 0.0;
	else
		return relFitness;
...

//fitnessScaling callback to avoid SLiM bug
if (fitnessfunction == 0) {
  ind.fitnessScaling = fitnessfunction + 0.1;
  print("WHOOPSIE");
  ind.tag = 0;
  }
else
  ind.fitnessScaling = fitnessfunction;
}

```

As it already says it in the code, the preset is that the callback returns 0.0, which eliminates the individual. This enacts the same level of selection as a fitnessScaling callback that equals 0 would without terminating the simulation.

It is possible to change the fitness callback so that it returns a fitness of 0.1, which results in highly likely but not certain death. In doing so, very distant optima can be achieved, but mean BConc is able to have "crashes" into a negative concentration (which makes little biological sense, but if it was a generic phenotype this would be acceptable, so its an issue with context here). [EDIT: Its a mean value so maybe that crash is driven by an outlier rather than representing the population; backed by quick bounce back.]

![Crash example](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/0.1%20example.png)

I personally believe the first option to be better suited for my models, but this option exists.

The next version (V3.0), will have new writeToFile functions and more general optimizations for the HPC - this should mark the last version of these models.

### Additive Model V2.1 ###

*11/07/21* Essentially Model V2.0 but I've removed Node B. Works just as well.

### Additive Model V2.2 ###

*11/07/21* Essentially Model V2.0 but I changed the AConc and BConc calculations, which has also lead to different parameter ranges:

The code from V2.0:

```
AConc = Abeta - Aalpha;
...
BConc = (Bbeta - Balpha)*AConc;  
```

is now:

```
AConc = (Abeta*AConcINI - Aalpha*AConcINI) + AConcINI;
...
BConc = (Bbeta*AConc - Balpha*BConcINI) + BConcINI;

```

Parameter ranges shift from V2.0:
```
defineConstant("BOpt", 200); //test value: 200
defineConstant("AbetaINI", 50); //test value: 50; some limits in terms of values this can take
defineConstant("AalphaINI", 20); //test value: 20
defineConstant("K", 10); //test value: 10, here neutral
defineConstant("BbetaINI", 15); //test value: 15
defineConstant("BalphaINI", 10); //test value: 10
```

to

```
defineConstant("AConcINI", 20);
defineConstant("BConcINI", 0);
defineConstant("BOpt", 200); //test value: 200
defineConstant("AbetaINI", 5); //test value: 50; some limits in terms of values this can take
defineConstant("AalphaINI", 2); //test value: 20
defineConstant("K", 10); //test value: 10, here neutral
defineConstant("BbetaINI", 8); //test value: 15
defineConstant("BalphaINI", 5); //test value: 10
defineConstant("S", 3); //selection coeff
```

I've done these changes in anticpation that my ODE model may need an AConcINI and BConcINI by the sheer nature of their formulae; better to prepare now than to have to come back and do this later. It runs well, but I'd have to retest the ranges.

I think it also makes more sense as alpha and beta are supposed to be production rates and removal rates, so smaller params check out (as does having an ini value).

Furthermore, this has given a nicer AConc Plot:

![AConc V2.0](https://github.com/sknief/honours/blob/master/NAR/Additive_models/ReadMe_Files/v2.2.png)


### Additive Model V2.3 ###

*24/07/21* After a meeting with Daniel and Jan changed the way the addtitive model operates so that the genes are now unnamed, the mutations are acquired from an exponential and it is a purely additive trait. Working model. 
