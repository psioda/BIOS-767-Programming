*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Make Forrest Plot;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       Midterm-2021-Forrest-Plot.sas                                   
*  LANGUAGE:       SAS, VERSION 9.4                                  
*                                                                   
*  NAME:           Matthew Psioda                               
*  DATE COMPLETE:  2021-04-19                                           
*-------------------------------------------------------------------
*                                                                   
*  Modification History:       
*                                                                                                                         
*  NAME:                         << Insert Name of Primary Programmer >>                               
*  DATE COMPLETE:                << YYYY-MM-DD >>   
*  DESCRIPTION OF MODIFICATION:  << Please insert 2-3 sentences >>                                                               
********************************************************************;
%include "C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING\MACROS\SETUP.SAS";
%setup(Midterm-2021-Forrest-Plot,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);


data DNA;
 infile "&datpath2.\..\..\99-MIDTERM\DATA\dnarepair.dat" firstobs=2;
 input Y X HOSPITAL;
 ID = _n_;
 label  X = "Molecular Marker Value"
        Y = "Risk Score";
run;

proc sql noprint;
 select mean(X) into :mX from DNA;
 select std(X) into  :sX from DNA;
quit;


data DNA;
 informat ID Hospital;
 set DNA;
  Xc = (X - &mX.)/&sX.;
  label Xc  = "Standardized Molecular Marker Value";
run;


%macro a;
	option mprint;
	%do i = 1 %to 10;
		estimate "&i." Xc 1 | Xc 1 / subject %do s = 1 %to %eval(&i-1); 0 %end; 1 cl;
	%end;
	option nomprint;
%mend;


ods output Estimates = work.Estimates;
proc mixed data = DNA method=reml;
 model y=Xc / solution cl;
 random intercept Xc / type=un subject=hospital s;
	%a;
	estimate "Overall" Xc 1;
run;


data work.Estimates;
 set work.Estimates;
  if label ='Overall' then plotGroup = 1;
  else plotGroup = 2;

  est = put(estimate,6.2)||' ('||strip(put(lower,6.2))||','||strip(put(upper,6.2))||')';
run;

ods html newfile=proc nogtitle;
ods graphics / height=6in width=6.5in noborder;
title "Overall and Hospital-Specific Marker Effects";
proc sgplot data = work.Estimates noautolegend;
 highlow y=label high=upper low=lower / group=plotGroup highcap=serif lowcap=serif lineattrs=(thickness=2);
 scatter y=label x=estimate / group=plotGroup markerattrs=(symbol=circleFilled);
 refline 18.1509 / axis=x lineattrs=(pattern=2);
 yaxistable est / label='Estimate /w 95% CI/PI';
 xaxis label = 'Marker Effect' values=(10 to 30 by 5);
 yaxis label = 'Hospital';
run;





