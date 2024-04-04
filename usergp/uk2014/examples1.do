#delim ;
version 12.1;
*
 Examples in the auto data.
 SSC packages used:
 scheme_rbn1mono, rcentile, scsomersd, expgen, somersd, xsvmat, eclplot, parmest, polyspline, bspline
 Graphics files exported:
 figseq1.pdf, figseq2.pdf, figseq3.pdf
*;

clear all;
set scheme rbn2mono;

*
 Demo of rcentile
*;

sysuse auto, clear;
gene firm=word(make,1);
lab var firm "Firm";
describe firm;
rcentile weight, centile(12.5(12.5)87.5) cluster(firm) tdist;
xsvmat, from(r(cimat)) name(col) norestore;
describe;
eclplot Centile Minimum Maximum Percent,
  xlab(12.5(12.5)87.5)
  ytitle("Percentile of Weight (US pounds)")
  plotregion(margin(l=5 r=5))
  xsize(5) ysize(5);
graph export figseq1.pdf, replace;
more;

*
 Demo of centile and qreg
*;
sysuse auto, clear;
gene firm=word(make,1);
lab var firm "Firm";
describe firm;
centile weight, centile(12.5(12.5)87.5);
foreach CE of numlist 12.5(12.5)87.5 {;
  qreg weight, quantile(`=`CE'/100') vce(robust);
};

*
 Demo of polyspline
*;

sysuse auto, clear;
*
 Quadratic spline
*;
polyspline weight, refpts(2000 3000 4500) gene(qs_);
desc qs_*;
regress mpg qs_*, robust noconst;
parmest, label list(parm label estimate min* max*)
  format(estimate min* max* %8.2f);
* Plot predicted values *;
preserve;
predict mpghat;
lab var mpghat "Predicted mileage (mpg) from quadratic";
tempfile tf1;
parmest, label saving(`"`tf1'"', replace);
append using `"`tf1'"', gene(param);
replace mpghat=estimate if param;
replace weight=real(subinstr(subinstr(label, "Spline at ","",.),",","",.))
  if param;
eclplot estimate min* max* weight,
  ylab(10(5)35) xlab(1500(500)5000)
  baddplot(line mpghat weight, sort)
  ytitle("Predicted mileage (mpg) from quadratic")
  xsize(5) ysize(5);
graph export figseq2.pdf, replace;
more;  
restore;

*
 Quadratic spline with base weight
*;
polyspline weight, refpts(2000 3000 4500) base(2000) gene(bqs_);
desc bqs_*;
regress mpg bqs_*, robust;
parmest, label list(parm label estimate min* max* p)
  format(estimate min* max* %8.2f p %-8.2g);

*
 Linear spline
*;
polyspline weight, refpts(2000 3000 4500) power(1) gene(ls_);
desc ls_*;
regress mpg ls_*, robust noconst;
parmest, label list(parm label estimate min* max*)
  format(estimate min* max* %8.2f);
* Plot predicted values *;
preserve;
predict mpghat;
lab var mpghat "Predicted mileage (mpg) from linear spline";
tempfile tf1;
parmest, label saving(`"`tf1'"', replace);
append using `"`tf1'"', gene(param);
replace mpghat=estimate if param;
replace weight=real(subinstr(subinstr(label, "Spline at ","",.),",","",.))
  if param;
eclplot estimate min* max* weight,
  ylab(10(5)35) xlab(1500(500)5000)
  baddplot(line mpghat weight, sort)
  ytitle("Predicted mileage (mpg) from linear spline")
  xsize(5) ysize(5);
graph export figseq3.pdf, replace;
more;  
restore;


exit;
