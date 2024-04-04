#delim ;
version 14.2;
*
 Create array of sensitivity-specificity plots
 illustrating variance formula for Harrell's c
*;

clear;
set memory 8m;
set scheme rbn2mono;

*
 Create a dataset with 1 obs per mean difference per SD ratio
*;
local sdratios "1/4 1/2 1 2 4";
local meandiffs "-2 -1 0 1 2";
set obs 1;
gene byte baseline=1;
* Create dataset with 1 obs per SD ratio *;
local nsr: word count `sdratios';
forv i1=1(1)`nsr' {;
  local sdrcur: word `i1' of `sdratios';
  gene sdr`i1'="`sdrcur'";
  gene sdrn`i1'=(`sdrcur');
};
compress;
reshape long sdr sdrn, i(baseline) j(sdrseq);
lab var sdr "SD ratio";
lab var sdrn "SD ratio (numeric)";
sencode sdr, replace;
assert sdr==sdrseq;
drop baseline sdrseq;
keyby sdr sdrn;
desc;
list, abbr(32);
* Create dataset with 1 obs per mean difference per SD ratio *;
local nmd: word count `meandiffs';
forv i1=1(1)`nmd' {;
  local mdcur: word `i1' of `meandiffs';
  gene md`i1'="`mdcur'";
  gene mdn`i1'=(`mdcur');
};
compress;
reshape long md mdn, i(sdr sdrn) j(mdseq);
lab var md "Mean difference (Subpop 0 SDs)";
lab var mdn "Mean difference (Subpop 0 SDs) (numeric)";
sencode md, replace;
assert md==mdseq;
drop mdseq;
keyby sdr sdrn md mdn;
desc;
list, abbr(32) sepby(sdr sdrn);

*
 Add variables containing Harrell's c and Somers' D
*;
gene harc=normal(mdn/sqrt(1+sdrn*sdrn));
gene somd=2*harc-1;
lab var harc "Harrell's c";
lab var somd "Somers' D";
desc;
list, abbr(32) sepby(sdr sdrn);

*
 Create dataset with 1 obs per uniform deviate
*;
local nint=4096;
expgen =`nint'+1, copyseq(useq);
lab var useq "Uniform deviate sequence number";
gene u=(useq-1)/`nint';
lab var u "Uniform deviate";
keyby sdr sdrn md mdn useq;
desc;
summ useq u, de;

*
 Add sensitivity and specificity
*;
gene nordev0=invnorm(u);
gene nordev1 = sdrn*nordev0 + mdn;
gene sens0=1-normal((nordev0-mdn)/sdrn);
replace sens0=0 if u==1;
replace sens0=1 if u==0;
gene spec1=normal(nordev1);
replace spec1=0 if u==0;
replace spec1=1 if u==1;
lab var nordev0 "Normal deviate (Subpopulation 0)";
lab var nordev1 "Normal deviate (Subpopulation 1)";
lab var sens0 "Sensitivity (Subpopulation 0)";
lab var spec1 "Specificity (Subpopulation 1)";
desc;
summ nordev0 nordev1 sens0 spec1, de;

*
 Create plots
*;
clonevar harcf=harc;
sdecode harcf, format(%5.3g) replace;
desc;
xcontract sdr md harcf, list(, abbr(32) sepby(sdr));
numlist "0(0.125)1";
local xylabs "`r(numlist)'";
bynote sdr md harcf, lo(noteby);
line sens0 u, sort || ,
  by(sdr md harcf, note("`noteby'", size(2.5))) subtitle(, size(2.125) height(2.125))
  aspect(1)
  xlab(`xylabs', labsize(2)) ylab(`xylabs', labsize(2))
  xtitle("Specificity", size(2.75)) ytitle("Sensitivity", size(2.75))
  graphregion(margin(0 0 0 0))
  plotregion(margin(0.75 0.75 0.5 0.5))
  xsize(6) ysize(6);
graph export senspec2.pdf, replace;
more;

exit;
