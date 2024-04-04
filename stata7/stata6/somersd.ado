#delimit ;
program define somersd,eclass;
version 6.0;
/*
 Take, as input, 2 or more variables in varlist,
 comprising 1 x-variate and 1 or more y-variates,
 and, optionally, a flag asking for Kendall's tau-a instead of Somers' D.
 Create, as output, a maximum-likelihood mlout structure,
 with the vector of estimates equal to the vector of Somers' D's
 (or Kendall's tau-a's)
 of each y-variate with respect to the x-variate,
 and the vce matrix equal to their jackknife variance-covariance estimates.
 This program allows fweights, iweights or pweights.
*! Author: Roger Newson
*! Date: 30 May 2005
*/

if(replay()){;
*
 Beginning of replay section (not indented)
*;

if("`e(cmd)'"!="somersd"){;error 301;};
syntax [,Level(integer $S_level) CImatrix(passthru)];

*
 End of replay section (not indented)
*;
};
else{;
*
 Beginning of non-replay section (not indented)
*;

syntax varlist(min=2 max=9999 numeric) [if] [in] [fweight iweight pweight]
  [, TAua CLuster(varname) Level(integer $S_level) TDist
  TRansf(string) CImatrix(passthru) ];

* Initialise local macros to be used again and again *;
local nvar: word count `varlist';
local nvarp=`nvar'+1;local nvarm=`nvar'-1;
local x: word 1 of `varlist';
* Y-variates (including the X-variate) *;
local i1=0;
while(`i1'<`nvar'){;local i1=`i1'+1;
  local y`i1': word `i1' of `varlist';
};
* List of y-variates (other than the X-variate) *;
local i1=1;local nxvlist "";
while(`i1'<`nvar'){;local i1=`i1'+1;
  local nxvlist "`nxvlist' `y`i1''";
};

* Create to-use variable *;
marksample touse;

*
 Define variables containing cluster frequency and importance weights.
 Importance weights are the w_hi in the formulae.
 Cluster frequency weights (f_i for the i'th cluster)
 must be the same for all observations in the same cluster,
 and signify that the i'th cluster in the data set stands
 for f_i identical clusters in the true sample.
 If cluster() is specified,
 then fweights, iweights and pweights are all interpreted
 as importance weights,
 and cluster frequency weights are all set to one.
 If cluster() is not specified,
 then fweights are interpreted as cluster frequency weights
 (and all importance weights are set to one),
 and iweights and pweights are interpreted as importance weights
 (and all cluster frequency weights are set to one).
 This protocol is equivalent to the standard Stata practice
 of treating iweights and pweights as importance weights
 and treating fweights by doing the calculations
 as if there were multiple identical observations in the data set.
 (Stata requires that you cannot specify
 both importance weights and cluster frequency weights,
 and only allows cluster frequency weights for clusters of one,
 but this is a minor limitation of Stata,
 and not a mathematical requirement.)
*;
tempvar cfwei iwei;
if("`cluster'"==""){;
  * At least 1 cluster per obs *;
  if("`weight'"==""){;
    gene byte `cfwei'=1;gene byte `iwei'=1;
  };
  else if("`weight'"=="fweight"){;
    gene long `cfwei'`exp';gene byte `iwei'=1;
  };
  else if(("`weight'"=="iweight")|("`weight'"=="pweight")){;
    gene byte `cfwei'=1;gene double `iwei'`exp';
  };
};
else{;
  * At least 1 obs per cluster *;
  if("`weight'"==""){;
    gene byte `cfwei'=1;gene byte `iwei'=1;
  };
  else if("`weight'"=="fweight"){;
    gene byte `cfwei'=1;gene long `iwei'`exp';
  };
  else if(("`weight'"=="iweight")|("`weight'"=="pweight")){;
    gene byte `cfwei'=1;gene double `iwei'`exp';
  };
};

*
 Preserve data variates
 (they will be subjected to listwise missing value deletion,
 collapsed with respect to clusters,
 and over-written with pseudovalues)
*;
preserve;

*
 Drop unnecessary observations
 to save space and time
*;
quietly keep if(`touse');

*
 Generate number of observations (to be saved as e(N))
 to be sum of frequency weights
 (similar to Stata convention),
 equal to number of clusters if cluster() is not defined
 and number of rows of the analysis data matrix if cluster() is defined
*;
tempvar fwei;
if("`weight'"=="fweight"){;gene long `fwei'`exp'};
else{;gene byte `fwei'=1};
quietly summ `fwei',meanonly;local nobs=r(sum);
drop `fwei';

*
 Abort if no observations
 (to be consistent with the rest of Stata)
*;
if(`nobs'<=0){;error 2000;};

*
 Create cluster sequence variable
*;
tempvar clseq;
if("`cluster'"==""){;
  qui gene long `clseq'=_n;sort `clseq';  
};
else{;
  qui{;
    tempvar seqnum;gene long `seqnum'=_n;
    sort `cluster' `seqnum';
    by `cluster':gene long `clseq'=_n==1;
    replace `clseq'=sum(`clseq');
    sort `clseq' `seqnum';
    drop `seqnum';
  };
};

*
 Drop unnecessary variables,
 and collapse data by combination
 of varlist and summarized importance weight values,
 if data are unclustered,
 or by combination of cluster, varlist
 and summarized importance weight values,
 if data are clustered.
 This is done to save space and time.
*;
quietly{;
  keep `varlist' `cfwei' `iwei' `clseq';
  sort `clseq' `cfwei' `varlist' `iwei';
  collapse (sum) `iwei',by(`clseq' `cfwei' `varlist') fast;
  if("`cluster'"==""){;
    * At least 1 cluster per obs *;
    sort `varlist' `iwei' `cfwei' `clseq';
    collapse (sum) `cfwei',by(`varlist' `iwei') fast;
    gene long `clseq'=_n;order `clseq';
  };
  else{;
    * At least 1 obs per cluster *;
    sort `clseq' `varlist' `iwei';
    collapse (sum) `cfwei',by(`clseq' `varlist' `iwei') fast;
  };
  sort `clseq' `varlist' `iwei';
};

*
 Calculate tidot and vidot variables
 (containing ti... and vi..., respectively,
 in the formulae for Somers' D and Kendall's tau-a)
 collapsing data set by cluster if necessary
 to create new data set with at least 1 cluster per obs
 for input to jackknife variance calculation,
 with cluster frequency weights defined for jackknifing)
*;

*
 Generate product of weights
 (for use when calculating vidot and tidot variables)
*;
tempvar prodwei;gene double `prodwei'=`cfwei'*`iwei';

* Calculate vidot variable *;
tempvar vidot;
quietly{;
  by `clseq':gene double `vidot'=sum(`iwei');
  by `clseq':replace `vidot'=`vidot'[_N];
  summ `prodwei',meanonly;
  replace `vidot'=`iwei'*(r(sum)-`vidot');
};

*
 Create tidot and sij variables
 (the sij variables will contain signed differences
 to be input to vecaccum to create tidot variables)
*;
local i1=0;local tidlist "";local sijlist "";
quietly while(`i1'<`nvar'){;local i1=`i1'+1;
  tempvar tid`i1' sij`i1';
  gene double `tid`i1''=0;gene double `sij`i1''=0;
  local tidlist "`tidlist' `tid`i1''";
  local sijlist "`sijlist' `sij`i1''";
};

*
 Evaluate tidot variables
 (iterating over observations)
*;
if(_N>1){;
  *
   vecaccum will only work if _N>1,
   otherwise tidots will all be zero
  *;
  tempname tidcur;tempvar wvsij1;
  gene double `wvsij1'=0;
  matrix define `tidcur'=J(1,`nvar',0);
  local i1=0;
  quietly while(`i1'<_N){;local i1=`i1'+1;
    * Evaluate sij variables *;
    local i2=0;
    while(`i2'<`nvar'){;local i2=`i2'+1;
      replace `sij`i2''=sign(`y`i2''[`i1']-`y`i2'');
    };
    * Accumulate sij variables (using vecaccum) *;
    replace `wvsij1'=`sij1'*`prodwei'*(`clseq'!=`clseq'[`i1']);
    matrix vecaccum `tidcur'=`wvsij1' `sijlist',noconst;
    * Put weighted sums into tidot variables *;
    local i2=0;
    while(`i2'<`nvar'){;local i2=`i2'+1;
      replace `tid`i2''=`iwei'*`tidcur'[1,`i2'] if(_n==`i1');
    };
  };
};

*
 Collapse data set by cluster (if that is necessary),
 creating new data set with at least 1 cluster per obs
 and cluster frequency weights for jackknifing
 and only the necessary variables for calculating U-statistics
 and their jackknife variance estimates
*;
quietly{;
  if("`cluster'"!=""){;
    * Currently at least 1 obs per cluster *;
    collapse (sum) `vidot' `tidlist',by(`clseq') fast;
    tempvar cfwei;gene byte `cfwei'=1;
  };
  else{;
   keep `clseq' `vidot' `tidlist' `cfwei';
  };
};

*
 Calculate nclust
 (Data set now has at least 1 cluster per obs
 so _N<=`nclust')
*;
quietly summ `cfwei',meanonly;local nclust=r(sum);

*
 Convert the vidot and tidot variables
 to jackknife pseudovalues
 and rename the tidots as the original variates in varlist
 (so the estimate vector and its dispersion matrix
 will be correctly labelled)
*;
quietly{;
  * Convert vidot and tidots to pseudovalues *;
  tempname udotdot;
  if(_N<2){;
    * vecaccum will not work - initialize udotdot to zero *;
    bVzinit `cfwei' `vidot' `tidlist',b(`udotdot');
  };
  else{;
    * vecaccum will work - calculate udotdot *;
    matr vecaccum `udotdot'=`cfwei' `vidot' `tidlist',noconst;
  };
  jpseud `vidot' `udotdot' `nclust';
  local i1=0;
  while(`i1'<`nvar'){;local i1=`i1'+1;
    jpseud `tid`i1'' `udotdot' `nclust';
  };
  local i1=0;
  * Rename tidots *;
  while(`i1'<`nvar'){;local i1=`i1'+1;
    *
     Renaming is done so that it still works
     even if there are repeats in the varlist
    *;
    capture drop `y`i1'';rename `tid`i1'' `y`i1'';
  };
};

*
 Create estimates and dispersion matrix of V and T(XY)
 in matrices b and vce
*;
tempname b vce factor;
if(_N<2){;
  * Initialize estimates and dispersion matrix to zero *;
  bVzinit `x' `vidot' `varlist',b(`b') v(`vce');
};
else{;
  * accum will work - set estimates and dispersion matrix *;
  quietly matr accum `vce'=`vidot' `varlist' [fweight=`cfwei']
   ,means(`b') noconst dev;
  matr rownames `b'="y1";
};
if(`nclust'<2){;
  * Less than 2 clusters, so set dispersion matrix to zero *;
  matr `vce'=0*`vce';
};
else{;
  * 2 or more clusters, so scale dispersion matrix *;
  matr `vce'=(1/(`nclust'-1))*`vce';matr `vce'=(1/(`nclust'))*`vce';
};

* Restore old data (discarding pseudovalues) *;restore;

*
 Convert V and T(XY) to Kendall's tau-a or Somers' D
 (setting matrices to zero if they are undefined,
 as Stata 6.0 does not permit missing values in matrices)
*;
if("`taua'"!=""){;
  * Kendall's tau-a *;
  local param "taua";local parmlab "Kendall's tau-a";
  tempname V invV invsqV transm transm1 transm2;
  matr `V'=`b'[1,"`vidot'"];scal `V'=trace(`V');
  if(`V'==0){;
    * Sum total of weights is zero, so set matrices to zero *;
    matr `vce'=0*`vce'[2...,2...];
    matr `b'=0*`b'[1,2...];
  };
  else{;
    * Some nonzero weights, so transform matrices *;
    scal `invV'=1/`V';scal `invsqV'=`invV'*`invV';
    matr `transm1'=(`b'[1,2...])';
    matr `transm1'=-`invsqV'*`transm1';
    matr `transm2'=`invV'*I(`nvar');
    matr `transm'=`transm1',`transm2';
    matr `vce'=`transm'*`vce'*`transm'';
    matr `vce'=0.5*(`vce'+`vce'');
    matr `b'=`invV'*`b'[1,2...];
  };
};
else{;
  * Somers' D *;
  local param "somersd";local parmlab "Somers' D";
  tempname T invT invsqT transm transm0 transm1 transm2;
  matr `T'=`b'[1,"`x'"];scal `T'=trace(`T');
  if(`T'==0){;
    * All valid x-pairs are equal, so set matrices to zero *;
    matr `vce'=0*`vce'[3...,3...];
    matr `b'=0*`b'[1,3...];
  };
  else{;
    * Some valid unequal x-pairs, so transform matrices *;
    scal `invT'=1/`T';scal `invsqT'=`invT'*`invT';
    matr `transm1'=(`b'[1,3...])';
    matr `transm0'=0*`transm1';
    matr `transm1'=-`invsqT'*`transm1';
    matr `transm2'=`invT'*I(`nvar'-1);
    matr `transm'=`transm0',`transm1',`transm2';
    matr `vce'=`transm'*`vce'*`transm'';
    matr `vce'=0.5*(`vce'+`vce'');
    matr `b'=`invT'*`b'[1,3...];
  };
};

* Post estimation results *;
if("`tdist'"==""){;
  *
   Normal distribution assumed
  *;
  estimates post `b' `vce',depname("`x'") esample(`touse') obs(`nobs');
};
else{;
  *
   Student's t-distribution with df one less than number of clusters
  *;
  local nclustm=`nclust'-1;
  estimates post `b' `vce',depname("`x'") esample(`touse') obs(`nobs')
   dof(`nclustm');
};
estimates scalar N_clust=`nclust';
estimates local cmd "somersd";
estimates local param "`param'";
estimates local parmlab "`parmlab'";
estimates local tdist "`tdist'";
estimates local depvar "`x'";
estimates local clustvar "`cluster'";
estimates local vcetype "Jackknife";
estimates local wtype "`weight'";
estimates local wexp "`exp'";
estimates local predict "somers_p";

* Transform if necessary *;
if("`transf'"==""){;local transf="iden";};
capture corrtran,transf(`transf');
if(_rc==0){;
  * Beginning of section amended for Stata 7 compatibility 24 Jan 2001 *;
  matr  `b'=r(b);matr `vce'=r(V);
  estimates repost b=`b' V=`vce';
  * End of section amended for Stata 7 compatibility 24 Jan 2001 *;
  estimates local transf="`r(transf)'";
  estimates local tranlab="`r(tranlab)'";
};

*
 End of non-replay section (not indented)
*;
};

* Check that confidence level is within range *;
if((`level'<10)|(`level'>99)){;
  disp in red "Level must be between 10 and 99 inclusive";
  exit 198;
};

*
 Display output
*;

* CI label *;
if(("`transf'"=="z")|("`transf'"=="asin")){;
  local cilab "Symmetric `level'% CI for transformed `e(parmlab)'";
};
else if("`transf'"=="zrho"){;
  local cilab "Symmetric `level'% CI for transformed Greiner's rho";
};
else if ("`transf'"=="c") | ("`transf'"=="roc") | ("`transf'"=="auroc") {;
  local cilab "Symmetric `level'% CI for Harrell's c";
};
else{;
  local cilab "Symmetric `level'% CI";
};

* Display symmetric CI *;
disp in green "`e(parmlab)' with variable: `e(depvar)'";
disp in green "Transformation: `e(tranlab)'";
disp in green "Valid observations: " in yellow e(N);
if("`e(clustvar)'"!=""){;
  disp in green "Number of clusters: " in yellow e(N_clust);
};
if("`e(tdist)'"!=""){;
  disp in green "Degrees of freedom: " in yellow e(df_r);
};
disp in green _n "`cilab'";
estimates display,level(`level');

* Back-transformed parameters if appropriate *;
parmtran,level(`level') `cimatri';

end;

program define jpseud;
version 6.0;
args uidot udotdot nclust;
*
 Transform uidot to jackknife pseudovalues
 using vector of totals in udotdot
 and number of clusters in nclust
*;
tempname uddcur;
matr `uddcur'=`udotdot'[1,"`uidot'"];scal `uddcur'=trace(`uddcur');
if(`nclust'<2){;quietly replace `uidot'=0;};
else if(`nclust'==2){;
  *
   All pseudovalues to be set equal to the U-statistic
   (zero jackknife variance)
  *;
  quietly replace `uidot'=`uddcur'/2;
};
else{;
  * More than 2 clusters - pseudovalues fully valid *;
  quietly replace `uidot'=`uddcur'/(`nclust'-1)
   - (`uddcur'-2*`uidot')/(`nclust'-2);
};

end;

program define bVzinit;
version 6.0;
syntax varlist(min=2 max=9999) [, B(string) V(string) ];
*
 Take varlist as input
 and create, as output, matrices `b' and `v',
 with row and column names as for regression coefficients
 and covariance matrix respectively,
 but initialized to zero.
 (This is necessary because Stata's matrix accumulation commands
 do not work if _N<1.)
*;

local y:word 1 of `varlist';
local nvar:word count of `varlist';local nxvar=`nvar'-1;
local i1=1;local xvlist "";

* Create list of "x-variates" *;
while(`i1'<`nvar'){;local i1=`i1'+1;
  local xvcur:word `i1' of `varlist';
  local xvlist "`xvlist' `xvcur'";
};

* Create "regression coefficient matrix" *;
if("`b'"!=""){;
  matr def `b'=J(1,`nxvar',0);
  matr rownames `b'="y1";matrix colnames `b'=`xvlist';
};

* Create "covariance matrix" *;
if("`v'"!=""){;
  matr `v'=J(`nxvar',`nxvar',0);
  matr rownames `v'=`xvlist';matrix colnames `v'=`xvlist';
};

end;

program define corrtran,rclass;
version 6.0;
*
 Transform a vector of correlation coefficients from e(b)
 and its dispersion matrix in e(V)
 using the transformation specified in transf
*;
syntax [, TRansf(string) ];

* Identify transformation (collapsing synonyms) *;
if(("`transf'"=="z")|("`transf'"=="harctan")|("`transf'"=="hatan")){;
  local transf="z";local tranlab="Fisher's z";
};
else if(("`transf'"=="arcsin")|("`transf'"=="arsin")
 |("`transf'"=="asin")){;
  local transf="asin";local tranlab="Daniels' arcsine";
};
else if(("`transf'"=="sinph")|("`transf'"=="rho")){;
  local transf="rho";local tranlab="Greiner's rho";
};
else if(("`transf'"=="zsinph")|("`transf'"=="zrho")){;
  local transf="zrho";local tranlab="z-transform of Greiner's rho";
};
else if ("`transf'"=="c") | ("`transf'"=="roc") | ("`transf'"=="auroc") {;
  local transf="c";local tranlab="Harrell's c";
};
else{;
  if(("`transf'"!="")&("`transf'"!="iden")){;
    disp "Unrecognized transformation - identity assumed";
  };
  local transf="iden";local tranlab="Untransformed";
};

* Abort if no estimation results *;
if("`e(cmd)'"==""){;
  disp in red "No estimation results present";
  error 301;
};

* Get matrices *;
tempname b vce;matr `b'=e(b);matrix `vce'=e(V);

*
 Set maximum absolute value for coefficients
 (because of danger of missing transformed values
 which cannot be inserted into Stata matrices)
*;
local tranlst="iden z asin rho zrho c";
tempname rmaxlst rmax;
matr def `rmaxlst'=(1,0.999999999999999,0.999999999999999,1,0.99999999,1);
matr colnames `rmaxlst'=`tranlst';
matr `rmax'=`rmaxlst'[1,"`transf'"];scal `rmax'=trace(`rmax');

local ncolb=colsof(`b');
* Initialize matrix of derivatives to zero *;
tempname dtran;matr `dtran'=0*`vce';
local i1=0;
while(`i1'<`ncolb'){;local i1=`i1'+1;
  tempname ri1 dri1;
  scal `ri1'=`b'[1,`i1'];
  * Set correlation to maximum if unity not allowed *;
  if(abs(`ri1')>`rmax'){;
    scal `ri1'=sign(`ri1')*`rmax';
  };
  * Calculate transformation and its derivative *;
  if("`transf'"=="z"){;
    scal `dri1'=1/(1-`ri1'*`ri1');
    scal `ri1'=0.5*(log(1+`ri1')-log(1-`ri1'));
  };
  else if("`transf'"=="asin"){;
    scal `dri1'=1/sqrt(1-`ri1'*`ri1');
    scal `ri1'=asin(`ri1');
  };
  else if("`transf'"=="rho"){;
    scal `dri1'=0.5*_pi*cos(0.5*_pi*`ri1');
    scal `ri1'=sin(0.5*_pi*`ri1');
  };
  else if("`transf'"=="zrho"){;
    * Apply sinph transform first *;
    scal `dri1'=0.5*_pi*cos(0.5*_pi*`ri1');
    scal `ri1'=sin(0.5*_pi*`ri1');
    * Then superimpose z-transform *;
    scal `dri1'=`dri1'/(1-`ri1'*`ri1');
    scal `ri1'=0.5*(log(1+`ri1')-log(1-`ri1'));
  };
  else if "`transf'"=="c" {;
    scal `dri1'=0.5;
    scal `ri1'=0.5*(`ri1'+1);
  };
  else{;
    * Identity transform *;
    scal `dri1'=1;
  };
  * Insert transformation results into matrices *;
  matr `dtran'[`i1',`i1']=`dri1';matr `b'[1,`i1']=`ri1';
};

* Transform dispersion matrix *;
if("`transf'"!="iden"){;matr `vce'=`dtran'*`vce'*`dtran';};

* Return values *;
return local transf "`transf'";
return local tranlab "`tranlab'";
return matrix b `b';
return matrix V `vce';

end;

program define parmtran;
version 6.0;
*
 Take confidence level and estimation output as input
 and create, as results output,
 a matrix containing asymmetric CIs for the untransformed parameters
 (which will be listed if appropriate)
*;
syntax [,Level(integer $S_level) CImatrix(string)];
local transf="`e(transf)'";

* Create matrices containing estimates and standard errors *;
tempname btran sebtran se;
matr `btran'=(e(b))';matr `sebtran'=(vecdiag(e(V)))';
local nparam=rowsof(`btran');
local i1=0;
while(`i1'<`nparam'){;local i1=`i1'+1;
  scal `se'=`sebtran'[`i1',1];
  matr `sebtran'[`i1',1]=sqrt(`se');
};

* Define multiplier for creation of confidence intervals *;
tempname mult clfloat;
scal `clfloat'=`level'/100;
if("`e(tdist)'"!=""){;
  * Student's t-distribution *;
  local dof=e(df_r);
  scal `mult'=invt(`dof',`clfloat');
};
else{;
  * Normal distribution *;
  scal `mult'=invnorm(0.5*(1+`clfloat'));
};

* Create upper and lower confidence limits *;
tempname hwid min max ci;
matr `hwid'=`mult'*`sebtran';
matr `min'=`btran'-`hwid';
matr `max'=`btran'+`hwid';
matr `ci'=`btran',`min',`max';
if(("`transf'"=="rho")|("`transf'"=="zrho")){;
  matr colnames `ci'=Rho Minimum Maximum;
};
else if("`e(param)'"=="somersd"){;
  matr colnames `ci'=Somers_D Minimum Maximum;
};
else if("`e(param)'"=="taua"){;
  matr colnames `ci'=Tau_a Minimum Maximum;
};
else{;
  matr colnames `ci'=Estimate Minimum Maximum;
};

* Carry out inverse transformation if appropriate *;
local ncci=colsof(`ci');tempname r halfpi;
scal `halfpi'=_pi/2;
local i1=0;
while(`i1'<`nparam'){;local i1=`i1'+1;
  local i2=0;
  while(`i2'<`ncci'){;local i2=`i2'+1;
    scal `r'=`ci'[`i1',`i2'];
    if(("`transf'"=="z")|("`transf'"=="zrho")){;
      scal `r'=exp(2*`r');scal `r'=(`r'-1)/(`r'+1);
    };
    else if("`transf'"=="asin"){;
      * Convert out-of-range arcsines to + or - pi/2 *;
      if(`r'<-`halfpi'){;scal `r'=-`halfpi';};
      else if(`r'>`halfpi'){;scal `r'=`halfpi';};
      scal `r'=sin(`r');
    };
    matr `ci'[`i1',`i2']=`r';
  };
};  

* CI label *;
if(("`transf'"=="z")|("`transf'"=="asin")){;
  local cilab "Asymmetric `level'% CI for untransformed `e(parmlab)'";
};
else if("`transf'"=="zrho"){;
  local cilab "Asymmetric `level'% CI for untransformed Greiner's rho";
};
else{;
  local cilab "`level'% CI";
};

* Save confidence interval to output matrix if appropriate *;
if("`cimatri'"!=""){;matr `cimatri'=`ci';};

* List confidence interval if appropriate *;
if(("`transf'"=="z")|("`transf'"=="asin")|("`transf'"=="zrho")){;
  disp in green _n "`cilab'";matr list `ci',noheader noblank;
};

end;
