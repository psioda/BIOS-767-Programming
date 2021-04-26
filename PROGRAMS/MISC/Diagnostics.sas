ods html close;
ods html newfile=none;


/** linear mixed model -- linear time -- linear age -- random intercept **/
data sim;
	call streaminit(1);
	do sub = 1 to 100;
		b = rand('normal',0,8);
		do time    = 1 to 5;
		    age = rand('normal',0,1);
			y   = rand('normal',b+ 100 + 5*time + 5*age,20);
			output;
		end;
	end;
run;

ods html select VCIRYPanel StudentPanel ;
proc mixed data = sim method=reml plots=(all);
 model y = time age / vciry residual outpm=predMean outp=eBlup;
 random intercept / subject=sub;
run;

/** Plot of Mean Value by Studentized Residuals **/
proc sgplot data = predMean;
 loess x=pred y=StudentResid;
run;

/** Plot of Predicted Value by Studentized Residuals **/
proc sgplot data = eBlup;
 loess x=pred y=StudentResid;
run;

/** Plot of Time Covariate by Studentized Residuals **/
proc sgplot data = predMean;
 loess x=time y=StudentResid;
run;

/** Plot of age Covariate by Studentized Residuals **/
proc sgplot data = eBlup;
 loess x=age y=StudentResid;
run;
