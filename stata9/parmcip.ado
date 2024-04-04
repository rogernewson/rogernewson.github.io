#delim ;
prog def parmcip;
version 9.0;
/*
  Input a dataset with 1 obs per parameter
  and variables containing estimates, standard errors
  and (optionally) degrees of freedom.
  Add output variables containing z-statistics or t-statistics,
  confidence limits and P-values.
*! Author: Roger Newson
*! Date: 15 November 2006
*/

syntax [if] [in] [, noTDist EForm FLOAT FAST
      ESTimate(varname) STDerr(varname) Dof(varname)
      Zstat(name) Tstat(name) Pvalue(name)
      STArs(numlist descending >=0 <=1) NSTArs(name)
      LEvel(numlist >=0 <100 sort) CLNumber(string) MINprefix(name) MAXprefix(name)
      replace
      ];
/*
noTDist specifies whether or not a t-distribution is used
  to calculate confidence limits
  (defaulting to tdist if dof() variable exists and to notdist otherwise).
EForm indicates that the input estimates are exponentiated,
  and that the input standard errors are multiplied by the exponentiated estimate,
  and that the output confidence limits are to be exponentiated.
FLOAT specifies that the numeric output variables
  will be created as type float or below.
FAST is an option for programmers, and specifies that no action will be taken
  to restore the original data if the user presses Break.
ESTimate() contains the name of the input variable containing estimates
  (defaulting to "estimate").
STDerr() contains the name of the input variable containing standard errors
  (defaulting to "stderr").
Dof() contains the name of the input variable containing degrees of freedom
  (defaulting to "dof").
Zstat() contains the name of the output variable containing the z-statistics
  (defaulting to "z").
Tstat() contains the name of the output variable containing the t-statistics
  (defaulting to "t").
Pvalue() contains the name of the output variable containing the P-values
  (defaulting to "p").
STArs() specifies a list of P-value thresholds,
  and indicates that the new data set should contain a string variable
  with default name stars,
  containing, in each observation, one star for each P-value threshold alpha
  such that the variable p is less than or equal to alpha.
NSTArs() specifies the name of the output variable containing the stars
  (defaulting to "stars" if stars() is present, and ignored otherwise).
LEvel() specifies the confidence level(s) to be used
  in calculating the lower and upper confidence limits minxx and maxxx
  (defaulting to $S_level if not specified).
CLNumber() specifies the method for numbering the names
  of the lower and upper confidence limit variable names minxx and maxxx,
  and may be level (specifying that xx is the confidence level)
  or rank (specifying that xx is the rank, in ascending order,
  of the confidence level in the set of levels specified in the level option).
MINprefix() specifies the prefix for the lower confidence limits
  (defaulting to "min").
MAXprefix() specifies the prefix for the upper confidence limits
  (defaulting to "max").
replace specifies that generated variables
  should overwrite existing variables of the same names.
*/


*
 Set default input options
*;
if "`estimate'"=="" {;local estimate "estimate";};
if "`stderr'"=="" {;local stderr "stderr";};
if "`dof'"=="" {;local dof "dof";};
if "`tdist'"=="" {;
  cap confirm variable `dof';
  if _rc==0 {;
    local tdist "tdist";
  };
  else {;
    local tdist "notdist";
    disp as text "Note: variable `dof' not found, normal distribution assumed";
  };
};


*
 Set default output options
*;
if "`tdist'"=="notdist" & "`zstat'"=="" {;local zstat "z";};
if "`tdist'"=="tdist" & "`tstat'"==""  {;local tstat "t";};
if "`pvalue'"=="" {;local pvalue "p";};
if "`stars'"!="" & "`nstars'"=="" {;local nstars "stars";};
if "`minprefix'"=="" {;local minprefix "min";};
if "`maxprefix'"=="" {;local maxprefix "max";};


*
 Check for name clashes of output variables
 with input variables and with each other
*;
local invars "`estimate' `stderr'";
if "`tdist'"=="tdist" {;
  local invars "`invars' `dof'";
};
local outvars "";
local iovars "`invars'";
foreach Y in `zstat' `tstat' `pvalue' `nstars' {;
  local clash: list Y in iovars;
  if `clash' {;
    disp _n as error "Clash with output variable name: " as result "`Y'"
      _n as error "Existing input variable names: " as result "`invars'"
      _n as error "Existing output variable names: " as result "`outvars'";
    error 498;
  };
  else {;
    local outvars "`outvars' `Y'";
    local iovars "`iovars' `Y'";
  };
};


*
 Set maximum numeric type according to float option
*;
if "`float'"=="" {;local maxntype "double";};
else {;local maxntype "float";};


*
 Set level to default value
 and set local macro nlevel to number of distinct levels
*;
if "`level'"=="" {;
    local level=c(level);
};
local nlevel:word count `level';


*
 Set clnumber to default value if absent
 and check that it is valid if present
*;
if `"`clnumber'"'=="" {;
    local clnumber "level";
};
if !inlist(`"`clnumber'"',"level","rank") {;
    disp as error `"Invalid clnumber(`clnumber')"';
    error 498;
};


if "`fast'"=="" {;preserve;};


marksample touse;


*
 Define symmetric estimates and standard errors
 for use in calculating test statistics, P-values and confidence limits
 (important if eform option is specified)
*;
if "`eform'"=="" {;
  local sestimate "`estimate'";
  local sstderr "`stderr'";
};
else {;
  tempvar sestimate sstderr;
  qui gene double `sestimate' = log(`estimate') if `touse';
  qui gene double `sstderr' = `stderr' / `estimate' if `touse';
};


* Add t-statistics or z-scores and P-values *;
if "`tdist'"=="notdist" {;
    * Normal distributioon *;
    if "`replace'"!="" {;
      foreach Y in `zstat' `pvalue' {;cap drop `Y';};
    };
    qui gene double `zstat' = `sestimate' / `sstderr' if `touse';
    qui gene double `pvalue' = 2 * normprob(-abs(`zstat')) if `touse';
    if "`maxntype'"!="double" {;
      recast `maxntype' `tstat' `pvalue', force;
    };
    qui compress `tstat' `pvalue';
    label variable `zstat' "Standard normal deviate";
    label variable `pvalue' "P-value";
};
else {;
    * t-distribution *;
    if "`replace'"!="" {;
      foreach Y in `tstat' `pvalue' {;cap drop `Y';};
    };
    qui gene double `tstat' = `sestimate' / `sstderr' if `touse';
    qui gene double `pvalue' = tprob(`dof',`tstat') if `touse';
    if "`maxntype'"!="double" {;
      recast `maxntype' `zstat' `pvalue', force;
    };
    qui compress `zstat' `pvalue';
    label variable `tstat' "t-test statistic";
    label variable `pvalue' "P-value";
};


*
 Add stars for P-values if requested
*;
if `"`stars'"'!="" {;
  if "`replace'"!="" {;cap drop `nstars';};
  qui{;
    gene str1 `nstars'="" if `touse';
    foreach A of numlist `stars' {;
      replace `nstars'=`nstars'+"*" if `touse' & `pvalue'<=`A';
    };
    qui compress `nstars';
    * Choose a default left-justified string format for stars *;
    tempvar numstars;
    gene `numstars'=length(`nstars') if `touse';
    summ `numstars';
    local mstars=max(r(max),1);
    drop `numstars';
    format `nstars' %-`mstars's;
    lab var `nstars' "Stars for P-value";
  };
};


* Add confidence limits *;
tempvar hwid;
local i1=0;
foreach leveli1 of numlist `level' {;
    local i1=`i1'+1;
    if `"`clnumber'"'=="rank" {;
        * Number confidence limits by ascending rank of level *;
        local cimin "`minprefix'`i1'";
        local cimax "`maxprefix'`i1'";
    };
    else {;
        * Number confidence limits by level *;
        *
         Create macro sleveli1 containing string version of leveli1
         to define variable names for confidence limits
        *;
        local sleveli1="`leveli1'";
        local sleveli1=subinstr("`sleveli1'",".","_",.);
        local sleveli1=subinstr("`sleveli1'","-","m",.);
        local sleveli1=subinstr("`sleveli1'","+","p",.);
        local cimin  "`minprefix'`sleveli1'";
        local cimax  "`maxprefix'`sleveli1'";
    };
    * Check for name clashes involving confidence limits *;
    foreach Y in `cimin' `cimax' {;
      local clash: list Y in iovars;
      if `clash' {;
        disp _n as error "Clash with output variable name: " as result "`Y'"
          _n as error "Existing input variable names: " as result "`invars'"
          _n as error "Existing output variable names: " as result "`outvars'";
        error 498;
      };
      else {;
        local outvars "`outvars' `Y'";
        local iovars "`iovars' `Y'";
      };
    };
    * Generate confidence limits *;
    if "`tdist'"=="notdist" {;
        qui gene double `hwid'= `sstderr'*invnorm(1-(100-`leveli1')/200) if `touse';
    };
    else {;
        qui gene double `hwid' = `sstderr'*invttail(`dof',(100-`leveli1')/200) if `touse';
    };
    if "`replace'"!="" {;
      foreach Y in `cimin' `cimax' {;cap drop `Y';};
    };
    qui gene double `cimin' = `sestimate' - `hwid' if `touse';
    qui gene double `cimax' = `sestimate' + `hwid' if `touse';
    * Exponentiate if requested *;
    if "`eform'"!="" {;
      qui replace `cimin' = exp(`cimin') if `touse';
      qui replace `cimax' = exp(`cimax') if `touse';
    };
    if "`maxntype'"!="double" {;
      qui recast `maxntype' `cimin' `cimax', force;
    };
    qui compress `cimin' `cimax';
    drop `hwid';
    label variable `cimin' "Lower `leveli1'% confidence limit";
    label variable `cimax' "Upper `leveli1'% confidence limit";
};


if "`fast'"=="" {;restore, not;};

end;
