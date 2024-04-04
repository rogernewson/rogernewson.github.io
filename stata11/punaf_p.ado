#delim ;
program define punaf_p;
version 11.0;
/*
 Predict program for punaf
 (warning the user that predict should not be used
 after punaf)
*! Author: Roger Newson
*! Date: 01 February 2010
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after punaf";
error 498;

end;
