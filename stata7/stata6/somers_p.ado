#delim ;
program define somers_p;
version 6.0;
/*
 Predict program for somersd
 (warning the user that predict should not be used
 after somersd)
*! Author: Roger Newson
*! Date: 11 March 2003
*/

syntax [newvarlist] [,*];

disp in red
 "predict should not be used after somersd";
error 498;

end;
