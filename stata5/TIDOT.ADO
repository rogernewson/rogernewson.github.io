#delimit ;
program define tidot;
version 5.0;
*
 Take, as input, 2 variables in varlist,
 and, optionally, a grouping variable in option Group.
 Create, as output, a variable in option Tidot,
 containing concordance-discordance difference counts
 between the two variables in varlist.
 This program allows fweights.
*;
local varlist "required existing min(2) max(2)";
local weight "fweight";
local options "Group(string) Tidot(string)";
parse "`*'";
local y: word 1 of `varlist';local x:word 2 of `varlist';


* Create group and tidot variables *;
local tidot:word 1 of `tidot';local group: word 1 of `group';
if("`group'"==""){tempvar group;gene byte `group'=1;};
if("`tidot'"==""){tempvar tidot;disp in green "Warning: no tidot variable";};

* Calculate concordance-discordance counts in `tidot';
quietly{
tempname xcur ycur gcur;tempvar tij;
quietly{capture drop `tidot';gene `tidot'=.;gene `tij'=.;};
local i1=0;
quietly while(`i1'<_N){local i1=`i1'+1;
  scal `gcur'=`group'[`i1'];scal `ycur'=`y'[`i1'];scal `xcur'=`x'[`i1'];
  if((`xcur'!=.)&(`ycur'!=.)){
    replace `tij'=.;
    replace `tij'=sign(`x'-`xcur')*sign(`y'-`ycur') if(`group'==`gcur');
    summarize `tij' [`weight'`exp'],meanonly;
    replace `tidot'=_result(18) if(_n==`i1');
  };
};

end;
