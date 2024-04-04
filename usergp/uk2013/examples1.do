#delim ;
version 12.1;
*
 Examples in the lbw data.
 SSC packages used:
 scheme_rbn1mono, sencode, keyby, sdecode, parmest, eclplot, xcontract, factmerg, insingap
 Graphics files exported:
 figseq1.pdf, figseq2.pdf, figseq3.pdf, figseq4.pdf
*;

clear all;
set scheme rbn2mono;

*
 Input data
*;
sysuse auto, clear;
describe;

*
 Demo of sencode
*;
sencode make, gsort(-weight) generate(make2);
describe make2;
keyby make2;
describe;
twoway spike weight make2,
  ylabel(0(500)5000)
  xlabel(1(1)74, labsize(2) angle(90))
  xsize(6.5) ysize(3.75);
graph export figseq1.pdf, replace;
more;

*
 Subsetting demo
*;
* Wrong way *;
twoway spike weight make2 if price>=9000,
  ylabel(0(500)5000)
  xlabel(1(1)74, labsize(2) angle(90))
  xsize(6.5) ysize(3.75);
graph export figseq2.pdf, replace;
more;
* Right way *;
sdecode make2 if price>=9000, generate(make3) prefix("{it:") suffix("}");
sencode make3, replace gsort(make2);
describe make2 make3;
levelsof make3, local(xlabs);
twoway spike weight make3,
  ylabel(0(500)5000)
  xlabel(`xlabs', labsize(2) angle(90))
  xsize(6.5) ysize(3.75);
graph export figseq3.pdf, replace;
more;

*
 Concatenating parmest resultssets
*;
tempfile tf1 tf2 tf3 tf4;
parmby "regress mpg foreign, vce(robust)",
  idstr("Unequal&Unadjusted") saving(`"`tf1'"', replace);
parmby "regress mpg foreign weight, vce(robust)",
  idstr("Unequal&Adjusted") saving(`"`tf2'"', replace);
parmby "regress mpg foreign",
  idstr("Equal&Unadjusted") saving(`"`tf3'"', replace);
parmby "regress mpg foreign weight",
  idstr("Equal&Adjusted") saving(`"`tf4'"', replace);
clear all;
append using `"`tf1'"' `"`tf2'"' `"`tf3'"' `"`tf4'"';
describe;
list idstr parmseq parm estimate min* max*, sepby(idstr);
split idstr, parse(&) generate(S_);
sencode S_1, gene(vartype);
sencode S_2, gene(adjtype);
lab var vartype "Variance type";
lab var adjtype "Adjustment type";
drop idstr S_*;
keyby vartype adjtype parmseq;
describe;
list vartype adjtype parmseq parm estimate min* max*, sepby(vartype adjtype);
* Create plot *;
eclplot estimate min* max* adjtype if parm=="foreign", hori
  estopts(msize(4)) ciopts(msize(4))
  by(vartype, col(1))
  ylab(1 2)
  xlab(-5(1)10, format(%8.4g)) xline(0)
  xtitle("Difference in mileage (MPG) between non-US and US cars", just(right))
  plotregion(margin(t=10 b=10))
  xsize(5) ysize(5);
graph export figseq4.pdf, replace;
more;

*
 Advanced example: Merging factors using factmerg
*;
* Input data and add oddness variable *;
sysuse auto, clear;
gene byte odd=mod(_n,2);
lab def odd 0 "Even" 1 "Odd";
lab val odd odd;
lab var odd "Odd-numbered car";
keyby foreign make;
desc;
tab odd, m;
* Create concatenated resultsset *;
tempfile tf1 tf2 tf3;
xcontract foreign, nomiss saving(`"`tf1'"', replace);
xcontract odd, nomiss saving(`"`tf2'"', replace);
xcontract rep78, nomiss saving(`"`tf3'"', replace);
preserve;
clear all;
append using `"`tf1'"' `"`tf2'"' `"`tf3'"';
keyby foreign odd rep78, missing;
describe;
list, sepa(0);
* Convert dataset to be keyed by factor and level *;
factmerg foreign odd rep78, flabel(factor) fvalue(faclev);
sencode factor, replace;
sencode faclev, replace manyto1 gsort(factor foreign odd rep78);
lab var factor "Factor";
lab var faclev "Factor level";
drop foreign odd rep78;
keyby factor faclev;
describe;
list, sepby(factor);
* Insert gap observations *;
sdecode faclev, gene(row);
insingap factor, rowlabel(row) grdecode(factor) inner(faclev)
  neworder(rowseq1) gapindicator(gapstat) prefix("{bf:") suffix(":}");
sencode row, replace manyto1;
describe;
list row _freq _percent, sepby(factor);
* Create plot *;
levelsof row, local(ylabs);
levelsof row if gapstat, local(ylines);
twoway bar _percent row, hori barwidth(0.75)
  yscale(reverse) ylabel(`ylabs') yline(`ylines', lpattern(solid))
  ytitle("")
  xlabel(0(10)80, format(%8.4g))
  xsize(5) ysize(5);
graph export figseq5.pdf, replace;
more;
restore;

exit;
