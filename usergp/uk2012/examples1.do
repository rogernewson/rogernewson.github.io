#delim ;
version 12.1;
*
 Examples in the lbw data.
 SSC packages used:
 regpar, punaf, parmest, sencode, keyby, regaxis, eclplot
 Graphics files exported:
 figseq1.eps
*;

clear all;
set scheme rbn2mono;

*
 Input data
*;
use http://www.stata-press.com/data/r11/lbw.dta, clear;
describe;
tab low, m;
tab smoke, m;
tab race, m;

global tflist "";

* Logit regression model *;
logit low i.race i.smoke, or vce(robust);

* All children, All mothers *;
regpar, at(smoke=0);
tempfile tfcur;
parmest, bmat(r(b)) vmat(r(V)) float idstr("All children (PAR)&All mothers")
  saving(`"`tfcur'"', replace) flis(tflist);

* All children, Smoking mothers *;
regpar, at(smoke=0) subpop(if smoke==1);
tempfile tfcur;
parmest, bmat(r(b)) vmat(r(V)) float idstr("All children (PAR)&Smoking mothers")
  saving(`"`tfcur'"', replace) flis(tflist);

* Low weight children, All mothers *;
punaf, at(smoke=0) eform;
tempfile tfcur;
parmest, bmat(r(b)) vmat(r(V)) float eform idstr("Low weight children (PAF)&All mothers")
  saving(`"`tfcur'"', replace) flis(tflist);

* Low weight children, Smoking mothers *;
punaf, at(smoke=0) subpop(if smoke==1) eform;
tempfile tfcur;
parmest, bmat(r(b)) vmat(r(V)) float eform idstr("Low weight children (PAF)&Smoking mothers")
  saving(`"`tfcur'"', replace) flis(tflist);

*
 Concatenate attributable risks and fractions
*;
clear;
append using $tflist;
split idstr, parse(&) gene(S_);
sencode S_1, gene(childpop);
sencode S_2, gene(motherpop);
lab var childpop "Child subpopulation";
lab var motherpop "Mother subpopulation";
drop if strpos(parm,"Scenario")==1;
foreach Y of var estimate min* max* {;
  replace `Y'=tanh(`Y') if parm=="PAR";
  replace `Y'=1-`Y' if parm=="PUF";
  replace `Y'=100*`Y';
};
creplace min* max* if parm=="PUF";
format estimate min* max* %8.2f;
drop idstr parm S_*;
keyby childpop motherpop;
desc;
list;

*
 Create plot
*;
regaxis motherpop, cy(1) ltick(ylabs);
regaxis estimate min* max*, inc(0) ltick(xlabs);
eclplot estimate min* max* motherpop, hori eplottype(bar)
  estopts(barwidth(0.75)) ciopts(msize(3))
  by(childpop, col(1))
  ylab(`ylabs', labsize(3))
  ytitle(, size(3))
  xlab(`xlabs', format(%8.4g) labsize(3))
  xtitle("Percent saved from low birth weight if no mothers smoked (95% CI)", size(3) just(right))
  plotregion(margin(t=3 b=3))
  xsize(5) ysize(5);
graph export figseq1.eps, replace;
more;

exit;
