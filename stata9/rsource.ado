#delim ;
prog def rsource;
version 9.0;
/*
  Run R as a command line job,
  using source code from the using file
  and optionally outputting source code and/or listed output
  to the Stata log,
*!Author: Roger Newson
*!Date: 07 June 2007
*/

syntax using/ [, RPath(string) ROptions(string) noLOutput LSource ];
/*
  rpath is the path for the Rterm program on the user's system
    (possibly stored by default in the global macro Rterm_path
    and otherwise set by default to "Rterm.exe").
  roptions is the default option set for the Rterm program on the user's system
    (possibly stored by default in the global macro Rterm_options
    and otherwise set by default to an empty string).
  noloutput specifies that the listed R output is not listed to the Stata log.
  lsource specifies that the  source file is listed to the Stata log.
*/

*
 Set default Rterm path and options
*;
if `"`rpath'"'=="" {;
  local rpath `"$Rterm_path"';
  if `"`rpath'"'=="" {;
    local rpath "Rterm.exe";
  };
};
if `"`roptions'"'=="" {;
  local roptions `"$Rterm_options"';
};

* Display assumed R path to output *;
disp as text "Assumed R program path: " as result `""`rpath'""';

*
 List R source if requested
*;
if "`lsource'"=="lsource" {;
  disp _n as text "Beginning of listing of R source file: " as result `"`using'"';
  type `"`using'"';
  disp _n as text "End of listing of R source file: " as result `"`using'"';
};

*
 Execute Rterm
*;
tempfile tempsource templis;
copy `"`using'"' `"`tempsource'"';
local Rcommand `""`rpath'" `roptions' < "`tempsource'" > "`templis'""';
shell `Rcommand';

*
 List R output if requested
*;
if "`loutput'"!="noloutput" {;
  disp _n as text "Beginning of R output from source file: " as result `"`using'"';
  type `"`templis'"';
  disp _n as text "End of R output from source file: " as result `"`using'"';
};

end;
