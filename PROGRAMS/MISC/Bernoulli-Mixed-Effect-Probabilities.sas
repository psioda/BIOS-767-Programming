ods html close;
ods html newfile=none;

/**** Monte Carlo Integration ***/
data MonteCarlo;
 call streaminit(1);

 array pi[2] pi0 pi1 (0 0);
 do i = 1 to 1e7;
  b  = rand('normal',0,sqrt(2));
  pi[1] + logistic(-2 + b);
  pi[2] + logistic(-2 + 0.4 + b);
 end;
 pi[1] = pi[1] / 1e7;
 pi[2] = pi[2] / 1e7;

 format pi: 6.3;
 drop i b;
run; 
proc print data = MonteCarlo noobs; run;

/*** Numerical Integration ***/
/*** SAS R-like procedure (can call R in fact) ***/
proc IML;
	start pi(b) global(beta0,beta1,trt);
		return logistic(beta0+beta1*trt+b)*pdf('normal',b,0,sqrt(2));
	finish;

	beta0 = -2.0; beta1 = 0.4;

	trt=0; call quad(pi0,'pi',.M||.P);
	trt=1; call quad(pi1,'pi',.M||.P);
	print pi0[format=6.3] pi1[format=6.3];
quit;


