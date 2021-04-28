ods html close;
ods html newfile=none;


/** linear mixed model -- linear time -- linear age -- random intercept **/
data sim;
	call streaminit(1);
	do sub = 1 to 200;
		b = rand('normal',0,0.2);
		age = rand('normal',0,1);
		n=1;
		do time    = 1 to 5;
			y   = rand('binomial',logistic(b + 0.2*time + 0.2*age /*+ 0.6*age**2*/),n);
			output;
		end;
	end;
run;

ods html select RESIDUALPANEL;
proc glimmix data = sim method=quad(qpoints=10) plots=residualpanel(conditional marginal) ;
 model y/n = time age / dist=bin;
 random intercept / subject=sub;
 output out = residuals  STUDENT(noblup);
run;

/** Plot of age Covariate by Studentized Residuals **/
proc sgplot data = residuals;
 reg x=age y=PearsonResid / degree=2;
run;
