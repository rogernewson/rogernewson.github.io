#delim ;
program define kmest_p;
version 12.0;
/*
 Predict program for kmest
 (warning the user that predict should not be used
 after kmest)
*! Author: Roger Newson
*! Date: 27 February 2020
*/

syntax [newvarlist] [,*];

disp as error
 "predict should not be used after kmest";
error 498;

end;
