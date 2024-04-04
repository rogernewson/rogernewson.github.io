#delim ;
version 14.2;
*
 Create array of plots of SD of influence function
 illustrating variance formula for Harrell's c
 when comparing samples from 2 Normal populations
*;

clear;
set memory 8m;
set scheme rbn2mono;

local figseq=0;

*
 Create a dataset with 1 obs per mean difference per SD ratio
*;
local sdratios "1/4 1/2 2/3 1 3/2 2 4";
local meandiffs "-2 -1 -1/2 0 1/2 1 2";
local nratios "1 1/2 1/4 1/8 1/16";
local cols: word count `meandiffs';
local xsize 6;
local ysize 6;
local msize 1;
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
lab var sdr "SD ratio (subpop 1/0)";
lab var sdrn "SD ratio (subpop 1/0) (numeric)";
sencode sdr, replace gsort(sdrn);
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
lab var md "Mean difference (subpop 0 SDs)";
lab var mdn "Mean difference (subpop 0 SDs) (numeric)";
sencode md, replace;
assert md==mdseq;
drop mdseq;
keyby sdr sdrn md mdn;
desc;
list, abbr(32) sepby(sdr sdrn);
* Create dataset with 1 obs per mean difference per SD ratio per N ratio *;
local nnr: word count `nratios';
forv i1=1(1)`nnr' {;
  local nrcur: word `i1' of `nratios';
  gene nr`i1'="`nrcur'";
  gene nrn`i1'=(`nrcur');
};
compress;
reshape long nr nrn, i(sdr sdrn md mdn) j(nrseq);
lab var nr "Sample size ratio (subsample 1/0)";
lab var nrn "N ratio (subsample 1/0) (numeric)";
sencode nr, replace gsort(-nrn);
assert nr==nrseq;
drop nrseq;
keyby sdr sdrn md mdn nr nrn;
desc;
list, abbr(32) sepby(sdr sdrn md mdn);

*
 Add variables containing Harrell's c and Somers' D
*;
gene harc=normal(mdn/sqrt(1+sdrn*sdrn));
gene somd=2*harc-1;
lab var harc "Harrell's c";
lab var somd "Somers' D";
desc;
list, abbr(32) sepby(sdr sdrn md mdn);

*
 Create dataset with 1 obs per uniform deviate
*;
local nint=4096;
expgen =`nint'+1, copyseq(useq);
lab var useq "Uniform deviate sequence number";
gene u=(useq-1)/`nint';
lab var u "Uniform deviate";
keyby sdr sdrn md mdn nr nrn useq;
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
 Collapse dataset to have 1 obs per scenario
 and data on SDs and variances of sensitivity and specificity
*;
collapse (count) N_sens0=sens0 N_spec1=spec1 (sd) sd_sens0=sens0 sd_spec1=spec1,
  by(sdr sdrn md mdn nr nrn harc somd);
gene var_sens0=sd_sens0*sd_sens0;
gene var_spec1=sd_spec1*sd_spec1;
lab var var_sens0 "(variance) sens0";
lab var var_spec1 "(variance) spec1";
compress;
desc, fu;
summ N_sens0 N_spec1 sd_sens0 sd_spec1 var_sens0 var_spec1, de;

*
 Create formatted Harrell's c
*;
clonevar harcf=harc;
sdecode harcf, format(%5.3g) replace;
desc;
xcontract sdr md harcf, list(, abbr(32) sepby(sdr));

*
 Generate SD of influence function for Harrell's c
*;
gene sdinf_c = sqrt( (1+nrn)*var_sens0 + ((1+nrn)/nrn)*var_spec1 );
lab var sdinf_c "SD of influence function for Harrell's c";
desc sdinf_c, fu;
summ sdinf_c, de;

*
 Generate null SD of influence function for Harrell's c
*;
gene sdinf0_c = sqrt( (1+nrn)/12 + ((1+nrn)/nrn)/12 );
lab var sdinf0_c "Null SD of influence function for Harrell's c";
desc sdinf0_c, fu;
summ sdinf0_c, de;

*
 List results
*;
list sdr md nr harc somd var_sens0 var_spec1 sdinf_c sdinf0_c, abbr(32) sepby(sdr md);

*
 Plot SD of influence function for Harrell's c
*;
levelsof nr, lo(xlabs);
regaxis sdinf_c, inc(0) maxt(13) ltick(ylabs);
bynote sdr md harcf, lo(bnote);
twoway connected sdinf_c nr, msize(`msize') || ,
  by(sdr md harcf, col(`cols') note("`bnote'", size(2))) subt(, size(1.75))
  ylab(`ylabs', labsize(1.75))
  xlab(`xlabs', labsize(2))
  ytitle(, size(2)) xtitle(, size(2))
  plotregion(margin(t=0 b=0  l=1.25 r=1.25))
  ysize(`ysize') xsize(`xsize');
local figseq=`figseq'+1;
graph export sdinf1_`figseq'.pdf, replace;
more;

*
 Generate SD of influence function for quarter-logit of Harrell's c
*;
gene sdinf_lc=sdinf_c*0.25*(1/harc + 1/(1-harc));
lab var sdinf_lc "SD of influence function for quarter-logit of Harrell's c";
desc sdinf_lc, de;
summ sdinf_lc, de;

*
 List results
*;
list sdr md nr harc somd var_sens0 var_spec1 sdinf_lc sdinf0_c, abbr(32) sepby(sdr md);

*
 Plot SD of influence function for quarter-logit of Harrell's c
*;
levelsof nr, lo(xlabs);
regaxis sdinf_lc, inc(0) maxt(13) ltick(ylabs);
bynote sdr md harcf, lo(bnote);
twoway connected sdinf_lc nr, msize(`msize') || ,
  by(sdr md harcf, col(`cols') note("`bnote'", size(2))) subt(, size(1.75))
  ylab(`ylabs', labsize(1.75))
  xlab(`xlabs', labsize(2))
  ytitle(, size(2)) xtitle(, size(2))
  plotregion(margin(t=0 b=0  l=1.25 r=1.25))
  ysize(`ysize') xsize(`xsize');
local figseq=`figseq'+1;
graph export sdinf1_`figseq'.pdf, replace;
more;

*
 Compute influence function SD ratios (computed/null)
*;
gene sdinfr_c=sdinf_c/sdinf0_c;
gene sdinfr_lc=sdinf_lc/sdinf0_c;
lab var sdinfr_c "Influence function SD ratio (computed/null) for Harrell's c";
lab var sdinfr_lc "Influence function SD ratio (computed/null) for quarter-logit Harrell's c";
foreach X of var sdinfr_c sdinfr_lc {;
  desc `X', fu;
  summ `X', de;
};

*
 List results
*;
list sdr md nr harc somd var_sens0 var_spec1 sdinfr_c sdinfr_lc, abbr(32) sepby(sdr md);

*
 Plot SD ratio of influence function for Harrell's c
*;
levelsof nr, lo(xlabs);
regaxis sdinfr_c, inc(0) maxt(13) ltick(ylabs);
bynote sdr md harcf, lo(bnote);
twoway connected sdinfr_c nr, msize(`msize') || ,
  by(sdr md harcf, col(`cols') note("`bnote'", size(2))) subt(, size(1.75))
  ylab(`ylabs', labsize(1.75)) yline(1)
  xlab(`xlabs', labsize(2))
  ytitle(, size(2)) xtitle(, size(2))
  plotregion(margin(t=0 b=0  l=1.25 r=1.25))
  ysize(`ysize') xsize(`xsize');
local figseq=`figseq'+1;
graph export sdinf1_`figseq'.pdf, replace;
more;

*
 Plot SD ratio of influence function for quarter-logit Harrell's c
*;
levelsof nr, lo(xlabs);
regaxis sdinfr_lc, inc(0) maxt(13) ltick(ylabs);
bynote sdr md harcf, lo(bnote);
twoway connected sdinfr_lc nr, msize(`msize') || ,
  by(sdr md harcf, col(`cols') note("`bnote'", size(2))) subt(, size(1.75))
  ylab(`ylabs', labsize(1.75)) yline(1)
  xlab(`xlabs', labsize(2))
  ytitle(, size(2)) xtitle(, size(2))
  plotregion(margin(t=0 b=0  l=1.25 r=1.25))
  ysize(`ysize') xsize(`xsize');
local figseq=`figseq'+1;
graph export sdinf1_`figseq'.pdf, replace;
more;


exit;
