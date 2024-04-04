#delim ;
prog def xglm, eclass;
version 11.0;
*
 Extended version of glm
 with added estimation results
*!Author: Roger Newson
*!Date: 27 July 2011
*;

syntax varlist(numeric fv ts) [if] [in] [fweight pweight iweight aweight] [, * ];
glm `varlist' `if' `in' [`weight'`exp'] , `options';
* Add e(depvarsum) *;
local yvar "`e(depvar)'";
if "`e(wtype)'"=="fweight" {;
  qui summ `yvar' [`e(wtype)'`e(wexp)'] if e(sample), meanonly;
};
else {;
  qui summ `yvar' if e(sample), meanonly;
};
ereturn scalar depvarsum=r(sum);
* Add e(msum) *;
if `"`e(m)'"'!="" {;
  tempvar mvar;
  qui gene long `mvar'=`e(m)';
  qui compress `mvar';
  if "`e(wtype)'"=="fweight" {;
    qui summ `mvar' [`e(wtype)'`e(wexp)'] if e(sample), meanonly;
  };
  else {;
    qui summ `mvar' if e(sample), meanonly;
  };  
};
ereturn scalar msum=r(sum);

end;
