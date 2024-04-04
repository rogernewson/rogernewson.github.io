#delim ;
program define scenttest_p;
version 13.0;
/*
 Predict program for scenttest
 (warning the user that predict should not be used
 after scenttest)
*! Author: Roger Newson
*! Date: 05 September 2014
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after scenttest";
error 498;

end;
