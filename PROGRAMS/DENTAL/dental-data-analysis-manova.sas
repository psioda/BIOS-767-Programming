*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Analysis of data from the Dental Study;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       dental-data-analysis-manova.sas                                   
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
%setup(DENTAL-DATA-ANALYSIS-MANOVA,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);
option papersize=("8.5in","11.0in") topmargin=0.1in rightmargin=0.1in leftmargin=0.1in bottommargin=0.1in;



/*************************************************************************************
 *************************************************************************************
 *************************************************************************************
 *************************************************************************************
 ************************************************************************************/
ods noptitle;
ods html path = "&outpath." file="Dental-MANOVA-Analysis1.html";
	title1 j=c "Analysis of Dental Study Data -- Multivariate ANOVA (MANOVA)";
	proc glm data = dat2.dental;
		class gender;
		model age8 age10 age12 age14 = gender / nouni;
		repeated age / nou ;
	run;
	quit;
ods html close;

