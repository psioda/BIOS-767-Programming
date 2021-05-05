
%let nSims     = 5000;
%let nSubjects = 104;
%let D         = {9 0,0 1};
%let s2e       = 25;
%let pi        = 0.5;
%let beta      = 0 0 
                 0 1;

%let seedIML = 124214;
%let seedDS  = 423321;

data _null_;
 
 alpha = 0.05;
 gamma = 0.10;

 Z1 = quantile('normal',1-alpha/2,0,1);
 z2 = quantile('normal',1-gamma,0,1);

 tSSE  = 17.5;
 s2B   = &s2e./tSSE + 1;
 delta = 1;
 pi    = &pi.;

 N = (Z1+Z2)**2*s2B/(pi*(1-pi)*delta**2);
 put N=;
run;

proc IML;
 call randseed(&seedIML.);

  M=&nSims.;
  N=&nSubjects.;

  D = &D.;
  b = randNormal(M*N,{0 0},D);

  sub = repeat(t(do(1,N,1)),M,1);
  dat = sub||b;

  create work.randEffects from dat[c={"id" "b0" "b1"}];
   append from dat;
  close work.randEffects;
quit;

proc print data = work.randEffects(obs=10) noobs; run;


data work.sim;
 set work.randEffects;
 call streaminit(&seedDS.);

  pi = &pi.;
  N  = &nSubjects.;
  se = sqrt(&s2e.);
  array beta[2,2] _temporary_ (&beta.);

  retain sim 0;
  if id = 1 then sim+1;

	trt = (id<=pi*N);
	do time = 0 to 5;
		y = rand('normal',(b0+beta[trt+1,1]) + (b1+beta[trt+1,2])*time,se);
		output;
	end;

	keep sim id trt y time;
run;

proc print data = work.sim(obs=20) noobs; run;

proc means data = sim;
 class trt time;
 var y;
run;

ods html exclude all;
ods output SolutionF = work.PE;
proc mixed data = sim method=reml;
 by sim;
 model y = trt time trt*time / solution;
 random intercept time / subject=id;
quit; 
ods html exclude none;

proc format;
 value pv
  Low-<0.05 = 'Reject Null'
  other    = 'Fail to Reject Null';
quit;

proc freq data = work.PE;
 where effect = 'trt*time';
 table Probt;
 format probt pv.;
run;


/***** NMAR Example *****/



data work.sim_missing;
 set work.randEffects;
  call streaminit(&seedDS.);

  pi = &pi.;
  N  = &nSubjects.;
  se = sqrt(&s2e.);
  array beta[2,2] _temporary_ (&beta.);

  retain sim 0;
  if id = 1 then sim+1;

	trt = (id<=pi*N);
	do time = 0 to 5;
		y     = rand('normal',(b0+beta[trt+1,1]) + (b1+beta[trt+1,2])*time,se);
		r     = rand('bernoull',logistic(2 - (y<-2.5) - (y<-5.0)));
		yComp = y;
		
		if r = 0 and time>0 then y = .;
		output;
	end;

	keep sim id trt y: r time;
run;


proc means data = sim_missing n nmiss mean;
 class trt time;
 var y;
run;

ods html exclude all;
ods output SolutionF = work.PE_missing;
proc mixed data = work.sim_missing method=reml;
 by sim;
 model y = trt time trt*time / solution;
 random intercept time / subject=id;
quit; 
ods html exclude none;

proc format;
 value pv
  Low-<0.05 = 'Reject Null'
  other    = 'Fail to Reject Null';
quit;

proc freq data = work.PE_missing;
 where effect = 'trt*time';
 table Probt;
 format probt pv.;
run;


proc means data = work.PE mean std;
 class effect;
 var estimate;
run;

proc means data = work.PE_missing mean std;
 class effect;
 var estimate;
run;
