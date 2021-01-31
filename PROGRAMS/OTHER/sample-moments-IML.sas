*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Compute sample moments for Dental Study data;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:      sample-moments-IML.sas                                   
*  LANGUAGE:       SAS, VERSION 9.4                                  
*                                                                   
*  NAME:           Matthew Psioda                               
*  DATE COMPLETE:  2020-1-26                                           
*-------------------------------------------------------------------
*                                                                   
*  Modification History:       
*                                                                                                                         
*  NAME:                         << Insert Name of Primary Programmer >>                               
*  DATE COMPLETE:                << YYYY-MM-DD >>   
*  DESCRIPTION OF MODIFICATION:  << Please insert 2-3 sentences >>                                                               
********************************************************************;
%include "C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING\MACROS\SETUP.SAS";
%setup(SAMPLE-MOMENTS-IML,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);

%let dentalPath = %sysfunc(tranwrd(&datPath2,OTHER,DENTAL));
libname data "&dentalPath.";

title "Sample Moments for the Dental Study Data";
ods html path="&outPath." file="sample-moments.html";
proc IML;
 /* read in dental data to matrix Y */
 use data.dental(where=(gender="F"));
 	read all var {age8 age10} into y;
 close data.dental;

 /* compute column means, covariance, correlation */
 mean = y[:,];
 cov  = cov(y);
 corr = corr(y);
 
 /* print sample statistics */
 print mean[L="Sample Mean Vector" f=6.2],
       cov[L="Sample Covariance Matrix" f=6.2],
       corr[L="Sample Correlation Matrix" f=6.2];
quit;
ods html close;
