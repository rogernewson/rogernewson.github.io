#delim ;
prog def outputstold;
version 10.0;
/*
  Output a non-Stata data set using Stat/Transfer
 (with parameters and switches supplied by the user)
 from the Stata data set in the memory,
 using saveold instead of save
 to produce the temporary Stata dataset
 for input to stcmd.
*!Author: Roger Newson
*!Date: 11 August 2011
*/

tempfile tmpdta;
disp as text "Outputting data to temporary datafile: " as result `"`tmpdta'"';
qui saveold `"`tmpdta'"', replace;
cap confirm file `"`tmpdta'"';
if _rc!=0 {;
  disp as error "Temporary datafile not created: " as result `"`tmpdta'"';
  error _rc;
};
disp as text "Temporary datafile created: " as result `"`tmpdta'"';
stcmd stata "`tmpdta'" `0';

end;
