#delimit ;
program define ujack;
version 5.0;
*
 Take, as input, 1 variable in varlist,
 containing uidot values for a U-statistic,
 and, optionally, a degree for the U-statistic in option Degree
 (defaulting to 2).
 Create, as output, a variable in option Pseud,
 containing jackknife pseudovalues for the U-statistic,
 retaining the n value in scalar S_1
 and the udotdot value in scalar S_2.
 This program allows fweights.
*;
local varlist "required existing min(1) max(1)";
local weight "fweight";
local options "Pseud(string) Degree(int 2)";
parse "`*'";
local uidot: word 1 of `varlist';

* Create pseudovalue variable if necessary *;
local pseud:word 1 of `pseud';
if("`pseud'"==""){tempvar pseud;disp in green "Warning: no pseud variable";};

* Calculate udotdot *;
tempname n udotdot;quietly summarize `uidot' [`weight'`exp'],meanonly;
scal `n'=_result(1);scal `udotdot'=_result(18);

* Calculate jackknife pseudovalues *;
tempname denom1 denom2;scal `denom1'=1;scal `denom2'=1;local i1=0;
while(`i1'<`degree'-1){local i1=`i1'+1;
  scal `denom1'=`denom1'*(`n'-`i1');scal `denom2'=`denom2'*(`n'-`i1'-1);
};
quietly{capture drop `pseud';
  gene `pseud'=`udotdot'/`denom1' - (`udotdot'-`degree'*`uidot')/`denom2';
};

* Save results in system scalars *;scal S_1=`n';scal S_2=`udotdot';

end;
