#delim ;
prog def expgen;
version 10.0;
/*
 Expand by expression and generate new variables
 containing sequence number of original observation before duplication
 and copy sequence number after duplication,
 sorting the dataset by these new variables
 to retain the original order.
*!Author: Roger Newson
*!Date: 07 March 2024
*/

syntax [newvarname]=/exp [if]  [in] [ , Oldseq(string) Copyseq(string) Sortedby(string) ORder Zero Missing fast ];
/*
exp specifies number of copies of the observation.
oldseq() specifies variable to be generated containing sequence order
  of old observation in the original dataset.
copyseq() specifies variable to be generated containing sequence order
  of copy in new dataset
  (1 to number of copies).
sortedby() determines the interpretation of the sortedby varlist in the input dataset,
  which determines the sortedby varlist in the output dataset.
order specifies that the variables by which the new dataset is sorted
  will be positioned at the start of the variable order.
zero specifies that observations with zero or negative value of exp
  will have one copy in the new dataset.
missing specifies that observations with missing values of exp
  will have one copy in the new dataset.
fast specifies that expgen will take no action to restore old dataset
  if expgen fails or the user presses Break.
*/

*
 Standardize and check the sortedby() option
 and initialize the sbvarlist to contain sortedby varlist
*;
local sortedby=lower(`"`sortedby'"');
if `"`sortedby'"'=="" {;local sortedby "ignore";};
else if strpos("unique",`"`sortedby'"')==1 {;local sortedby "unique";};
else if strpos("group",`"`sortedby'"')==1 {;local sortedby "group";};
else if strpos("ignore",`"`sortedby'"')==1 {;local sortedby "ignore";};
else {;
  disp as error "Invalid sortedby()";
  error 198;
};
local sbvarlist: sortedby;
if "`sbvarlist'"=="" & "`sortedby'"=="unique" {;
  disp as error "sortedby(unique) invalid because dataset is not sorted";
  error 498;
};

* Mark sample defined by if and in *;
marksample touse, novarlist;

*
 Create macros ncopy (to contain variable name for number of copies)
 and ncexp (to contain expression for number of copies)
*;
if("`varlist'"==""){;tempvar ncopy;};
else{;local ncopy "`varlist'";};
local ncexp "`exp'";

*
 Check that oldseq and copyseq are valid variable names
 (filling them in with temporary variable names if necessary)
*;
if("`oldseq'"==""){;tempvar oldseq;};
if("`copyseq'"==""){;tempvar copyseq;};
local 0 "`oldseq'";syntax newvarname;
local 0 "`copyseq'";syntax newvarname;

if "`fast'"=="" preserve;

*
 Expand and generate
*;
qui{;
  keep if(`touse');
  *
   Check that sort key uniquely identifies observations in sample to be used
   if sortedby(unique) is specified
  *;
  if "`sortedby'"=="unique" {;
    cap by `sbvarlist': assert _N==1;
    if _rc!=0 {;
      disp as error "Multiple observations with same values for variables: `sbvarlist'"
        _n as error "sortedby(unique) requires these variables to identify observations uniquely";
      error 498;
    };
  };
  * Evaluate expression for number of copies *;
  gene long `ncopy'=`ncexp';
  compress `ncopy';
  if("`missing'"==""){;drop if missing(`ncopy');};
  if("`zero'"==""){;drop if `ncopy'<1;};
  gene long `oldseq'=_n;
  compress `oldseq';
  expand =`ncopy';
  sort `oldseq';
  by `oldseq':gene long `copyseq'=_n;
  compress `copyseq';
  lab var `ncopy' "Number of copies";
  lab var `oldseq' "Observation order in input dataset";
  lab var `copyseq' "Copy order in output dataset";
  if "`sortedby'"=="ignore" {;
    * Ignore old sortedby varlist *;
    sort `oldseq' `copyseq';
  };
  else if "`sortedby'"=="group" {;
    * sortedby varlist is a group ID *;
    sort `sbvarlist' `oldseq' `copyseq';
  };
  else if "`sortedby'"=="unique" {;
    * sortedby varlist is a unique ID *;
    sort `sbvarlist' `copyseq';
  };
  * Reorder sort key to start of variable order if requested *;
  if "`order'"!="" {;
    local newsbvarlist: sortedby;
    order `newsbvarlist';
  };
};


if "`fast'"=="" restore, not;


end;
