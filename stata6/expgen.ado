#delim ;
prog def expgen;
version 6.0;
*
 Expand by expression and generate new variables
 containing sequence number of original observation before duplication
 and copy sequence number after duplication,
 sorting the data set by these new variables
 to retain the original order.
 Author: Roger Newson
 Date: 16 November 2000
*;
syntax [newvarname]=/exp [if]  [in] [ , Oldseq(string) Copyseq(string) Zero Missing ];
*
 exp specifies number of copies of the observation.
 oldseq specifies variable to be generated containing sequence order
 of old observation in the original data set.
 copyseq specifies variable to be generated containing sequence order
 of copy in new data set
 (1 to number of copies).
 zero specifies that observations with zero or negative value of exp
 will have one copy in the new data set.
 missing specifies that observations with missing values of exp
 will have one copy in the new data set.
*;

* Mark sample defined by if and in *;
marksample touse,novarlist;

*
 Create macros ncopy (to contain variable name for number of copies)
 and ncexp (to contain expression for number of copies)
*;
if("`varlist'"==""){tempvar ncopy;};
else{local ncopy "`varlist'";};
local ncexp "`exp'";

*
 Check that oldseq and copyseq are valid variable names
 (filling them in with temporary variable names if necessary)
*;
if("`oldseq'"==""){tempvar oldseq;};
if("`copyseq'"==""){tempvar copyseq;};
local 0 "`oldseq'";syntax newvarname;
local 0 "`copyseq'";syntax newvarname;

preserve;

qui{
  keep if(`touse');
  * Evaluate expression for number of copies *;
  gene int `ncopy'=`ncexp';compress `ncopy';
  if("`missing'"==""){drop if(`ncopy'==.);};
  if("`zero'"==""){drop if(`ncopy'<1);};
  gene int `oldseq'=_n;compress `oldseq';
  expand =`ncopy';
  sort `oldseq';
  by `oldseq':gene int `copyseq'=_n;compress `copyseq';
  sort `oldseq' `copyseq';
};

restore,not;

end;
