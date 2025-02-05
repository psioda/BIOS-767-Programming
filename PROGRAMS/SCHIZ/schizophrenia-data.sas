*********************************************************************                             
*                                                                   
*  PROGRAM DESCRIPTION: Process data from the Schizophrenia Study;
*                                                                   
*-------------------------------------------------------------------
*  JOB NAME:       schizophrenia-data.sas                                   
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
%setup(SCHIZOPHRENIA-DATA,C:\USERS\PSIODA\DOCUMENTS\GITHUB\BIOS-767-PROGRAMMING);




/** code to read in text files in SAS **/
data dat2.schiz;
 infile "&datPath2.&slash.schiz.txt" dlm=' '  missover firstobs=1;
 length id $20 ;
 input id y trt week ;

 modWorse = (y>=3);
run;

