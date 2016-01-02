/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Warn_put

 Description: Write a macro-generated warning message to the SAS LOG
 using PUT.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Warn_put( 
  Macro=,    /* Macro name */
  Msg=       /* Error message (space-separated character values) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Warn_put( macro=MyMacro, Msg="Missing value." )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  11/07/04 - If Macro= parameter blank, does not include [macroname] in
             message.  Reformatted to hide resolved WARNING label in LOG.
  09/06/05 - Reformatted so that message will be displayed in color
             in SAS Enhanced Editor.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local SYL1 SYL2;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let SYL1 = "WARN";
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = "ING:";
  %end;
  %else %do;
    %let SYL2 = "ING: [&Macro]";
  %end;
  
  put &SYL1 &SYL2 " " &Msg;

%mend Warn_put;


/************************ UNCOMMENT TO TEST ***************************

data _null_;

  %Warn_put( macro=MyMacro, Msg="Test warning message." )
  
run;

/**********************************************************************/

