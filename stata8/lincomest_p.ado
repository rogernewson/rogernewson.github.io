#delim ;
program define lincomest_p;
version 8.0;
/*
 Predict program for lincomest
 (warning the user that predict should not be used
 after lincomest)
*! Author: Roger Newson
*! Date: 10 May 2005
*/

syntax [newvarlist] [,*];

disp in red
 "predict should not be used after lincomest";
error 498;

end;
