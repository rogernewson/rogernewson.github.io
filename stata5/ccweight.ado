#delimit ;
program define ccweight;
version 5.0;
*
 Generate inverse sampling probability weights for a case-control study,
 weighting controls inversely by control/case ratio in each case group,
 for use in a robust-variance regression analysis.
 The varlist contains variables specifying the case groups.
 The options are:
 Status, an expression (usually a variable name),
 defining case-control status
 (0 for controls, other nonmissing values for cases,
 and missing values for indeterminates).
 Cpc, specifying controls per case in the final weighting,
 which may be a scalar or integer expression (defaulting to 1).
 Pweight (defaulting to _pweight), the name of an output variable,
 giving inverse sampling probability weights,
 equal to zero for units with indeterminate case-control status,
 zero for orphan cases and controls,
 one for non-orphan cases,
 and to the case/control ratio, multiplied by the cpc option if present,
 for non-orphan controls.
 The Cpc option does not affect odds ratios or mean differences,
 but improves the aesthetics if the pweight variable is tabulated.
*;
local varlist "required existing min(1)";
local options
 "Status(string) Pweight(string) Cpc(string)";
parse "`*'";
if("`status'"==""){tempvar status;gene byte `status'=1;};
if("`pweight'"==""){local pweight="_pweight";};
if("`cpc'"==""){tempname cpc;scal `cpc'=1.0;};

* Create temporary variables containing case and control status *;
tempvar ncase ncont;
gene byte `ncase'=(`status');replace `ncase'=`ncase'!=0 if(`ncase'!=.);
gene byte `ncont'=1-`ncase';

*
 Create temporary data set `casgp' with 1 obs per case group,
 containing `varlist' and control weights in `pweight'
*;
preserve;
sort `varlist';collapse (sum) `ncase' `ncont',by(`varlist');
quietly{
 replace `ncase'=0 if(`ncase'==.);replace `ncont'=0 if(`ncont'==.);
 capture drop `pweight';gene `pweight'=0;
 replace `pweight'=(`cpc')*(`ncase'/`ncont')
  if((`ncont'>0)&(`ncase'>0));
 drop `ncase' `ncont';
 tempfile casgp;save `casgp',replace;
};

*
 Merge control pweights with the rest of the data
*;
restore,preserve;
quietly{
 tempvar seqnum;gene int `seqnum'=_n;
 sort `varlist' `seqnum';
 capture drop _merge;merge `varlist' using `casgp',update;drop _merge;
 sort `seqnum';drop `seqnum';
};

*
 Set pweights to one for nonorphan cases
 and zero for units with missing case status
*;
quietly{
 replace `pweight'=0 if(`ncase'==.);
 replace `pweight'=1 if((`ncase'==1)&(`pweight'!=0));
};

*
 Restore data state before first preserve if anything went wrong
*;
restore,not;

end;
