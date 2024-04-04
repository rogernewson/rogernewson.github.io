program define parmest,rclass
version 6.0
/*
 If current estimation matrices exist,
 then extract the parameter names, estimates,
 standard errors and confidence limits
 and reformat them as a data set with 1 observation per parameter,
 (replacing the current one, in the manner of the collapse command,
 unless the user specifies otherwise).
 This program calls programs estse, svroweq and svrown.
 Author: Roger Newson
 Date: 2 April 2002
*/
syntax [, Label EForm Dof(real -1) LEvel(numlist integer >=1 <=99) /*
    */ FAST SAving(string asis) noREstore /*
    */ EMac(string asis) EScal(string asis) EVec(string asis) /*
    */ IDNum(string) IDStr(string) FList(string) /*
    */ REName(string) ]
/*
 Dof contains residual DF for t-based confidence limits.
 In default, it is set to the value
 from the currently stored estimation results.
 If dof is zero, then normal confidence limits are calculated.
 Label indicates that the new data set
 should contain a variable named label,
 containing labels corresponding to variables named in parm
 (wherever such variables exist in the pre-existing data set).
 EForm indicates that the estimates and confidence limits
 are to be exponentiated, and the standard errors multiplied
 by the exponentiated estimate.
 FAST specifies that parmest not preserve the original data set
 so that it can be restored if the user presses Break
 (intended for use by programmers).
 SAving specifies a data set in which to save the output data set.
 noREstore specifies whether or not the pre-existing data set
 is restored after the new data set has been produced
 (ignored and set to norestore
 if FAST is present or SAving() is absent,
 and defaulting to restore if SAving() is present).
 EMac is a list of macro estimation results
 to be saved in string variables with names em_xx.
 EScal is a list of scalar estimation results
 to be saved in numeric variables with names es_xx.
 EVec is a list of matrix estimation results
 to be converted to column vectors
 and saved in numeric variables with names ev_xx.
 IDNum is an ID number for the model fit,
 used to create a numeric variable idnum in the output data set
 with the same value for all observations
 (this is useful if the output data set is concatenated
 with other parmest output data sets using append).
 IDStr is an ID string for the model fit,
 used to create a string variable idstr in the output data set
 with the same value for all observations
 (a parmest output may have idnum, idstr, both or neither).
 FList is a global macro name,
 belonging to a macro containing a filename list (possibly empty),
 to which parmest will append the name of the data set
 specified in the SAving() option
 (this enables the user to build a list of filenames
 in a global macro,
 containing the output of a sequence of model fits,
 which may later be concatenated using append).
 REName contains a list of alternating old and new variable names,
 so the user can rename variables in the output data set
 to avoid name clashes (eg with by-variables).
*/


/*
 Set level to default value
 and set local macro nlevel to number of distinct levels
*/
if "`level'"=="" {
    local level=$S_level
}
local nlevel:word count `level'


/*
 Set restore to norestore
 if fast is present or saving() is absent
*/
if(("`fast'"!="")|(`"`saving'"'=="")){
    local restore="norestore"
}


/*
  Reset dof to current estimates if negative
*/
if(`dof'<0){
    if "`e(df_r)'" == "" {
        local dof=0
    }
    else {
        local dof=`e(df_r)'
    }
}


/*
 Create matrix of estimates and SEs if possible,
 and extract observations and degrees of freedom into local macros
 for creation of confidence limits
*/
tempname estse
capture estse `estse'
if _rc != 0 {
        di in r "Data will not be replaced"
        if _rc == 301 { error 301 }
        else {
                di in r "Estimates and SEs could not be extracted"
                exit 498
        }
}

/*
 Store variable labels in macros with names of form labi1
 if label requested
*/

if "`label'" != "" {
        local xvlist : rownames(`estse')
        local nxv : word count `xvlist'
        local i1 = 0
        while `i1' < `nxv' {
                local i1 = `i1' + 1
                local xvcur : word `i1' of `xvlist'
                local lab`i1' ""
                capture local lab`i1' : variable label `xvcur'
        }
}

/*
 Preserve old data set if restore is set or fast unset
*/
if("`fast'"==""){
    preserve
}

* Create new data set *
drop _all
svroweq `estse' eq
svrown `estse' parm
svmat double `estse', name(col)
local nparm=_N
label variable eq "Equation name"
label variable parm "Parameter name"
label variable estimate "Parameter estimate"
label variable stderr "SE of parameter estimate"

* Add label if requested *
if "`label'" != "" {
        qui gene str1 label = ""
        local i1 = 0
        while `i1' < `nxv' {
                local i1 = `i1' + 1
                qui replace label = "`lab`i1''" in `i1'
        }
        order eq parm label
        label variable label "Parameter label"
}


* Drop variable eq if it contains only underscores *
qui {
        count if eq == "_"
        if r(N) == _N { drop eq }
}

* Add z-scores and P-values *
if `dof' <= 0 {
    qui gene double z = estimate / stderr
    qui gene double p = 2 * normprob(-abs(z))
    label variable z "Standard normal deviate"
    label variable p "P-value"
}
else {
    qui gene double t = estimate / stderr
    qui gene double p = tprob(`dof',t)
    label variable t "t-test statistic"
    label variable p "P-value"
}

* Add confidence limits *
tempvar hwid
local i1=0
while `i1'<`nlevel' {
    local i1=`i1'+1
    local leveli1:word `i1' of `level'
    local cimin  "min`leveli1'"
    local cimax  "max`leveli1'"
    if `dof' <= 0 {
        qui gene double `hwid'= stderr*invnorm(1-(100-`leveli1')/200)
    }
    else {
        qui gene double `hwid' = stderr*invt(`dof',`leveli1'/100)
        * In Stata 7, the previous line would be:
        * qui gene double `hwid' = stderr*invttail(`dof',(100-`leveli1')/200)
        * Roger Newson 2 April 2002
    }
    qui gene double `cimin' = estimate - `hwid'
    qui gene double `cimax' = estimate + `hwid'
    drop `hwid'
    label variable `cimin' "Lower `leveli1'% confidence limit"
    label variable `cimax' "Upper `leveli1'% confidence limit"
}

/*
 EForm transformation if requested
*/
if "`eform'" != "" {
        qui {
                replace estimate = exp(estimate)
                replace stderr = stderr * estimate
                local i1=0
                while `i1'<`nlevel' {
                    local i1=`i1'+1
                    local leveli1:word `i1' of `level'
                    local cimin  "min`leveli1'"
                    local cimax  "max`leveli1'"
                    replace `cimin' = exp(`cimin')
                    replace `cimax' = exp(`cimax')
                }
        }
}

/*
 Create numeric and/or string ID variables if requested
 and move them to the beginning of the variable order
*/
if("`idstr'"!=""){
    qui gene str1 idstr=" "
    qui replace idstr="`idstr'"
    qui compress idstr
    qui order idstr
    lab var idstr "String ID"
}
if("`idnum'"!=""){
    qui gene double idnum=real("`idnum'")
    qui compress idnum
    qui order idnum
    lab var idnum "Numeric ID"
}

/*
 Create scalar estimation result variables if requested
*/
if `"`escal'"'!="" {
    local nescal:word count `escal'
    local i1=0
    while `i1'<`nescal' {
        local i1=`i1'+1
        local escur:word `i1' of `escal'
        qui gene double es_`i1'=e(`escur')
        qui compress es_`i1'
        lab var es_`i1' `"e(`escur')"'
    }
}

/*
 Create macro estimation result variables if requested
*/
local strmax=80
if `"`emac'"'!="" {
    local nemac:word count `emac'
    local i1=0
    while `i1'<`nemac' {
        local i1=`i1'+1
        local emcur:word `i1' of `emac'
        qui gene str`strmax' em_`i1'=`"`e(`emcur')'"'
        qui compress em_`i1'
        lab var em_`i1' `"e(`emcur')"'
    }
}

/*
 Create vector estimation result variables if requested
*/
if `"`evec'"'!="" {
    tempname emcur
    local nevec:word count `evec'
    local i1=0
    while `i1'<`nevec' {
        local i1=`i1'+1
        local evcur:word `i1' of `evec'
        cap matrix define `emcur'=e(`evcur')
        if _rc!=0 {
                qui gene byte ev_`i1'=.
        }
        else {
            local nrcur=rowsof(`emcur')
            local nccur=colsof(`emcur')
            * Convert matrix to column vector if necessary *
            if (`nrcur'==`nparm')&(`nccur'==`nparm') {
                matrix define `emcur'=vecdiag(`emcur')
                matrix define `emcur'=`emcur''
            }
            else if `nccur'==`nparm' {
                matrix define `emcur'=`emcur''
                matrix define `emcur'=`emcur'[1..`nccur',1]
            }
            else if `nrcur'==`nparm' {
                matrix define `emcur'=`emcur'[1..`nrcur',1]
            }
            else if `nrcur'>`nparm' {
                matrix define `emcur'=`emcur'[1..`nparm',1]
            }
            else {
                matrix define `emcur'=`emcur'[1..`nrcur',1]
            }
            matr colnames `emcur'="ev_`i1'"
            svmat double `emcur',name(col)
            qui compress ev_`i1'
        }
        lab var ev_`i1' `"e(`evcur')"'
    }
}

/*
 Rename variables if requested
*/
if "`rename'"!="" {
    local nrename:word count `rename'
    if mod(`nrename',2) {
        disp in green "Warning: odd number of variable names in rename list - last one ignored"
        local nrename=`nrename'-1
    }
    local nrenp=`nrename'/2
    local i1=0
    while `i1'<`nrenp' {
        local i1=`i1'+1
        local i3=`i1'+`i1'
        local i2=`i3'-1
        local oldname:word `i2' of `rename'
        local newname:word `i3' of `rename'
        cap{
            confirm var `oldname'
            confirm new var `newname'
        }
        if _rc!=0 {
            disp in green "Warning: it is not possible to rename `oldname' to `newname'"
        }
        else {
            rename `oldname' `newname'
        }
    }
}

/*
 Save data set if requested
*/
if(`"`saving'"'!=""){
    capture noisily save `saving'
    if(_rc!=0){
        disp in red `"saving(`saving') invalid"'
        exit 498
    }
    tokenize `"`saving'"',parse(" ,")
    local fname `"`1'"'
    if(index(`"`fname'"'," ")>0){
        local fname `""`fname'""'
    }
    * Add filename to file list in FList if requested *
    if(`"`flist'"'!=""){
        if(`"$`flist'"'==""){
            global `flist' `"`fname'"'
        }
        else{
            global `flist' `"$`flist' `fname'"'
        }
    }
}

/*
 Restore old data set if restore is set
 or if program fails when fast is unset
*/
if(("`fast'"=="")&("`restore'"=="norestore")){
    restore,not
}

/*
 Return saved results
*/
return local eform "`eform'"
return local level "`level'"
return scalar nparm=`nparm'
return scalar dof=`dof'

end

program define estse
version 6.0
/*
 Create output matrix
 with rows corresponding to parameters of last model
 and 1 column each for estimates and standard errors
*/
args estse
if "`estse'" == "" { local estse "estse"}

tempname esti cov stderr vari
* Temporary matrices *
capture matrix `esti' = e(b)
matrix `cov' = e(V)
matrix `esti' = `esti''
matrix `stderr' = vecdiag(`cov')
matrix `stderr' = `stderr''
local nparm = rowsof(`stderr')
local i1 = 0
while `i1' < `nparm' {
        local i1 = `i1' + 1
        scal `vari'=`stderr'[`i1',1]
        if `vari' < 0 {
                matrix `stderr'[`i1',1] = 0
        }
        else {
                matrix `stderr'[`i1',1] = sqrt(`vari')
        }
}
matrix `estse' = `esti', `stderr'
matrix coln `estse' = estimate stderr
end

program define svroweq
version 6.0
/*
 Save row equation names from `matrix' in string variable `roweq'.
 (This routine is designed to be used with svmat.)
*/
args matrix roweq

if "`matrix'" == "" {
        di in r "No matrix specified"
        error 498
}
if "`roweq'" == "" {
        di in r "No variable name specified"
        error 498
}
local nrow = rowsof(`matrix')

* Create variable `roweq' *
tempname tempmat
qui capture drop `roweq'
qui set obs `nrow'
qui gen str1 `roweq' = ""
local rowind = 0
while `rowind' < `nrow'{
        local rowind = `rowind' + 1
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1]
        local namec : roweq(`tempmat')
        qui replace `roweq' = "`namec'" in `rowind'
}

end

program define svrown
version 6.0
/*
 Save row names from `matrix' in string variable `rowname'.
 (This routine is designed to be used with svmat.)
*/
args matrix rowname

if "`matrix'" == "" {
        di in r "No matrix specified"
        error 498
}
if "`rowname'" == "" {
        di in r "No variable name specified"
        error 498
}
local nrow = rowsof(`matrix')

* Create variable `rowname' *
tempname tempmat
qui capture drop `rowname'
qui set obs `nrow'
qui gene str1 `rowname' = ""
local rowind = 0
while  `rowind' < `nrow' {
        local rowind = `rowind' + 1
        matr def `tempmat'=`matrix'[`rowind'..`rowind',1..1]
        local namec : rownames(`tempmat')
        qui replace `rowname' = "`namec'" in `rowind'
}

end
