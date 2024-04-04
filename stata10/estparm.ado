#delim ;
prog def estparm, eclass byable(recall);
version 10.0;
/*
  Input variables from the current dataset in memory
  containing estimates and standard errors
  and (optionally) degrees of freedom and numbers of observations.
  Create estimation output in e() with 1 parameter per observation in the sample,
  and estimates and variance matrix copied from the dataset in memory,
  assuming the parameters to be uncorrelated.
  estparm is an inverse to parmest,
  and can be used to create an estimation output in e()
  for input to the test command.
*!Author: Roger Newson
*!Date: 21 April 2008
*/


if(replay()){;
*
 Beginning of replay section (not indented)
*;


if "`e(cmd)'"!="estparm"{;error 301;};
if _by() {;error 190;};
syntax [, EForm(passthru) Level(cilevel)];


*
 Display output
*;
if !missing(e(N)) {;
  disp as text "Valid observations: " as result e(N);
};
if("`e(df_r)'"!=""){;
  disp as text "Degrees of freedom: " as result e(df_r);
};
ereturn display, level(`level');


*
 End of replay section (not indented)
*;
};
else{;
*
 Beginning of non-replay section (not indented)
*;


syntax varlist(numeric min=2 max=3) [if] [in] , [  Level(cilevel) EForm
          Obs(varname numeric) EQ(varname string)    
      ];
/*
Level() contains the confidence level.
EForm indicates that the input estimates are exponentiated,
  and that the input standard errors are multiplied by the exponentiated estimate,
  and that the output confidence limits are to be exponentiated.
Obs() contains the name of the input variable containing numbers of observations
  (defaulting to no variable).
EQ() contains the name of the input string variable containing equation names
  (defaulting to a temporary variable with values equal
  to the string parameter sequence numbers ).
*/


*
 Extract estimates, standard errors and (optionally) degrees of freedom from varlist
*;
local estimate: word 1 of `varlist';
local stderr: word 2 of `varlist';
local dof: word 3 of `varlist';


*
 Mark observations to use
*;
marksample touse;


*
 Set default equation names
*;
if "`eq'"=="" {;
  tempvar eq eqseq;
  qui {;
    gene long `eqseq'=1 if `touse' `in';
    replace `eqseq'=sum(`eqseq') if `touse' `in';
    gene `eq'=string(`eqseq') if `touse' `in';
    drop `eqseq';
  };
};


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
  qui gene double `sestimate' = log(`estimate') if `touse' `in';
  qui gene double `sstderr' = `stderr' / `estimate' if `touse' `in';
};


*
 Create matrices
*;
tempname tempb tempV;
tempvar convarname;
qui {;
  gene `convarname'="_cons" if `touse' `in';
  mkmat `sestimate' if `touse' `in' , matr(`tempb') nomiss roweq(`eq') rowname(`convarname');
  matr def `tempb'=`tempb'';
  matr rownames `tempb' = "y1";
  tempvar svari;
  gene double `svari'=`sstderr'*`sstderr' if `touse' `in';
  mkmat `svari' if `touse' `in' , matr(`tempV') nomiss roweq(`eq') rowname(`convarname');
  matr def `tempV'=diag(`tempV');
};


*
 Create macros obsopt and dofopt
 to be passed as number of observations and degrees of freedom
*;
if "`obs'"!="" {;
  qui {;
    summ `obs' if `touse' `in';
    local obsopt="obs(`=r(sum)')";
  };
};
if "`dof'"!="" {;
  qui {;
    summ `dof' if `touse' `in';
    local dofopt="dof(`=r(sum)')";
  };
};


*
 Save estimation results
*;
ereturn post `tempb' `tempV', `obsopt' `dofopt' prop("b V");
ereturn local predict="estparm_p";
ereturn local cmdline `"estparm `0'"';
ereturn local cmd "estparm";


*
 Display output
*;
if !missing(e(N)) {;
  disp as text "Valid observations: " as result e(N);
};
if("`e(df_r)'"!=""){;
  disp as text "Degrees of freedom: " as result e(df_r);
};
ereturn display, level(`level');


*
 End of non-replay section (not indented)
*;
};


end;
