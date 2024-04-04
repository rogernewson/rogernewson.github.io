#delim ;
program define punafcc_p;
version 13.0;
/*
 Predict program for punafcc
 (warning the user that predict should not be used
 after punafcc)
*! Author: Roger Newson
*! Date: 25 October 2011
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after punafcc";
error 498;

end;
