#delim ;
version 14.1;
/*
 Example analyses for 2016 UK Stata User Meeting.
 Demonstrate the use of psmatch2
 in estimating a treatment effect of a treatment variable t
 (participation in a job training program)
 on an earnings measure re78 (income in 1978 dollars),
 adjusting for a list of confounders.
 This dataset is described in:
 Abadie A, Drukker D, Leber Herr J, Imbens GW.
 Implementing matching estimators for average treatment effects in Stata.
 The Stata Journal 2004; 4(3): 290–311.
 SSC packages required:
 psmatch2, somersd, parmest, xsvmat, sencode, keyby, addinby, regaxis, eclplot
*/

clear all;
set scheme rbn4mono;
local figseq=0;

*
 Input data
*;
use ldw_exper, clear;
desc, fu;
tab t, m;

* Compress data *;
compress;

* Label variables as in the original article *;
lab def t 0 "Non-participants" 1 "Participants";
lab val t t;
lab var t "Participation in the job training program";
lab var age "Age";
lab var educ "Years of education";
lab var black "Indicator for African-American";
lab var hisp "Indicator for Hispanic";
lab var married "Indicator for married";
lab var nodegree "Indicator for > grade school but < high-school education";
lab var re74 "Earnings in 1974 (1000s of 1978 $)";
lab var re75 "Earnings in 1975 (1000s of 1978 $)";
lab var re78 "Earnings in 1978 (1000s of 1978 $)";
lab var u74 "Indicator for unemployed in 1974";
lab var u75 "Indicator for unemployed in 1975";
desc, fu;
tab t, m;

*
 Compute propensity scores and weights
*;
psmatch2 t age educ black hisp married nodegree re74 re75 u74 u75, logit;
desc _pscore _weight, fu;
tab _weight, m;
summ _pscore, de format;

*
 Unadjusted Somers' D and HAIF
*;
somersd t _pscore age educ black hisp married nodegree re74 re75 u74 u75, tdist;
tempfile sdf0;
parmest, idstr("Unadjusted") saving(`"`sdf0'"', replace);
haif t;
tempfile hf0;
xsvmat, from(r(haif)) names(col) rownames(parm) idstr("Unadjusted") saving(`"`hf0'"', replace);

*
 Propensity matching
*;

*
 Generate matching weights
*;
gene matchwei=cond(missing(_weight),0,_weight);
lab var matchwei "Propensity-matching weight";
desc matchwei, fu;
tab matchwei, m;

*
 Balance and variance-inflation checks
*;
somersd t _pscore age educ black hisp married nodegree re74 re75 u74 u75
  [pwei=matchwei], tdist;
tempfile sdf1;
parmest, idstr("Matched") saving(`"`sdf1'"', replace);
haif t, pweight(matchwei);
tempfile hf1;
xsvmat, from(r(haif)) names(col) rownames(parm) idstr("Matched") saving(`"`hf1'"', replace);

*
 Regress outcome data and estimate ATET
*;
regress re78 t [pweight=matchwei], vce(robust);
scenttest, at(t=0) atzero(t=1);

*
 Propensity weighting for ATET
*;

*
 Generate propensity weights for ATET
*;
gene atetwei=cond(t==1,1,_pscore/(1-_pscore));
lab var atetwei "Propensity weight for ATET";
desc atetwei, fu;
summ atetwei, de;

*
 Balance and variance inflation checks
*;
somersd t _pscore age educ black hisp married nodegree re74 re75 u74 u75
  [pwei=atetwei], tdist;
tempfile sdf2;
parmest, idstr("Weighted") saving(`"`sdf2'"', replace);
haif t, pweight(atetwei);
tempfile hf2;
xsvmat, from(r(haif)) names(col) rownames(parm) idstr("Weighted") saving(`"`hf2'"', replace);

*
 Regress outcome data and estimate ATET
*;
regress re78 t [pweight=atetwei], vce(robust);
scenttest, at(t=0) atzero(t=1);

*
 Propensity stratification
*;

*
 Compute propensity groups
*;
xtile propgp=_pscore, nq(5);
lab var propgp "Propensity group";
desc propgp, fu;
tab propgp, m;
tab propgp t, m;

*
 Balance and variance inflation checks
*;
somersd t _pscore age educ black hisp married nodegree re74 re75 u74 u75,
  tdist wstrata(propgp);
tempfile sdf3;
parmest, idstr("Stratified") saving(`"`sdf3'"', replace);
gene byte const=1;
lab var const "Constant";
desc const, fu;
haifcomp t, nadd(ibn.propgp) dadd(const) noconst;
tempfile hf3;
xsvmat, from(r(haif)) names(col) rownames(parm) idstr("Stratified") saving(`"`hf3'"', replace);

*
 Regress outcome data and estimate ATET
*;
regress re78 ibn.propgp ibn.propgp#c.t, noconst vce(robust);
scenttest, at(t=0) atzero(t=1) subpop(if t==1);

*
 Collect HAIFs for treatment effects
*;
preserve;
clear;
append using `"`hf0'"' `"`hf1'"' `"`hf2'"' `"`hf3'"';
keep if parm=="t";
sencode idstr, gene(adjtype);
lab var adjtype "Adjustment type";
lab var Variance "Variance HAIF";
lab var SE "SE HAIF";
drop idstr parm;
keyby adjtype;
desc, fu;
list, abbr(32);
tempfile hftot;
save `"`hftot'"', replace;
restore;

*
 Append Somers' D parameters into memory
*;
clear;
append using `"`sdf0'"' `"`sdf1'"' `"`sdf2'"' `"`sdf3'"';
sencode idstr, gene(adjtype);
sencode parm, gene(covar);
lab var adjtype "Adjustment type";
lab var covar "Covariate";
drop idstr parm;
lab var estimate "Somers' {it:D}";
keyby adjtype covar;
desc, fu;
list, abbr(32) sepby(adjtype);

*
 Generate figures
*;

* Individual adjustment methods *;
foreach AT of num 2 3 4 {;
  local figseq=`figseq'+1;
  levelsof covar, lo(ylabs);
  regaxis estimate, inc(0) cy(0.01) ltick(xlabs);
  eclplot estimate estimate estimate covar if inlist(adjtype,1,`AT'), hori
    eplottype(spike) rplottype(rspike)
    estopts(lwidth(1))
    by(adjtype)
    ylab(`ylabs')
    xlab(`xlabs', labsize(1.5) format(%8.4g)) xline(0)
    xtitle("Somers' {it:D} of covariate with respect to course participation")
    ysize(5) xsize(5);
  graph export figseq`figseq'.pdf, replace;
  more;   
};

* All adjustment methods *;
local figseq=`figseq'+1;
levelsof covar, lo(ylabs);
regaxis estimate, inc(0) cy(0.01) ltick(xlabs);
eclplot estimate estimate estimate covar, hori
  eplottype(spike) rplottype(rspike)
  estopts(lwidth(1))
  by(adjtype, row(1)) subt(, size(2))
  ylab(`ylabs', labsize(2))
  xlab(`xlabs', labsize(1) format(%8.4g)) xline(0)
  xtitle("Somers' {it:D} of covariate with respect to course participation")
  plotregion(margin(l=0.5 r=0.5))
  ysize(5) xsize(5);
graph export figseq`figseq'.pdf, replace;
more;   

* Costs and benefits of propensity adjustment *;
local figseq=`figseq'+1;
preserve;
keep if covar==1;
addinby adjtype using `"`hftot'"';
desc, fu;
list, abbr(32);
regaxis estimate Variance SE, inc(1 0) cy(0.05) ltick(ylabs);
levelsof adjtype, lo(xlabs);
twoway connected Variance adjtype, sort || connected SE adjtype, sort || connected estimate adjtype, sort || ,
  ylab(`ylabs', labsize(2) format(%8.4g)) yline(0 1)
  xlab(`xlabs', labsize(2))
  legend(row(1) size(2))
  ysize(5) xsize(5);
graph export figseq`figseq'.pdf, replace;
more;   
  

restore;


exit;
