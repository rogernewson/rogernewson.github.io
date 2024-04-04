#delim ;
version 16.1;
*
 Differences in c-statistics
 with corresponding ratios of interquartile odds ratios
 (assuming an equal-variance normal model)
*;

clear all;
set scheme rbn4mono;

*
 Input differences in c-statistics
*;
#delim cr
input double cdif
0.50
0.25
0.20
0.10
0.05
0.04
0.03
0.02
0.01
0.005
0.004
0.003
0.002
0.001
0.0005
0.0004
0.0003
0.0002
0.0001
0
end
#delim ;
lab var cdif "Difference in c-statistics";
desc, fu;

*
 Compute approximate positive ratios between odds ratios
*;
gene double ror=exp(8*sqrt(2)*(invnorm(0.75))^2 * cdif);
lab var ror "Ratio of interquartile odds ratios";
desc, fu;
list, abbr(32);

exit;
