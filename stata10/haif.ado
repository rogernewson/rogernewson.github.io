#delim ;
prog def haif, rclass byable(recall);
version 10.0;
/*
  Calculate homoskedastic adjustment inflation factors (HAIFs)
  for the coefficients of a list of core predictor variables,
  caused by adjusting for a list of additional variables.
*!Author: Roger B. Newson
*!Date: 13 March 2009
*/

syntax [ varlist(numeric default=none) ] [if] [in] [fweight aweight iweight] ,
  Addvars(varlist numeric min=1) [ noConstant ];
/*
  addvars() specifies the additional variables.
  noconstant specifies that no constant term is included in the core model.
*/

*
 Check that varlists are mutually exclusive
*;
local sharedvars: list varlist & addvars;
if `"`sharedvars'"'!="" {;
  disp as error "The following variables are in the core variable list"
    _n as error "and also in the added variable list:"
    _n as error "`sharedvars'";
  error 498;
};

*
 Mark sample to use
*;
marksample touse, zeroweight;
markout `touse' `addvars';

*
 Count numbers of parameters
*;
local Naddvars: word count `addvars';
local Ncorevars: word count `varlist';
if "`constant'"!="noconstant" {;
  local Ncorevars=`Ncorevars'+1;
};
if `Ncorevars'<1 {;
  disp as error "No columns in the core design matrix";
  error 498;
};

*
 Create row vectors of variances of core model parameters
 for core and full models
*;
tempname Vcore Vfull Nobs;
tempvar Y;
qui gene byte `Y'=0;
qui regress `Y' `varlist' if `touse' [`weight'`exp'] , mse1 `constant';
scal `Nobs'=e(N);
matr def `Vcore'=e(V);
matr def `Vcore'=vecdiag(`Vcore');
qui regress `Y' `addvars' `varlist' if `touse' [`weight'`exp'] , mse1 `constant';
matr def `Vfull'=e(V);
matr def `Vfull'=vecdiag(`Vfull');
local findex=`Naddvars'+1;
local lindex=`Naddvars'+`Ncorevars';
matr def `Vfull'=`Vfull'[1..1,`findex'..`lindex'];

*
 Create output matrix
*;
tempname haifmatrix;
mata: haif_createoutputmatrix("`Vcore'","`Vfull'","`haifmatrix'");

*
 List results
*;
disp as text "Number of observations: " as result `Nobs'
  _n as text "Homoskedastic adjustment inflation factors"
  _n "for variances and standard errors:";
matlist `haifmatrix', noheader noblank nohalf lines(none) names(all) format(%10.0g);

*
 Return results
*;
return matrix haif=`haifmatrix';
return local addvars `"`addvars'"';
return scalar N=`Nobs';

end;

#delim cr
/*
  Private Mata programs
*/
mata:

void haif_createoutputmatrix(string scalar Vcorename, string scalar Vfullname, string scalar haifname)
{
/*
  Input Stata row matrices with names Vcorename and Vfullname,
  containing variances for core parameters in core and full models,
  and output a 2-column Stata matrix with name haifname,
  with 1 row per core parameter,
  and columns containing variance and standard error HAIFs, respectively.
*/

real vector Vcore, Vfull;
real matrix haif;
string matrix haifrowstripe, haifcolstripe;
/*
  Vcore contains the variances under the core model.
  Vfull contains the variances under the full model.
  haif contains the HAIFs for variances and standard errors.
  haifrowstripe and haifcolstripe contain the row and column stripes for haif.  
*/

haifcolstripe=J(2,1,""),("Variance"\"SE");
haifrowstripe=st_matrixcolstripe(Vcorename);
Vcore=st_matrix(Vcorename);
Vfull=st_matrix(Vfullname);
haif=(Vfull:/Vcore)';
haif=haif,sqrt(haif);
st_matrix(haifname,haif);
st_matrixrowstripe(haifname,haifrowstripe);
st_matrixcolstripe(haifname,haifcolstripe);

}

end
