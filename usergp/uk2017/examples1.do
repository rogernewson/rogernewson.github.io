#delim ;
version 14.1;
/*
 Example analyses for 2017 UK Stata User Meeting.
 SSC packages required:
 wridit, bspline, polyspline, rcentile, somersd, scsomersd, expgen,
 xsvmat, keyby, addinby, parmest, factext, regaxis, eclplot
*/

clear all;
set scheme rbn4mono;
local figseq=0;

*
 Input data
*;
sysuse auto, clear;
keyby foreign make;
desc, fu;

*
 Create ridits of length
*;
wridit length, percent generate(lengthridit);
lab var lengthridit "Ridit (%) of Length (in.)";
desc lengthridit, fu;
summ lengthridit;
summ lengthridit, de;

*
 Create ridit spline basis
*;
polyspline lengthridit, power(3) refpts(0(25)100) gene(rs_) labprefix(Percent@);
desc rs_*, fu;

*
 Percentiles
*;
rcentile length, centile(0(25)100) transf(asin);
preserve;
xsvmat, from(r(cimat)) names(col) fast format(Percent Minimum Maximum Centile %8.0g);
keyby Percent;
desc, fu;
tempfile tf1;
save `"`tf1'"', replace;
restore;

*
 Fit regression model
*;
regress mpg rs_*, noconst vce(robust);
preserve;
parmest, label fast escal(N) rename(es_1 N) format(estimate stderr min* max* %8.2f p %-8.2g);
factext, parse(@);
keyby Percent;
addinby Percent using `"`tf1'"', keep(Centile);
lab var Centile "Percentile of Length (in.)";
desc, fu;
list Percent Centile parm estimate min* max*, abbr(32);
tempfile tf2;
save `"`tf2'"', replace;
restore;

*
 Create predicted outcome
*;
predict mpghat;
lab var mpghat "Predicted Mileage (mpg)";
desc mpghat, fu;
summ mpghat, de;

*
 Create plots
*;
preserve;
append using `"`tf2'"', gene(obstype);
lab def obstype 0 "Data observation" 1 "Model parameter";
lab val obstype obstype;
lab var obstype "Observation type";
keyby obstype foreign make Percent, miss;
desc, fu;
tab obstype, m;
more;
levelsof Centile if obstype==1, lo(xlines);
regaxis length Centile, cy(6) ltick(xlabs);
regaxis mpg mpghat, inc(0) cy(5) ltick(ylabs);
* Plot observed and fitted outcomes against predictor *;
local figseq=`figseq'+1;
twoway scatter mpg length || line mpghat length, sort || ,
  legend(off)
  ylab(`ylabs') ytitle("Mileage (mpg)")
  xlab(`xlabs') xline(`xlines') xtitle("Length (in.)")
  ysize(5) xsize(5);
graph export figseq`figseq'.pdf, replace;
more;
* Plot model parameters and fitted outcomes agains predictor *;
local figseq=`figseq'+1;
eclplot estimate min* max* Centile,
  estopts(mlab(Percent))
  ylab(`ylabs') ytitle("Mileage (mpg)")
  xlab(`xlabs') xline(`xlines') xtitle("Length (in.)")
  baddplot(line mpghat length, sort)
  ysize(5) xsize(5);
graph export figseq`figseq'.pdf, replace;
more;
restore;

exit;
