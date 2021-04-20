*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Make Hospital-Specific Curve Plot;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       Midterm-2021-Hospital-Specific-Curves.sas                                   
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
%setup(Midterm-2021-Hospital-Specific-Curves,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);

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


proc mixed data = DNA method=reml;
 model y=Xc / solution cl outpm=marginal outp=hosp_specific ddfm=kr chisq;
 random intercept Xc / type=un subject=hospital s cl;
run;




ods html newfile=proc nogtitle;
ods graphics / height=4in width=6in noborder;
title "Overall and Hospital-Specific Marker by Risk Score Curves";
proc sgplot data = hosp_specific;
 series x=x y=pred /  group=hospital;
 scatter x=x y=y / group=hospital markerattrs=(size=6 symbol=diamondFilled);
 band x=x lower=lower upper=upper / group=hospital transparency=0.7;
run;

