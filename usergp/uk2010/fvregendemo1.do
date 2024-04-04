#delim ;
version 11.0;
*
 Demo of the fvregen package in the auto data.
 SSC packages used:
 descsave, parmest, fvregen, scheme_rbn1mono
 External software used:
 epstopdf (available as part of MiKTeX)
*;

clear all;
set memory 1m;
set scheme rbn2mono;

*
 Demonstration example in presentation
*;
sysuse auto, clear;
tempfile df0;
descsave foreign rep78,
  list(name type format vallab varlab, clean noobs)
  do(`"`df0'"', replace);
parmby
  "regress mpg ibn.foreign ibn.foreign#ib(last).rep78, noconst",
  omit empty format(estimate min* max* %8.2f p %-8.2g) norestore;
list parm omit empty estimate min* max* p, clean noobs;
fvregen, do(`"`df0'"');
list foreign rep78 omit empty estimate min* max* p,
  noobs sepby(foreign);
eclplot estimate min* max* rep78 if !empty,
  hori by(foreign)
  estopts(msize(3)) ciopts(msize(5) blwid(0.5))
  yscale(range(0.5 5.5)) ylab(1(1)5)
  xline(0) xtitle("Mean difference in mileage (mpg)")
  xsize(5) ysize(5);
more;

*
 Export graph to .eps and .pdf formats
*;
graph export fvregendemo1.eps, replace;
shell epstopdf fvregendemo1.eps;

exit;
