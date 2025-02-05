*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Analyze the Melanoma Data;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       melanoma-multilevel.sas                                   
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
%setup(MELANOMA-MULTILEVEL,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);

/*
Region, County, Observed number of deaths due to malignant melanoma, 
expected number of deaths due to malignant melanoma, UVB exposure.
region county nDeath UVB
*/

data melanoma;
 set dat2.melanoma;
  log_eDeaths = log(eDeaths);
run;

ods html newfile=proc;
proc glimmix data = melanoma method=quad(qpoints=50);
 model nDeaths = uvb / offset=log_eDeaths dist=poisson link=log solution;
 random int / subject=region;
run;





proc glimmix data = melanoma method=quad(qpoints=50);
 model nDeaths = uvb / offset=log_eDeaths dist=poisson solution;
 random int / subject=region;
 estimate "+1SD versus -1SD" uvb 3 / exp cl;
run;




ods output SolutionR = work.SolutionRandom;
proc glimmix data = melanoma method=quad(qpoints=50);
 model nDeaths = uvb / offset=log_eDeaths dist=poisson solution;
 random int / subject=region s cl;
run;


proc sort data = work.SolutionRandom;
 by estimate;
run;


ods graphics / height=6in width=4in noborder;
proc sgplot data = work.SolutionRandom noautolegend;
 highlow y=subject low=lower high=upper / highcap=serif lowcap=serif;
 scatter y=subject x=estimate           / markerattrs=(symbol=diamondFilled);
 refline 0                              / axis=x lineattrs=(pattern=2 color=black);

 yaxis type=discrete label='Region';
 xaxis label="Region Specific Random Effect";
run;

