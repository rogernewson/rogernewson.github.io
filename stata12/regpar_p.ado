#delim ;
program define regpar_p;
version 12.0;
/*
 Predict program for regpar
 (warning the user that predict should not be used
 after regpar)
*! Author: Roger Newson
*! Date: 31 October 2011
*/

syntax [newvarlist] [, *];

disp as error
 "predict should not be used after regpar";
error 498;

end;
