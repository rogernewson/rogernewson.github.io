#delim ;
version 18.0;
*
 Example 1.
 Demo of balance and variance inflation checks
 with birthweight and maternal smoking
 in the cattaneo2 data.
 SSC packages required:
 scheme_rbn1mono, somersd, parmest, xframeappend,
 sencode, keyby, regaxis, haif
*; 

set linesize 80;
clear all;
set scheme rbn4mono;

*
 Input data
*;
use https://www.stata-press.com/data/r17/cattaneo2.dta;
desc, fu;
tab msmoke, m;

*
 Fit propensity model
 and compute ATE weights
*;
logit mbsmoke mmarried mhisp fhisp foreign alcohol deadkids
  mage medu fage fedu nprenatal monthslb order mrace frace
  prenatal fbaby,
  vce(robust);
predict propscor;
gene propwt=cond(mbsmoke,1/propscor,1/(1-propscor));
lab var propscor "Propensity score";
lab var propwt "Propensity ATE weight";
summ propscor, detail;
summ propwt, detail;

*
 Balance checks
*;
frame create somdframe;
somersd mbsmoke propscor mmarried mhisp fhisp foreign alcohol deadkids
  mage medu fage fedu nprenatal monthslb order mrace frace prenatal fbaby
  , tdist;
parmest, idstr(Unweighted)
  label escal(N) rename(es_1 N)
  frame(tframe, replace);
frame somdframe: xframeappend tframe, drop;
somersd mbsmoke propscor mmarried mhisp fhisp foreign alcohol deadkids
  mage medu fage fedu nprenatal monthslb order mrace frace prenatal fbaby
  [pwei=propwt], tdist;
parmest, idstr(ATE-weighted)
  label escal(N) rename(es_1 N)
  frame(tframe, replace);
frame somdframe: xframeappend tframe, drop;
frame somdframe {;
  format estimate min* max* %8.3f;
  format p %-8.2g;
  sencode idstr, gene(adjtype);
  sencode parm, replace;
  drop idstr;
  lab var adjtype "Adjustment type";
  lab var parm "Parameter";
  keyby adjtype parm;
  lab data "Somers' D estimates for propensity scores and predictors";
  describe, full; 
  list adjtype parm estimate min* max* p, sepby(adjtype);
  * Plot unweighted and weightedSomers' D estimates *;
  regaxis estimate, inc(-0.5 0 0.5) cy(0.1) ltick(xlabs);
  levelsof parm, lo(ylabs);
  graph twoway bar estimate parm,
      hori barwidth(0.5)
      by(adjtype, cols(2) compact note(""))
      yscale(reverse) ylab(`ylabs', angle(horizontal) valuelabel)
      xline(0, lpattern(shortdash)) 
	  ytitle("Propensity predictor")
	  xlab(`xlabs', format(%8.1f) angle(vertical) grid)
	  xtitle("Somers' {it:D} with respect to maternal smoking")
	  ysize(4.6) xsize(4.6);
    graph export figseq1.pdf, replace;
    more;
};

*
 Variance inflation checks
*;
haif mbsmoke, pwei(propwt);

*
 Regress outcome data and estimate ATE
*;
regress bweight ibn.mbsmoke [pweight=propwt], noconst vce(robust) nohead;
lincom 1.mbsmoke-0.mbsmoke;



exit;
