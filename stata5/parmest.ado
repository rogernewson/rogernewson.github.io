program define parmest
version 5.0
/*
 If current estimation matrices exist,
 then extract the parameter names, estimates,
 standard errors and confidence limits
 and reformat them as a data set with 1 observation per parameter,
 (replacing the current one, in the manner of the collapse command).
 This program calls programs estse, svroweq and svrown.
 Author: Roger Newson
 Date: 23/02/1999
*/

* Parse options *
local options "Label EForm Dof(integer -1) LEvel(int $S_level)"
local options "`options' FAST SAving(string) noREstore"
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
 (ignored and set to norestore if FAST is present or SAving() is absent,
 and defaulting to restore if SAving() is present).
*/

parse "`*'"

/*
 Parse saving to extract output data set (if any)
*/
if("`saving'"!=""){
    parse "`saving'", parse(",")
    local saving=trim("`1'")
    local replace="`3'"
    if("`replace'"!=""){
        if(lower(substr("`replace'",1,1))!="r"){
            disp in red "Illegal sub-option - `replace'"
            exit 498
        }
    }
}


/*
 Set restore to norestore
 if fast is present or saving() is absent
*/
if(("`fast'"!="")|("`saving'"=="")){
    local restore="norestore"
}


/*
  Reset dof to current estimates if negative
*/
if(`dof'<0){
    quietly test 0=0
    local dof=_result(5)
    if(`dof'==.){
        local dof=0
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
        if _result(1) == _N { drop eq }
}

* Add confidence limits *
local cimin  "min`level'"
local cimax  "max`level'"
tempvar hwid
if `dof' <= 0 {
        gene double z = estimate / stderr
        gene double p = 2 * normprob(-abs(z))
        gene double `hwid'= stderr * invnorm(1 - (100 -  `level') / 200)
        label variable z "Standard normal deviate"
        label variable p "P-value"
}
else {
        gene double t = estimate / stderr
        gene double p = tprob(`dof', t)
        gene double `hwid' = stderr * invt(`dof', `level' / 100)
        label variable t "t-test statistic"
        label variable p "P-value"
}
gene double `cimin' = estimate - `hwid'
gene double `cimax' = estimate + `hwid'
label variable `cimin' "Lower `level'% confidence limit"
label variable `cimax' "Upper `level'% confidence limit"

* EForm transformation if requested *
if "`eform'" != "" {
        qui {
                replace estimate = exp(estimate)
                replace stderr = stderr * estimate
                replace `cimin' = exp(`cimin')
                replace `cimax' = exp(`cimax')
        }
}

/*
 Save data set if requested
*/
if("`saving'"!=""){
    if("`replace'"==""){
        capture save "`saving'"
    }
    else{
        capture save "`saving'", replace
    }
    if(_rc!=0){
        disp in red "Could not save data set `saving'"
        exit 498
    }
}

/*
 Restore old data set if restore is set
 or if program fails when fast is unset
*/
if(("`fast'"=="")&("`restore'"=="norestore")){
    restore,not
}

end

program define estse
version 5.0
/*
 Create output matrix
 with rows corresponding to parameters of last model
 and 1 column each for estimates and standard errors
*/
if "`1'" == "" { local estse "estse"}
else local estse "`1'"

tempname esti cov stderr
* Temporary matrices *
matrix `esti' = get(_b)
matrix `cov' = get(VCE)
matrix `esti' = `esti''
matrix `stderr' = vecdiag(`cov')
matrix `stderr' = `stderr''
local nparm = rowsof(`stderr')
local i1 = 1
while `i1' <= `nparm' {
        matrix `stderr'[`i1',1] = sqrt(`stderr'[`i1',1])
        local i1 = `i1' + 1
}
matrix `estse' = `esti', `stderr'
matrix coln `estse' = estimate stderr
end

program define svroweq
version 5.0
/*
 Save row equation names from matrix `1' in string variable `2'.
 (This routine is designed to be used with svmat.)
*/

local matrix `1'
local roweq `2'
if "`matrix'" == "" {
        di in r "No matrix specified"
        error 498
}
if "`roweq'" == "" {
        di in r "No variable name specified"
        error 498
}
local nrow = rowsof(`matrix')
local names : roweq(`matrix')

* Create variable `roweq' *
qui capture drop `roweq'
qui set obs `nrow'
* qui gene str`len' `roweq' = ""
qui gen str1 `roweq' = ""
local rowind = 0
while `rowind' < `nrow'{
        local rowind = `rowind' + 1
        local namec : word `rowind' of `names'
        qui replace `roweq' = "`namec'" in `rowind'
}

end

program define svrown
version 5.0
/*
 Save row names from matrix `1' in string variable `2'.
 (This routine is designed to be used with svmat.)
*/

local matrix `1'
local rowname `2'
if "`matrix'" == "" {
        di in r "No matrix specified"
        error 498
}
if "`rowname'" == "" {
        di in r "No variable name specified"
        error 498
}
local nrow = rowsof(`matrix')
local names : rownames(`matrix')

* Create variable `rowname' *
qui capture drop `rowname'
qui set obs `nrow'
qui gene str1 `rowname' = ""
local rowind = 0
while  `rowind' < `nrow' {
        local rowind = `rowind' + 1
        local namec : word `rowind' of `names'
        qui replace `rowname' = "`namec'" in `rowind'
}

end
