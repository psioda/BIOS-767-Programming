ods html newfile=proc;



/*** Define macro variables ***/
%let root     = C:\Users\psioda\Documents\GitHub\BIOS-767-Programming;
%let dataPath = &root.\data\basics; 
%let outPath  = &root.\output\basics;

/*** Create SAS libref (i.e. alias for path to folder on computer ***/
libname basics "&dataPath.";

/*** print macro variable values to SAS log ***/
%put &outPath.;
%put outPath=&outPath.;
%put &=outPath.;








/**** Define a simple macro to print output ****/
%macro A;
	proc print data=basics.dental(&dsOptions.) &printOptions.;
		var &variables.;
	run;
%mend A;

%macro B(dsOptions,printOptions,variables);
	proc print data=basics.dental(&dsOptions.) &printOptions.;
		var &variables.;
	run;
%mend B;

%macro C(dsOptions=NONE,printOptions=NONE,variables=ALL);
	proc print data=basics.dental
           %if &dsOptions. ^= NONE %then %do;(&dsOptions.)%end;
		   %if &printOptions. ^= NONE %then %do; &printOptions.%end;
		   ;
		%if &variables. ^= ALL %then %do; var &variables.; %end;
	run;
%mend C;

/** example using SAS macro options **/
option mprint nomfile nomlogic nosymbolgen;

filename mprint "&outpath.\generated-macro-C-code.sas";
filename mprint clear;

%c;

/*** example using non-positional parameters ***/
%c(variables=ID Gender age8,dsOptions=obs=10);

/*** example with positional parameters ***/
%b(%str(obs=10),noobs,_all_);

/*** example with no macro parameter ***/

%let dsOptions    = obs=5 drop=age:;
%let printOptions = noobs label;
%let variables    = _all_;
%a;




/*** macro to generate estimate statements ***/
data dental;
	set basics.dental;

	array age[4] age8 age10 age12 age14;
	do j = 1 to dim(age);
		time = 6 + 2*j;
		cTime = put(time,z3.);
		distance = age[j];
		output;
	end;
	
	drop age: j;
run;

proc sort data=dental;
 by id time;
run;


%macro est;
 %do s = 1 %to 11;
	%do i = 80 %to 140 %by 1;
		%let i2 = %sysevalf(&i./10);
 		estimate "&s. - F -  &i2."    gender 1 0 time*gender &i2. 0 | intercept 1 time &i2. / subject  %do j = 1 %to %eval(&s.-1); 0 %end; 1 cl;
	%end;
 %end;
 %do s = 12 %to 27;
	%do i = 80 %to 140 %by 1;
		%let i2 = %sysevalf(&i./10);
 		estimate "&s. - M - &i2."    gender 0 1 time*gender 0 &i2. | intercept 1 time &i2. / subject %do j = 1 %to %eval(&s.-1); 0 %end; 1 cl;
	%end;
 %end;

	%do i = 80 %to 140 %by 1;
		%let i2 = %sysevalf(&i./10);
	 	estimate "99 - F -  &i2."    gender 1 0 time*gender &i2. 0  /  cl;
		estimate "99 - M -  &i2."    gender 0 1 time*gender  0 &i2. /  cl;
	%end;
%mend;



/*** complex example using macros ***/
option ls=150;
option mprint mfile;
filename mprint "C:\Users\psioda\Desktop\temp\test.text";

ods html select none;
ods output Estimates = work.est;
proc mixed data = dental method=reml noclprint;
 class gender;
 model distance  = gender time*gender / noint;
 random intercept time / subject=id type=un;
	%est;
run;
ods html select all;


data work.est2;
 set work.est;
  subject = scan(label,1,'-');
  gender  = scan(label,2,'-');
  time    = input(scan(label,3,'-'),best.);

  if subject = 99 then y2 = estimate;
  else if subject ^= 99 then y1 = estimate;
run;

proc sgpanel data = work.est2 noautolegend;
 panelby gender / rows=1 onepanel;
 series x=time y=y1 / group=subject;
 series x=time y=y2 / lineattrs=(thickness=2 color=black);
 colaxis grid;
 rowaxis grid;
run;
