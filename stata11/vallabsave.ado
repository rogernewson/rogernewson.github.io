#delim ;
prog def vallabsave;
version 11.0;
/*
 Save a labels-only dataset
 with no observations or variables
 and a user-specified list of value labels.
*!Author: Roger Newson
*!Date: 21 June 2019
*/

syntax [ namelist ] using/ [, replace DSLabel(string) ];
/*
 replace specifies that any existing file of the same name will be replaced.
 dslabel specifies a dataset label for the label-only dataset.
*/

*
 Set default namelist if necessary
*;
if `"`namelist'"'=="" {;
  qui lab dir;
  local namelist `"`r(names)'"';
};

*
 Create and save label-only dataset
*;
preserve;
drop _all;
* Add dataset label if requested *;
if `"`dslabel'"'!="" {;
  label data `"`dslabel'"';
};
* Drop data characteristics *;
local charlist: char _dta[];
foreach C in `charlist' {;
  char def _dta[`C'] "";
};
* Drop unwanted labels *;
qui lab dir;
local alllabels `"`r(names)'"';
local droplabels: list alllabels - namelist;
if `"`droplabels'"'!="" {;
  qui lab drop `droplabels';
};
* Save label-only dataset *;
save `"`using'"', orphans emptyok `replace';
restore;

end;
