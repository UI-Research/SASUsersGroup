/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moe_prop

 Description: Autocall macro that returns a calculation for a margin of error 
 for a derived proportion based on the values and margins of error of the 
 proportion numerator and denominator.
 
 The numerator of a proportion must be a subset of the denominator 
 (e.g., the proportion of single person households that are female).

 Method based on 
 http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
 pp. A-14 - A-15.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro moe_prop( 
  num=,       /** Proportion numerator value **/
  den=,       /** Proportion denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=    /** Denominator margin of error **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %moe_prop( num=female, den=total, num_moe=female_moe, den_moe=total_moe )
       returns calculation for margin of error for proportion female/total

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   06/28/11  Peter A. Tatian
   09/23/11  PAT Updated header note.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local prop;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %let prop = ((&num)/(&den));
  
  (sqrt( ((&num_moe)*(&num_moe)) - ((&prop*&prop) * ((&den_moe)*(&den_moe))) ) / (&den))

%mend moe_prop;


/************************ UNCOMMENT TO TEST ***************************

options mprint;

data _null_;

  prop = 45/100;
  moe = %moe_prop( num=45, den=100, num_moe=10, den_moe=15 );
  put prop= moe=;

run;

/**********************************************************************/

