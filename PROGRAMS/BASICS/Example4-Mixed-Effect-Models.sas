ods html close;
ods html newfile=none;



/*** Define macro variables ***/
%let root     = C:\Users\psioda\Documents\GitHub\BIOS-767-Programming;
%let dataPath = &root.\data\basics; 
%let outPath  = &root.\output\basics;

/*** Create SAS libref (i.e. alias for path to folder on computer ***/
libname basics "&dataPath.";


/*** process dental data ***/
data dental;
	set basics.dental;

	array age[4] age8 age10 age12 age14;
	do j = 1 to dim(age);
		time     = 6 + 2*j;
		timeSP1  = (time-10)*(time>10);
		distance = age[j];
		output;
	end;
	
	drop age: j;
run;

proc sort data=dental;
 by id time;
run;


ods html close;
ods html newfile=none;
/*** simple analysis with random effects modeling ***/
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time / noint;
 random intercept time / subject = id; 
run;




ods html close;
ods html newfile=none;
/*** Denominator degrees of freedom ***/
/*
data dental_mod;
 set dental;
 call streaminit(1);
  miss = rand('bernoulli',0.1);
  if miss=1 then delete;
run;
*/

title "DDFM=Default (Containment)";
ods html select Tests3 SolutionF;
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time / noint solution;
 random intercept time / subject = id; 
run;

title "DDFM=Default (Satterthwaite)";
ods html select Tests3 SolutionF;
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time / ddfm=satterth noint solution;
 random intercept time / subject = id; 
run;
title;

title "DDFM=Default (KR)";
ods html select Tests3 SolutionF;
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time / ddfm=kr noint solution;
 random intercept time / subject = id; 
run;

title "DDFM=Default (KR Improved)";
ods html select Tests3 SolutionF;
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time / ddfm=kr2 noint solution;
 random intercept time / subject = id; 
run;

/*** Non-positive definite G matrix ***/
proc mixed data = dental method = reml;
 class gender id;
 model distance = gender gender*time gender*time*time / noint ;
 random intercept time time*time/ subject = id; 
run;




/*** process dental data ***/
data cebu;
	set basics.cebu;
	where weight>.;
 	weight=weight/1000;

       if momht < -2.700 then mhc = 1;
  else if momht <  0.800 then mhc = 2;
  else if momht <  4.200 then mhc = 3;
  else 						  mhc = 4;

  age2 = (age-2)*(age>=2);
  age6 = (age-6)*(age>=6);

  drop momht;
run;

proc sort data=cebu;
 by id age;
run;


/*** Making Predictions from a random effects model ***/
proc mixed data = cebu/*(obs=5000)*/ method = ml noclprint plots=none;
 class mhc id;
 model weight = mhc mhc*age mhc*age2 mhc*age6 / noint solution outpm=estMean outpred=estPred cl;
 random intercept age age2 age6 / subject=id type=un v vcorr g gcorr;
run;

proc sort data = estMean nodupkey;
 by mhc age;
run;


proc sort data = estPred;
 by mhc id age;
run;

/*** random select a subset of children ***/
proc sort data =estPred out = ID(keep=ID mhc) nodupkey;
 by mhc id;
run; 

proc surveyselect data = ID method=srs n=30 out=selected_IDs noprint;
 strata mhc;
run;

data estPred2;
 merge estPred(in=a) selected_IDs(in=b);
 by mhc id;
 	if (a=1 and b=1);
run;



data comb;
 set estMean(in=a) 
     estPred2;
 if a then y2 = pred;
 else y1      = pred;
run;

ods graphics / height=4in width=10in;
proc sgpanel data = comb noautolegend;
  panelby mhc / rows=1 onepanel;
  series x=age y=y1 / group=id lineattrs=(color=lightblue);
  series x=age y=y2 / lineattrs=(color=black thickness=2 pattern=1);
  colaxis grid label='Age (months)';
  rowaxis grid label='Weight (kgs)';
  label mhc = 'Maternal Height Category';
run;




/*** testing random effects ***/
ods html close;
ods html newfile=none;

ods html select FitStatistics;
proc mixed data = cebu/*(obs=5000)*/ method = ml noclprint plots=none;
 class mhc id;
 model weight = mhc mhc*age mhc*age2 mhc*age6 / noint;
 random intercept age age2 age6 / subject=id type=un;
run;

ods html select FitStatistics;
proc mixed data = cebu/*(obs=5000)*/ method = ml noclprint plots=none;
 class mhc id;
 model weight = mhc mhc*age mhc*age2 mhc*age6 / noint;
 random intercept / subject=id type=un;
run;




/*** testing random effects ***/
ods html close;
ods html newfile=none;

ods html select Tests3 Contrasts /*SolutionF*/;
proc mixed data = cebu(obs=5000) method = ml noclprint plots=none;
 class mhc id;
 model weight = mhc mhc*age mhc*age2 mhc*age6 / noint solution;
 random intercept age age2 age6 / subject=id type=un;
 contrast "Parallelism" 
 			mhc*age  1 -1  0  0,
			mhc*age  1  0 -1  0,
			mhc*age  1  0  0 -1,

			mhc*age2 1 -1  0  0,
			mhc*age2 1  0 -1  0,
			mhc*age2 1  0  0 -1,

			mhc*age6 1 -1  0  0,
			mhc*age6 1  0 -1  0,
			mhc*age6 1  0  0 -1;


run;

/*** parameterization ***/
ods html select Tests3 Contrasts /*SolutionF*/;
proc mixed data = cebu(obs=5000) method = ml noclprint plots=none;
 class mhc(ref='4') id;
 model weight = mhc age age2 age6 mhc*age mhc*age2 mhc*age6 /  solution;
 random intercept age age2 age6 / subject=id type=un;
 contrast "Parallelism" 
 			mhc*age  1  0  0  -1,
			mhc*age  0  1  0  -1,
			mhc*age  0  0  1  -1,

			mhc*age2 1  0  0  -1,
			mhc*age2 0  1  0  -1,
			mhc*age2 0  0  1  -1,

			mhc*age6 1  0  0  -1,
			mhc*age6 0  1  0  -1,
			mhc*age6 0  0  1  -1;
run;
