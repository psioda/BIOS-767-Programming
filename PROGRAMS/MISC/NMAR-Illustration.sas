

data NMAR;
 call streaminit(1231);
 do sim = 1 to 2000000;
   y     = rand('normal',0,1);
   yTrue = y;
   if rand('bernoulli',logistic(-1 + 1.5*y))=1 then y = .;
   output;
 end;
run;

proc sgplot data = NMAR;
 histogram y     / nbins=100 transparency=0.5 fillattrs=(color=red) nooutline;
 histogram yTrue / nbins=100 transparency=0.5 fillattrs=(color=blue) nooutline;
 label y = 'Observed Data' yTrue='Complete Data';
 xaxis values=(-4 to 4 by 1) label='Outcome';
run;


