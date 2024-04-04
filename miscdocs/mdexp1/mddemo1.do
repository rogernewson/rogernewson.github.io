#delim ;
version 10.1;
*
 Demo of median differences, differences between medians, and mean differences
 between 2 exponential subpopulations with means 1 and sigmarat,
 where sigmarat takes a range of values greater than 1.
*;

clear;
set memory 1m;
set scheme rbn2mono;

local maxratio=4;
local minratio=1;
local nratio=1001;
set obs `nratio';
gene sigmarat = `minratio' + (`maxratio'-`minratio')*(_n-1)/(_N-1);
gene meddif=-sigmarat*ln((1 + 1/sigmarat)/2);
gene difmed=ln(2)*(sigmarat-1);
gene meandif=sigmarat-1;
gene dmratio=difmed/meddif;
lab var sigmarat "Ratio between largest and smallest means";
lab var meddif "Hodges-Lehmann median difference";
lab var difmed "Difference between medians";
lab var meandif "Mean difference";
lab var dmratio "Difference between medians/median difference";
keyby sigmarat;
desc;
summ, de;

*
 Plots
*;
regaxis sigmarat, cy(0.125) inc(1) ltick(xlabs);
regaxis meddif difmed meandif, cy(0.125) ltick(ylabs) maxt(17);
line meandif sigmarat, sort lpattern(shortdash) || line difmed sigmarat, sort lpattern(longdash) || line meddif sigmarat , sort lpattern(solid) || ,
  ylab(`ylabs') xlab(`xlabs');
graph export figseq1.eps, replace;
more;
regaxis dmratio, inc(1 `=2*ln(2)') cy(0.125) ltick(ylabs);
line dmratio sigmarat, sort yaxis(1 2) || ,
  yscale(range(1)) ylab(`ylabs', axis(1)) ylab(1 `=2*ln(2)' "2 ln(2)", axis(2)) yline(1 `=2*ln(2)')
  ytitle("", axis(2))
  xline(1) xlab(`xlabs');
graph export figseq2.eps, replace;
more;

exit;
