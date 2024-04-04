#delim ;
prog def vallabload;
version 11.0;
/*
 Load a labels-only dataset
 with no observations or variables
 after checking that it has no observations and no variables.
*!Author: Roger Newson
*!Date: 11 February 2019
*/

syntax using/ [, noNOTEs ];
/*
 nonotes specifies that notes from the using dataset
  must not be added to the dataset on disk.
*/

*
 Check that the dataset is a labels-only dataset
*;
if `"`using'"'!="" {;
  cap desc using `"`using'"';
  if _rc {;
    disp as error `"File `using' cannot be described as a Stata dataset"';
    error 498;
  };
  else if r(k)>0 | r(N)>0 {;
    disp as error `"File `using' is not a label-only dataset"';
    error 498;
  };
};

*
 Append labels-only dataset
*;
append using `"`using'"', `notes';

end;
