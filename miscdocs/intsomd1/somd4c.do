#delim ;
version 16.1;
*
 Plot the 4 canonical cases of Somers' D
 against their respective alternative parameterizations
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
gene c=(somd+1)/2;
gene delta=sqrt(2)*invnorm(c);
gene double logiqor = (invnorm(0.75)-invnorm(0.25)) * delta;
gene double iqor=exp( logiqor );
gene logiqor_approx = 4*sqrt(2)*invnorm(0.75)*((c-0.25)*invnorm(0.75)+(0.75-c)*invnorm(0.25));
gene iqor_approx = exp(logiqor_approx);
gene rho=sin(somd*_pi/2);
lab var somd "Somers' {it:D}";
lab var diffprop "Difference between proportions";
lab var hazrat "Hazard ratio";
lab var loghazrat "Log hazard ratio";
lab var log2hazrat "Binary log hazard ratio";
lab var c "Harrell's {it:c}";
lab var delta "Mean difference (SDs)";
lab var logiqor "Log interquartile odds ratio";
lab var iqor "Interquartile odds ratio";
lab var logiqor_approx "Log aproximate interquartile odds ratio";
lab var iqor_approx "Approximate interquartile odds ratio";
lab var rho "Pearson correlation coefficient";
keyby somd;
desc;

*
 Create plots
*;
local ylabs "";
forv i1=-12(1)12 {;
  local ylabs "`ylabs' `=`i1'/12'";
};
local xlabs_c "";
forv i1=0(1)24 {;
  local xlabs_c "`xlabs_c' `=`i1'/24'";
};
* Difference in proportions *;
twoway line somd diffprop, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`ylabs', format(%8.4g))
  yline(0) xline(0)
  xsize(4.6) ysize(4.6);
graph export diffprop.pdf, replace;
more;
* Hazard ratio *;
logaxis hazrat if hazrat>0, base(2) scale(1(2)7) lrange(xrange) ltick(xlabs) maxt(25);
twoway line somd hazrat if hazrat>0, sort || ,
  ylab(`ylabs', format(%8.4g)) xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g))
  yline(0) xline(1)
  xsize(4.6) ysize(4.6);
graph export hazrat.pdf, replace;
more;
* Mean difference *;
regaxis delta, cy(0.25) ltick(xlabs);
twoway line somd delta, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`xlabs', format(%8.2g))
  yline(0) xline(0)
  xsize(4.6) ysize(4.6);
graph export delta.pdf, replace;
more;
* Interquartile odds ratio *;
logaxis iqor if iqor>0, base(2) scale(1(2)7) lrange(xrange) ltick(xlabs) maxt(25);
twoway line somd iqor if iqor>0, sort || ,
  ylab(`ylabs', format(%8.4g)) xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g))
  yline(0) xline(1)
  xsize(4.6) ysize(4.6);
more;
graph export iqor.pdf, replace;
* Interquartile odds ratio by Harrell's c *;
logaxis iqor if iqor>0, base(2) scale(1(2)7) lrange(yrange_iqor) ltick(ylabs_iqor) maxt(25);
twoway line iqor c if iqor>0, sort || line iqor_approx c if iqor>0, sort lpattern(dot) lwidth(thick) || ,
  yscale(log range(`yrange_iqor')) ylab(`ylabs_iqor', format(%8.4g)) xlab(`xlabs_c', format(%8.4g))
  xline(0.5) yline(1)
  legend(row(1) size(2))
  xsize(4.6) ysize(4.6);
more;
graph export iqor_c.pdf, replace;
* Pearson correlation *;
twoway line somd rho, sort || ,
  ylab(`ylabs', format(%8.4g)) xlab(`ylabs', format(%8.4g))
  yline(-0.5 `=-1/3' 0 `=1/3' 0.5) xline(`=-sqrt(0.5)' -0.5 0 0.5 `=sqrt(0.5)')
  xsize(4.6) ysize(4.6);
graph export rho.pdf, replace;
more;

exit;
