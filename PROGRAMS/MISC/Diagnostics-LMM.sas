ods html close;
ods html newfile=none;


/** linear mixed model -- linear time -- linear age -- random intercept **/
data sim;
	call streaminit(1);
	do sub = 1 to 200;
		b   = rand('normal',0,8);
		age = rand('normal',0,1);
		do time    = 1 to 5;
		    cTime = time;
			y     = rand('normal',b+ 100 + 5*time + 5*age + 3*age**2,10/*+1*time*/);
			output;
		end;
	end;
run;

ods html newfile=proc;
ods html exclude ResidualPanel ;
proc mixed data = sim method=reml plots=(all);
 class cTime;
 model y = time age / vciry residual outpm=predMean outp=eBlup;
 random intercept / subject=sub;
 *repeated cTime / subject=sub type=toeph(1);
run;

/** Plot of age Covariate by Studentized Residuals **/
proc sgplot data = predMean;
 reg x=age y=StudentResid / degree=2;
run;
