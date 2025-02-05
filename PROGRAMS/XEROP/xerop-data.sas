*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Process data from the ICHS Study;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       xerop-data.sas                                   
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
%setup(XEROP-DATA,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);

/** code to write SAS dataset from source file **/
data dat2.xerop(drop=int costime sintime timeSQ);
 infile "&datPath2.&slash.xerop.data" dlm=' ';
 input ID respInf int age xerop costime sintime sex zheight stunted time baseage season timeSQ;                                              
run;
