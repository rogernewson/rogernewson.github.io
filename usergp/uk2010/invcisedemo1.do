#delim ;
version 11.0;
*
 Demo of invcise in the auto data.
 SSC packages used:
 somersd, parmest, invcise, scheme_s1mono
 External software used:
 epstopdf (available as part of MiKTeX)
*;

clear all;
set memory 1m;
set scheme rbn2mono;

*
 Set up data
*;
sysuse auto, clear;
gene byte odd=mod(_n,2);
lab def odd 0 "Even" 1 "Odd";
lab val odd odd;
lab var odd "Odd numbered model";
describe;
tab foreign odd, m;

*
 Replace dataset with resultsset with 1 obs per oddness status
 and data on median difference
 of weight between US and non-US models
*;
statsby N=(r(N))
  estimate=(el(r(cimat),1,2)) dof=(r(df_r))
  min95=(el(r(cimat),1,3)) max95=(el(r(cimat),1,4)),
  by(odd) clear:
  cendif weight, by(foreign) transf(iden) tdist;
desc;
list, abbr(32) clean noobs;

invcise min95 max95 dof, stderr(stderr);
list odd N estimate stderr dof min95 max95, abbr(32) clean noobs;

* Add interaction *;
tempfile tf1;
metaparm [iweight=(odd==1)-(odd==0)], sumvar(N) saving(`"`tf1'"', replace);
append using `"`tf1'"', gene(interact);
lab def odd 2 "Difference", add;
replace odd=2 if interact;
list odd N estimate stderr dof min95 max95, abbr(32) clean noobs;

*
 Plot differences and interaction
*;
regaxis odd, cy(1) marg(0.5) lrange(yrange) ltick(ylabs);
regaxis estimate min95 max95, inc(0) ltick(xlabs);
eclplot estimate min95 max95 odd, hori
  estopts(msize(3)) ciopts(msize(3) mlwidth(0.5))
  yscale(range(`yrange')) ylab(`ylabs')
  xlab(`xlabs', format(%8.4g)) xline(0)
  xtitle("Median weight difference (lb) between US and non-US cars", size(3) just(right))
  xsize(5)  ysize(5);
more;

* Export graphs to .eps and .pdf formats *;
graph export invcisedemo1.eps, replace;
shell epstopdf invcisedemo1.eps;

exit;
