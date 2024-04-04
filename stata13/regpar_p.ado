#delim ;
program define regpar_p;
version 13.0;
/*
 Predict program for regpar
 (warning the user that predict should not be used
 after regpar)
*! Author: Roger Newson
*! Date: 24 September 2013
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after regpar";
error 498;

end;
