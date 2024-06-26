#delim ;
prog def inputst;
version 6.0;
*
 Input a non-Stata data set using Stat/Transfer
 (with parameters and switches supplied by the user)
 and convert to a Stata data set in the memory,
 overwriting any existing data in the memory.
 Author: Roger Newson
 Date: 9 November 2000
*;

tempfile tmpdta;
stcmd `0' stata `tmpdta' /y;
* Check that input file exists *;
capture confirm file `tmpdta';
if(_rc!=0){
  capture erase `tmpdta';
  disp in red "Stat/Transfer did not run successfully";
  error _rc;
};
use `tmpdta',clear;
capture erase `tmpdta';

end;
