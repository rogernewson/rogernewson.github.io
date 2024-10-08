#delim ;
program define dolog;
local cversion=c(version);
version 16.0;
*
 Execute a do-file `1', outputting to `1'.log,
 with the option of passing parameters.
 Adapted from an example called dofile, given in net course 151,
 and installed at the KCL site by Jonathan Sterne.
*!Author: Roger Newson
*!Date: 07 July 2021
*;

syntax [ anything ] [ , * ];

*
 Extract do-file name (unabbreviated and abbreviated)
 and argument list.
*;
gettoken dfname arglist : anything;
if `"`dfname'"'=="" {;
  disp as error "Do-file name required";
  error 498;
};
mata: st_local("abdfname",pathrmsuffix(st_local("dfname")));

*
 Execute the do-file,
 generating a log file.
*;
tempname currentlog;
log using `"`abdfname'.log"', replace name(`currentlog');
capture noisily version `cversion': do `"`dfname'"' `arglist', `options';
local retcod = _rc;
log close `currentlog';
exit `retcod';

end;
