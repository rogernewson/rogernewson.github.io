#delimit ;
program define somersd;
version 5.0;
*
 Take, as input, 2 or more variables in varlist,
 comprising 1 x-variate and 1 or more y-variates,
 and, optionally, a flag asking for Kendall's tau-a instead of Somers' D.
 Create, as output, a maximum-likelihood mlout structure,
 with the vector of estimates equal to the vector of Somers' D's
 of each y-variate with respect to the x-variate,
 and the vce matrix equal to their jackknife variance-covariance estimates.
 This program allows fweights.
 This program calls the programs tidot and ujack.
*;
local varlist "required existing min(2)";
local weight "fweight";
local options "Taua";
parse "`*'";

* Initialise local macros to be used again and again *;
local nvar: word count `varlist';local nyvar=`nvar'-1;
local x: word 1 of `varlist';

*
 Preserve data variates
 (they will be subjected to listwise missing value deletion
 and over-written with pseudovalues)
*;
preserve;

*
 Create variable containing weight expression
 (before data are mangled by missing value exclusion
 and overwritten with pseudovalues)
*;
tempvar wt;
if("`exp'"==""){gene `wt'=1;};else{gene `wt'`exp';};

* Perform listwise deletion of observations with missing values *;
tempvar valid;gene `valid'=1;local i1=0;
quietly while(`i1'<`nvar'){local i1=`i1'+1;local y:word `i1' of `varlist';
  replace `valid'=0 if(`y'==.);
};
quietly keep if(`valid');drop `valid';

* Initialise scalar nobs containing number of observations *;
tempname nobs;
quietly summ `x' [fweight=`wt'],meanonly;scal `nobs'=_result(1);

*
 Overwrite varlist with pseudovalues
 (iterating from last to first, so as to overwrite x-variate last)
*;
tempvar pseud;local i1=`nvar'+1;
quietly while(`i1'>1){local i1=`i1'-1;local y:word `i1' of `varlist';
  tidot `y' `x' [fweight=`wt'],tidot(`pseud');
  replace `y'=`pseud';drop `pseud';
  ujack `y' [fweight=`wt'],pseud(`pseud') degree(2);
  replace `y'=`pseud';drop `pseud';
};

*
 Create vector of tau-a's and their dispersion matrix
 in matrices b and vce
*;
tempname b vce factor;
quietly matr accum `vce'=`varlist' [fweight=`wt'],means(`b') noconst dev;
scal `factor'=1/(`nobs'-1);matr `vce'=`factor'*`vce';
scal `factor'=1/`nobs';matr `vce'=`factor'*`vce';

* Restore old data (discarding pseudovalues) *;restore;

*
 Convert tau-a to Somers' D
*;
if("`taua'"==""){
  tempname tauxx invt invsqt transf transf1 transf2;
  scal `tauxx'=`b'[1,1];scal `invt'=1/`tauxx';scal `invsqt'=`invt'*`invt';
  matr `transf'=0*`vce';
  matr `transf1'=I(`nvar');matr `transf1'=`invt'*`transf1';
  matr `transf'=`transf'+`transf1';
  matr `transf1'=`b'';matr `transf1'=`invsqt'*`transf1';
  matr `transf2'=J(`nvar',`nyvar',0);matr `transf1'=`transf1',`transf2';
  matr `transf'=`transf'-`transf1';
  matr `vce'=`transf'*`vce';matr `transf'=`transf'';matr `vce'=`vce'*`transf';
  matr `b'=`invt'*`b';
  matr drop `transf' `transf1' `transf2';
  matr `b'=`b'[1,2..`nvar'];
  matr `vce'=`vce'[2..`nvar',2..`nvar'];
};

* Post new matrices and set global macros *;
local obs=`nobs';local dof=`nobs'-1;
matr post `b' `vce',depname(`x') obs(`obs') dof(`dof');
global S_E_cmd="somersd";
global S_E_tdf=`dof';global S_E_nobs=`obs';
global S_E_depv="`x'";global S_E_vce="Jackknife";

* Print output *;
if("`taua'"==""){disp in green "Somers' D";};
else{disp in green "Kendall's tau-a";};
disp in green "Valid observations: " in yellow "`obs'";
disp in green "Degrees of freedom: " in yellow "`dof'";
matrix mlout;

end;
