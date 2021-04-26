ods html close;
ods html newfile=none;


/** linear mixed model -- linear time -- linear age -- random intercept **/
data sim;
	call streaminit(1);
	do sub = 1 to 100;
		b = rand('normal',0,1);
		do time    = 1 to 5;
		    age = rand('normal',0,1);
			y   = rand('bernoulli',logistic(b + 0.2*time + 0.2*age + 0.6*age**2));
			output;
		end;
	end;
run;

ods html select RESIDUALPANEL ;
proc glimmix data = sim method=quad(qpoints=10) plots=residualpanel(conditional marginal) ;
 model y = time age;
 random intercept / subject=sub;
 output out = residuals  pred=cMean residual=rawResid pearson=PearsonResid student=StudentResid ;
run;


/** Plot of Mean Value by Studentized Residuals **/
proc sgplot data = residuals;
 loess x=cMean y=PearsonResid;
run;

/** Plot of Time Covariate by Studentized Residuals **/
proc sgplot data = residuals;
 loess x=time y=PearsonResid;
run;

/** Plot of age Covariate by Studentized Residuals **/
proc sgplot data = residuals;
 reg x=age y=PearsonResid / degree=2;
run;
