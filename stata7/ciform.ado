#delim ;
program define ciform;
version 7.0;
*
 Take, as input, a list of 3 numeric variables,
 supposed to contain estimates and upper and lower confidence limits
 (as output by parmest).
 Give, as output, a list of 3 string variables,
 containing the input variables formatted as a confidence interval
 ready to be output to a generic text file by outsheet
 and imported into a word processor or spreadsheet (or even TeX)
 and made into a table.
 Author: Roger Newson
 Date: 21 February 2002
*;

syntax [ varlist(numeric default=none) ] [if] [in],Newvars(string)
  [ Format(string) Refind(varname numeric) ];
*
 -varlist- contains the 3 numeric input variables
  (defaulting to estimate, min$S_level and max$S_level
  as created by parmest).
 -newvars- contains a list of 3 new string variables to be created.
 -format- contains the format to be used
  (defaulting to the format of the first variable in -varlist-).
 -refind- contains the reference value indicator
  (1 if reference value, 0 otherwise)
  telling -ciform- to format the confidence limits accordingly.
*;
marksample touse;
if("`varlist'"==""){local varlist "estimate min$S_level max$S_level";};
local esti:word 1 of `varlist';
local cimin:word 2 of `varlist';local cimax:word 3 of `varlist';
* Check that variables in the input varlist exist *;
local 0 "`varlist'";syntax varlist(numeric min=3 max=3);
*
 Check that newvars is a newvarlist of 3
 and put its contents into output macros
*;
local 0 "`newvars'";
syntax newvarlist(min=3 max=3);
local sesti:word 1 of `varlist';
local scimin:word 2 of `varlist';local scimax:word 3 of `varlist';
* Ensure that format is present *;
if("`format'"==""){local format:format `esti';};

* Create new variables *;
qui{
  gene str1 `sesti'=" ";gene str1 `scimin'=" ";gene str1 `scimax'=" ";
  replace `sesti'=string(`esti',"`format'") if(`touse');
  replace `scimin'="("+string(`cimin',"`format'")+"," if(`touse');
  replace `scimax'=string(`cimax',"`format'")+")" if(`touse');
};

* Reformat reference values *;
local reflab2 "(ref)";
local reflab3 "";
if "`refind'"!="" {;
  qui replace `scimin'="`reflab2'" if `touse'&(`refind'==1);
  qui replace `scimax'="`reflab3'" if `touse'&(`refind'==1);
};

end;
