*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Analysis of data from the Dental Study;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       dental-data-analysis-GLM-Spline.sas                                   
*  LANGUAGE:       SAS, VERSION 9.4                                  
*                                                                   
*  NAME:           Matthew Psioda                               
*  DATE COMPLETE:  2020-12-30                                           
*-------------------------------------------------------------------
*                                                                   
*  Modification History:       
*                                                                                                                         
*  NAME:                         << Insert Name of Primary Programmer >>                               
*  DATE COMPLETE:                << YYYY-MM-DD >>   
*  DESCRIPTION OF MODIFICATION:  << Please insert 2-3 sentences >>                                                               
********************************************************************;
%include "C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING\MACROS\SETUP.SAS";
%setup(DENTAL-DATA-ANALYSIS-GLM-Spline,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);

/******************************************************************************************/
/******************************************************************************************/
/******************************** Dataset Processing Code *********************************/
data dental;
	set dat2.dental;

	array age[4] age8 age10 age12 age14;
	do j = 1 to dim(age);
		time = 6 + 2*j;
		distance = age[j];
		output;
	end;
	
	drop age: j;
run;
proc sort data=dental;
 by id time;
run;


option papersize=("8.5in","11.0in") topmargin=0.1in rightmargin=0.1in leftmargin=0.1in bottommargin=0.1in;
ods noptitle; ods graphics / reset noborder;

/********************************************************************************************************/
/********************************************************************************************************/
/********************************************************************************************************/
/***************************************** Statistical Analysis -- Splines *********************************/

ods html path = "&outpath." file="Dental-General-Linear-Model-Spline-Analysis1.html" nogtitle;
/* Analysis assumes independent observations */
title1 j=c "Analysis of Dental Study Data -- REML via GLIMMIX using Linear Splines";
proc glimmix data = dental method=RSPL;
	class gender(ref='F') id;
	effect tspline = spline(time/basis=bspline degree=1);
	model distance = gender tspline*gender / noint solution ;
	random _residual_ / subject=id type=un; 
	output out = curves pred=p lcl=lowerp ucl=upperp;
run;
quit;
ods html close;

proc sort data=curves nodupkey;
 by gender time;
run;

data curves_jitter;
 set curves;
  if gender = 'F' then time = time-0.1;
  else if gender = 'M' then time =time + 0.1;
run;

proc format;
 value $ gend
  'F' = 'Female'
  'M' = 'Male';
run;
option papersize=("6.2in","4.2in") topmargin=0.1in rightmargin=0.1in leftmargin=0.1in bottommargin=0.1in;
ods graphics / height=4in width=6in;
title;
ods pdf file = "&outpath.&slash.Dental-General-Linear-Model-Spline-Analysis1-Graphic.pdf" nogtitle;
 proc sgplot data = curves_jitter;
  series x=time y=p / group=gender lineattrs=(thickness=2);
  highlow x=time high=upperp low=lowerp / group=gender highcap=serif lowcap=serif lineattrs=(thickness=2);
  yaxis label="Mean Distance";
  xaxis label='Age (years)';
  format gender $gend.;
  label gender = 'Gender';
 run;
ods pdf close;
