#delim ;
program define estparm_p;
version 10.0;
/*
 Predict program for estparm
 (warning the user that predict should not be used
 after estparm)
*! Author: Roger Newson
*! Date: 20 April 2008
*/

syntax [newvarlist] [, * ];

disp as error
 "predict should not be used after estparm or estparmtest";
error 498;

end;
