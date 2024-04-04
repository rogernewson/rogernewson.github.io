#delim ;
version 13.1;
*
 Examples of Somers' D as a common currency between associations.
 SSC packages used:
 keyby, regaxis
 Graphics files exported:
 figseq1.pdf, figseq2.pdf, figseq3.pdf, figseq3a.pdf, figseq4.pdf, figseq5.pdf
*;

clear;
set memory 1m;
set scheme rbn2mono;

*
 Create data
*;
local nposmag=1024;
local zeroseq=`nposmag'+1;
set obs `=2*`nposmag'+1';
gene somd=(_n-`zeroseq')/`nposmag';
gene diffprop=somd;
gene hazrat=(somd+1)/2;
replace hazrat=(1-hazrat)/hazrat;
gene loghazrat=log(hazrat);
gene log2hazrat=loghazrat/log(2);
gene delta=(somd+1)/2;
replace delta=sqrt(2)*invnorm(delta);
gene iqor=exp( (invnorm(0.75)-invnorm(0.25)) * delta );
gene itor=exp( (invnorm(2/3)-invnorm(1/3)) * delta );
gene rho=sin(somd*_pi/2);
lab var somd "Somers' {it:D}";
lab var diffprop "Difference between proportions";
lab var hazrat "Hazard ratio";
lab var loghazrat "Log hazard ratio";
lab var log2hazrat "Binary log hazard ratio";
lab var delta "Mean difference (SDs)";
lab var iqor "Interquartile odds ratio";
lab var itor "Intertertile odds ratio";
lab var rho "Pearson correlation coefficient";
keyby somd;
desc;

*
 Create plots
*;
* Create labels for the Somers' D axis *;
local ylabs "";
forv i1=-12(1)12 {;
  local ylabs "`ylabs' `=`i1'/12'";
};
* Difference in proportions *;
twoway line somd diffprop, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`ylabs', format(%8.4g))
  yline(-1(0.5)1) xline(-1(0.5)1)
  ysize(5) xsize(5);
graph export figseq1.pdf, replace;
more;
* Mean difference *;
scal deltamax=sqrt(2)*invnorm((0.5+1)/2);
disp deltamax;
regaxis delta, cy(0.25) ltick(xlabs);
twoway line somd delta, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`xlabs', format(%8.2g))
  yline(-1(0.5)1) xline(`=-deltamax' 0 `=deltamax')
  ysize(5) xsize(5);
graph export figseq2.pdf, replace;
more;
* Interquartile odds ratio *;
scal iqormax=exp(deltamax*(invnorm(0.75) - invnorm(0.25)));
disp iqormax;
logaxis iqor if iqor>0, base(2) scale(1(2)7) lrange(xrange) ltick(xlabs) maxt(25);
twoway line somd iqor if iqor>0, sort || ,
  ylab(`ylabs', format(%8.4g)) xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g))
  yline(-1(0.5)1) xline(`=1/iqormax' 1 `=iqormax')
  ysize(5) xsize(5);
more;
graph export figseq3.pdf, replace;
* Intertertile odds ratio *;
scal itormax=exp(deltamax*(invnorm(2/3) - invnorm(1/3)));
disp itormax;
logaxis itor if itor>0, base(2) scale(1(2)7) lrange(xrange) ltick(xlabs) maxt(25);
twoway line somd itor if itor>0, sort || ,
  ylab(`ylabs', format(%8.4g)) xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g))
  yline(-1(0.5)1) xline(`=1/itormax' 1 `=itormax')
  ysize(5) xsize(5);
more;
graph export figseq3a.pdf, replace;
* Hazard ratio *;
logaxis hazrat if hazrat>0, base(2) scale(1(2)7) lrange(xrange) ltick(xlabs) maxt(25);
twoway line somd hazrat if hazrat>0, sort || ,
  ylab(`ylabs', format(%8.4g)) xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g))
  yline(-1(0.5)1) xline(`=1/3' 1 3)
  ysize(5) xsize(5);
graph export figseq4.pdf, replace;
more;
* Pearson correlation *;
twoway line somd rho, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`ylabs', format(%8.4g))
  yline(-1 -0.5 `=-1/3' 0 `=1/3' 0.5 1) xline(-1 `=-sqrt(0.5)' -0.5 0 0.5 `=sqrt(0.5)' 1)
  ysize(5) xsize(5);
graph export figseq5.pdf, replace;
more;

exit;
