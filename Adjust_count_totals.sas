/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Adjust_count_totals

 Description: Adjusts a list of integer count variables against a 
 control total.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Adjust_count_totals( 
  in_ds=,          /** Input data set **/
  out_ds=,         /** Output data set **/
  control_total=,  /** Control total var **/
  counts=,         /** Count vars **/
  comp_op=EQ,      /** Comparison operator **/
  debug=N,         /** Print debugging info **/
  quiet=Y          /** Suppress LOG notes **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Adjust_count_totals( 
       in_ds=Test_adjust_count_totals,
       out_ds=Adjust_count_results,
       control_total=total,
       counts=a b c d,
       comp_op=eq,
       debug=y,
       quiet=n
     )
     adjusts count vars a b c and d so that their sum equals total 

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

    06/02/03  Peter A. Tatian
    06/27/03  Revised so that macro creates its own data step.
    06/30/03  Revised so that if control_total is 0, all counts 
              will be set to 0.
    07/02/03  Corrected problem where initial adjusted counts all round to 0
              and so final adjusted counts do not add to control total.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    %local ;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  data &out_ds;
  
    set &in_ds end=_act_last_obs;
  
    if _n_ = 1 then do;
      put / "NOTE (Adjust_count_totals):  Adjusting counts where " @;
      put "%upcase( &control_total &comp_op sum( of &counts ) ) " @;
      put "is not true." /;
    end;

    array _act_array{*} &counts;
    
    ** Copy original count values into separate array **;
    
    array _act_array_org{32767} _temporary_;
    
    do _act_i = 1 to dim( _act_array );
      _act_array_org{_act_i} = _act_array{_act_i};
    end;

    ** Initialize total vars **;

    _act_ctrl_total = &control_total;
    _act_sum_array = sum( of _act_array{*} );

    %if %mparam_is_yes( &debug ) %then %do;
      put / "INPUT DATA" // _n_= _act_ctrl_total= _act_sum_array= ;
      put (&counts) (=);
      ****%put_array( _act_array );
    %end;

    if _act_sum_array ~= 0 and _act_ctrl_total >= 0 and not( _act_ctrl_total &comp_op _act_sum_array ) then do;

      %if %upcase( &quiet ) = N %then %do;
        put "NOTE (Adjust_count_totals):  Adjusting counts for obs. " _n_;
      %end;
      
      %Sort_array_ref( _act_array, quiet=y, order=descending );

      do _act_i = 1 to dim( _act_array );
        _act_array{ _act_i } = round( _act_array{ _act_i } * ( _act_ctrl_total / _act_sum_array ) );
      end;

      _act_sum_array = sum( of _act_array{*} );
      _act_diff = _act_sum_array - _act_ctrl_total;

      %if %mparam_is_yes( &debug ) %then %do;
        put / "STEP 1" // _act_ctrl_total= _act_sum_array= _act_diff= ;
        put (&counts) (=);
        ****%put_array( _act_array );
      %end;

      if _act_diff ~= 0 then do;

        ****[7/2/03] %Sort_array_ref( _act_array, quiet=y, order=descending );

        do _act_i = 1 to dim( _act_array );
        
          ****[7/2/03] if _act_array{ _act_array_srtd{ _act_i } } > 0 then do;
          if _act_array_org{ _act_array_srtd{ _act_i } } > 0 then do;
        
            if _act_diff > 0 then 
              _act_array{ _act_array_srtd{ _act_i } } = 
                _act_array{ _act_array_srtd{ _act_i } } - 
                min( _act_array{ _act_array_srtd{ _act_i } }, _act_diff );
            else if _act_diff < 0 then
              _act_array{ _act_array_srtd{ _act_i } } = 
                _act_array{ _act_array_srtd{ _act_i } } - _act_diff;
            
            _act_sum_array = sum( of _act_array{*} );
            _act_diff = _act_sum_array - _act_ctrl_total;
    
            if _act_diff = 0 then go to exit_loop;
    
          end;
                      
        end;
        
        exit_loop:

      end;

    end;

    _act_sum_array = sum( of _act_array{*} );

    %if %mparam_is_yes( &debug ) %then %do;
      put / "FINAL" // _act_ctrl_total= _act_sum_array= _act_diff= ;
      put (&counts) (=);
      ****%put_array( _act_array );
    %end;
    
    drop _act_: ;

  run;

  %***** ***** ***** CLEAN UP ***** ***** *****;

  
%mend Adjust_count_totals;


/************************ UNCOMMENT TO TEST ***************************

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint nosymbolgen nomlogic;

title "Adjust_count_totals:  SAS Macro Library";

data Test_adjust_count_totals;

  input total a b c d;
  
  cards;
  100 40 30 0 10
  100 47 1 1 1
  100 50 40 0 20
  10 4 3 0 1
  10 5 4 0 2
  1 0 10 11 2
  1 0 100 101 20
  ;

run;

%Adjust_count_totals( 
  in_ds=Test_adjust_count_totals,
  out_ds=_null_,
  control_total=total,
  counts=a b c d,
  comp_op=eq,
  debug=y,
  quiet=n
)
  
/**********************************************************************/

