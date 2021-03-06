
ods html newfile=proc;

%let root     = C:\Users\psioda\Documents\GitHub\BIOS-767-Programming;
%let dataPath = &root.\data\basics; 
%let outPath  = &root.\output\basics;

libname basics "&dataPath.";

/*** Transform data using DATA Step + ARRAYS ***/

	data work.dental2;
	 set basics.dental;

		array dist[4] age8 age10 age12 age14;

		do i = 1 to 4;
			time     = 6 + 2*i;
			distance = dist[i];
			output;
		end;

		drop age: i;
	run;



/*** Basic Linear Regression ***/
	ods html select CovParms FitStatistics SolutionF;
	proc mixed data = work.dental2;
		class gender(ref='F');
		model distance = gender time gender*time / solution;
	run;

		/*
		ods html select ParameterEstimates;
		proc glm data = work.dental2;
			class gender(ref='F');
			model distance = gender time gender*time / solution;
		run;
		quit;
		*/


  /*** General Linear Model ***/
	ods html close;
	ods html newfile=none;

	ods html select CovParms FitStatistics SolutionF r ;
	proc mixed data = work.dental2;
		class gender(ref='F');
		model distance = gender time gender*time / solution;
		repeated  / subject=id type=un r=(1);
	run;

	data work.right;
	 set work.dental2;
	 	call streaminit(1);
	 	u = rand('uniform');

		cTime = put(time,z4.);
	run; 
	proc sort data = work.right; 
		by ID u;
	run;

	ods html select CovParms FitStatistics SolutionF r ;
	proc mixed data = work.right;
		class gender(ref='F') cTime;
		model distance = gender time gender*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;













	/*** Make a simple plot / take 1 ***/
	ods html select none;
	ods output SolutionF = work.ParmEst;
	proc mixed data = work.right;
		class gender(ref='F') cTime;
		model distance = gender time gender*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;
	ods html select all;

	data work.plotData;
		array parm[4] _temporary_ (17.4254 -1.5831 0.4764 0.3504);
		do Gender = 'F','M';
			do age    = 8 to 14 by 0.01;
			 	mDistance = parm[1] + parm[2]*(Gender='M') + parm[3]*age + parm[4]*age*(Gender='M');
				output work.plotData;
			end;
		end;
	run;

	proc sgplot data = work.plotData;
	 series x=age y=mDistance / group=gender;
	run;



















 	/*** Make a simple plot / take 2***/
	ods html select none;
	proc mixed data = work.right;
		class gender(ref='F') cTime;
		model distance = gender time gender*time / solution outpm=work.plotData2;
		repeated cTime / subject=id type=un r=(1);
	run;
	ods html select all;

	proc sort data = work.plotData2 nodupkey;
 		by gender time;
	run; 

	proc sgplot data = work.plotData2;
	 series x=time y=pred / group=gender markers;
	run;
















	%macro est;
	    %do time = 80 %to 140 %by 1;
			%let t = %sysevalf(&time./10);
			estimate "Male - &t."   gender 0 1  gender*time  0 &t. /*time*time*GENDER 0 %sysevalf(&t.**2)*/ / cl;
			estimate "Female - &t." gender 1 0  gender*time &t. 0  /*time*time*GENDER %sysevalf(&t.**2) 0*/  / cl;
		%end;
	%mend;



 	/*** Make a simple plot / take 3***/
	ods html select none;
	ods output Estimates = work.PlotData3;
	proc mixed data = work.right;
		class gender cTime;
		model distance = gender gender*time /*gender*time*time*/ / noint solution;
		repeated cTime / subject=id type=un r=(1);
		%est;
	run;
	ods html select all;

	data work.PlotData3;
	 set work.PlotData3;
      Gender = strip(scan(label,1,'-'));
	  age    = input(strip(scan(label,2,'-')),best.);
	run;

	proc sgplot data = work.plotData3;
	 series x=age y=estimate / group=gender;
	 band x=age lower=lower upper=upper / group=gender transparency=0.5;
	run;











	/**** Hypothesis Testing ****/

	*ods html close;
	*ods html newfile=proc;
	*ods html newfile=none;

	/*** Method 1 -- Wald Type Test or F Test ***/

	proc mixed data = work.right;
		class gender(ref='F') cTime;
		model distance = gender gender*time gender*time*time / solution;
		repeated cTime / subject=id type=un r=(1);

		contrast "Test of Parallelism (Quadratic Trajectories)"
				gender*time 1 -1,
				gender*time*time 1 -1 / chisq e;
	run;
















	/*** Method 1 -- Manual LRT ***/
	title "Full Model";
	ods html select FitStatistics;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender gender*time gender*time*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;

	title "Reduced Model";
	ods html select FitStatistics ;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender time time*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;


	data LRT;
	 logLikeFull = -0.5*417.0;
	 logLikeRed  = -0.5*424.8;
	 lrt         = 2*(logLikeFull-logLikeRed);
	 pv          = sdf('chisq',lrt,2);
	run;

	title "Likelihood Ratio Test for Parallelism";
	proc print data = LRT noobs; run;




	/*** Method 2 -- More Automated LRT ***/
	ods html select none;
	ods output FitStatistics = work.FitFull;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender gender*time gender*time*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;

		ods output FitStatistics = work.FitReduced;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender time time*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;
	ods html select all;

	data LRT;
		merge 	FitFull(rename=(value=fValue))
		   		FitReduced(rename=(value=rValue));

		by descr;
	run;


	data LRT2;
		set LRT;
		where descr = '-2 Log Likelihood';

		 logLikeFull = -0.5*fValue;
		 logLikeRed  = -0.5*rValue;
		 lrt         = 2*(logLikeFull-logLikeRed);
		 pv          = sdf('chisq',lrt,2);

	 	drop fValue rValue;
	run;

	title "Likelihood Ratio Test for Parallelism";
	proc print data = LRT2 noobs; run;







	/*** Method 2 -- More Automated LRT (Reduced Model = Linear Trajectories; Full = Quadratic) ***/
	ods html select none;
	ods output FitStatistics = work.FitFull;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender gender*time gender*time*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;

	ods output FitStatistics = work.FitReduced;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender gender*time / solution;
		repeated cTime / subject=id type=un r=(1);
	run;
	ods html select all;

	data LRT;
		merge 	FitFull(rename=(value=fValue))
		   		FitReduced(rename=(value=rValue));

		by descr;
	run;


	data LRT2;
		set LRT;
		where descr = '-2 Log Likelihood';

		 logLikeFull = -0.5*fValue;
		 logLikeRed  = -0.5*rValue;
		 lrt         = 2*(logLikeFull-logLikeRed);
		 pv          = sdf('chisq',lrt,2);

	 	drop fValue rValue;
	run;

	title "Likelihood Ratio Test for Linear versus Quadratic Trajectories (Not Parallel)";
	proc print data = LRT2 noobs; run;













	/*** Profile Analysis ***/
	title;
	proc mixed data = work.right method=ML;
		class gender(ref='F') time(ref='8') cTime;
		model distance = gender*time / noint solution;
		repeated cTime / subject=id type=un r=(1);
		contrast "Test of Parallelism" 
            gender*time  -1  0  0  1  1  0  0  -1,
			gender*time   0 -1  0  1  0  1  0  -1,
			gender*time   0  0 -1  1  0  0  1  -1 / chisq e;
	run;



























	title "Reduced Model";
	ods html select FitStatistics ;
	proc mixed data = work.right method=ML;
		class gender(ref='F') cTime;
		model distance = gender time  / solution;
		repeated cTime / subject=id type=un r=(1);
	run;


	data LRT;
	 logLikeFull = -0.5*417.0;
	 logLikeRed  = -0.5*424.8;
	 lrt         = 2*(logLikeFull-logLikeRed);
	 pv          = sdf('chisq',lrt,2);
	run;

	title "Likelihood Ratio Test for Parallelism";
	proc print data = LRT noobs; run;
