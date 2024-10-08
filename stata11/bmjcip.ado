#delim ;
prog def bmjcip;
version 11.0;
/*
  Replace a list of numeric variables,
  containing estimates, confidence limits and (optionally) P-values,
  with a list of corresponding string variables,
  containing estimates, confidence limits and (optionally) P-values,
  formatted in a way that might be approved
  by the British Medical Journal (BMJ) and other medical journals
  for use in tables.
*!Author: Roger Newson
*!Date: 28 December 2022
*/

* Check dependencies *;
qui _whichlist sdecode msdecode, package(sdecode);
if trim(`"`r(incomplete)'"')=="sdecode" {;
  disp as error "Package sdecode needs to be installed for bmjcip to work";
  disp as error "To install sdecode, type:"
    _n as input "ssc install sdecode";
  error 498;
};

syntax varlist(min=1 max=5) [if] [in] [, CFormat(string) PFormat(string) XMLSub ESub(string) ELZero
  STArvar(varname string) PRefix(string) SUffix(string) PPRefix(string) PSUffix(string)
  REFexp(string asis) REFLabel(string)
  HEadline(string) ];
/*
 cformat() is the format for the confidence limits and estimates.
 pformat() is the format for the P-values and Q-values.
 xmlsub specifies that the substrings "&", &<" and ">" will be substituted
  with the XML entity references "&amp;", "&lt;" and "&gt;", respectively.
 esub() specifies how to substitute strings "e+" and "e-",
   indicating following exponents in confidence limits and P-values.
 elzero specifies that leading zeros in exponents will not be removed.
 starvar() specifies a variable whose values will be appended
   to the P-value (if present) or to the upper confidence limits (otherwise),
   usually containing stars or other footnote references.
 prefix() specifies a prefix string.
 suffix() specifies a suffix string.
 pprefix() specifies a special prefix string for P-values.
 psuffix() specifies a special suffix string for P-values.
 refexp() specifies an expression that will be true if an observation corresponds
   to a reference parameter,
   which cannot have valid confidence limits and P-values.
 reflabel() specifies a label for a reference parameter,
   to be assigned, in reference parameter observations,
   to the decoded lower confidence limit if present,
   and to the decoded P-value otherwise.
 headline gives the name of a variable characteristic
   in which to store the headline cells
   and (optionally) non-default values for these cells.
*/

* Count input variables and assign roles *;
local nvar: word count `varlist';
if `nvar'==1 {;
  local pvalue: word 1 of `varlist';
};
else if `nvar'==2 {;
  local estimate: word 1 of `varlist';
  local pvalue: word 2 of `varlist';
};
else {;
  local estimate: word 1 of `varlist';
  local cimin: word 2 of `varlist';
  local cimax: word 3 of `varlist';
  local pvalue: word 4 of `varlist';
  local qvalue: word 5 of `varlist';
};

* Assign default CI and P formats if necessary *;
if `"`cformat'"'=="" & "`estimate'"!="" {;
  local cformat: format `estimate';
};
if `"`pformat'"'=="" local pformat "%-10.2g";

*
 Set default for esub() and check for illegal values
*;
if `"`esub'"'=="" {;local esub "x10";};
local esub=lower(`"`esub'"');
if !inlist(`"`esub'"',"none","x10","rtfsuper","texsuper","htmlsuper","smclsuper","mdsuper") {;
  disp as error `"Illegal esub(`esub')"';
  error 498;
};

*
 Set default pprefix() and psuffix()
 to prefix() and suffix(), respectively
*;
if `"`pprefix'"'=="" {;local pprefix `"`prefix'"';};
if `"`psuffix'"'=="" {;local psuffix `"`suffix'"';};

marksample touse, novarlist;

*
 Calculate reference status variable if present
*;
if `"`refexp'"'!="" {;
  tempvar refind;
  gene byte `refind'=(`refexp') if `touse';
};

*
 Decode confidence limits and P-value
*;
qui {;
  if "`estimate'"!="" {;
    sdecode `estimate' if `touse' & !missing(`estimate'), format(`cformat') replace ftrim `xmlsub' esub(`esub', `elzero');
  };
  if "`cimin'"!="" {;
    sdecode `cimin' if `touse' & !missing(`cimin'), format(`cformat') replace ftrim `xmlsub' esub(`esub',`elzero') prefix("(") suffix(",");
  };
  if "`cimax'"!="" {;
    sdecode `cimax' if `touse' & !missing(`cimax'), format(`cformat') replace ftrim `xmlsub' esub(`esub',`elzero') suffix(")");
  };
  if "`pvalue'"!="" {;
    sdecode `pvalue' if `touse' & !missing(`pvalue'), format(`pformat') replace `xmlsub' ftrim esub(`esub',`elzero');
    format `pvalue' %-10s;
  };
  if "`qvalue'"!="" {;
    sdecode `qvalue' if `touse' & !missing(`qvalue'), format(`pformat') replace `xmlsub' ftrim esub(`esub',`elzero');
    format `qvalue' %-10s;
  };
};

*
 Insert reference labels if requested
*;
if `"`refexp'"'!="" {;
  if `"`reflabel'"'=="" {;local reflabel="(ref)";};
  if "`cimin'"!="" {;
    qui replace `cimin'=`"`reflabel'"' if `touse' & `refind';
    foreach Y of var `cimax' `pvalue' {;
      qui replace `Y'="" if `touse' & `refind';
    };
  };
  else if "`pvalue'"!="" {;
    qui replace `pvalue'=`"`reflabel'"' if `touse' & `refind';
  };
};

*
 Append star variable if specified
*;
if "`starvar'"!="" {;
  if "`qvalue'"!="" {;
    qui replace `qvalue'=`qvalue'+`starvar' if `touse' & !missing(`qvalue');
  };
  else if "`pvalue'"!="" {;
    qui replace `pvalue'=`pvalue'+`starvar' if `touse' & !missing(`pvalue');
  };
  else if "`cimax'"!="" {;
    qui replace `cimax'=`cimax'+`starvar' if `touse' & !missing(`cimax');
  };
};

*
 Add prefixes and suffixes
*;
foreach STAT in estimate cimin cimax {;
  if "``STAT''"!="" {;
    qui replace ``STAT''=`"`prefix'"'+``STAT''+`"`suffix'"' if `touse';
  };
};
if "`pvalue'"!="" {;
  qui replace `pvalue'=`"`pprefix'"'+`pvalue'+`"`psuffix'"' if `touse';
};
if "`qvalue'"!="" {;
  qui replace `qvalue'=`"`pprefix'"'+`qvalue'+`"`psuffix'"' if `touse';
};

*
 Allocate headline cells if requested
*;
if `"`headline'"'!="" {;
  headline_parse `headline';
  local charname "`r(charname)'";
  local esthead `"`r(estimate)'"';
  local lowhead `"`r(lower)'"';
  local upphead `"`r(upper)'"';
  local pvahead `"`r(pvalue)'"';
  local qvahead `"`r(qvalue)'"';
  if "`estimate'"!="" {;
    char `estimate'[`charname'] `"`esthead'"';
    if `"`esthead'"'=="" {;char `estimate'[`charname'] "Estimate";};
  };
  if "`cimin'"!="" {;
    char `cimin'[`charname'] `"`lowhead'"';
    if `"`lowhead'"'=="" {;
      cap confirm number ``cimin'[level]';
      if _rc==0 {;
        char `cimin'[`charname'] "(`=``cimin'[level]''%";
      };
      else {;
        char `cimin'[`charname'] "(`=`c(level)''%";
      };
    };
  };
  if "`cimax'"!="" {;
    char `cimax'[`charname'] `"`upphead'"';
    if `"`upphead'"'=="" {;char `cimax'[`charname'] "CI)";};
  };
  if "`pvalue'"!="" {;
    char `pvalue'[`charname'] `"`pvahead'"';
    if `"`pvahead'"'=="" {;char `pvalue'[`charname'] "P";};
  };
  if "`qvalue'"!="" {;
    char `qvalue'[`charname'] `"`qvahead'"';
    if `"`qvahead'"'=="" {;char `qvalue'[`charname'] "Q";};
  };
};

end;

prog def headline_parse, rclass;
version 11.0;
/*
  Parse the headline() option.
*/

syntax name [ , Estimate(string) Lower(string) Upper(string) Pvalue(string) Qvalue(string) ];
/*
 estimate() is a user-supplied estimate headline cell.
 lower() is a user-supplied lower confidence limit headline cell.
 upper() is a user-supplied upper confidence limit headline cell.
 pvalue() is a user-supplied P-value headline cell.
 qvalue() is a user-supplied Q-value headline cell.
*/

* Return results *;
return local charname "`namelist'";
return local estimate `"`estimate'"';
return local lower `"`lower'"';
return local upper `"`upper'"';
return local pvalue `"`pvalue'"';
return local qvalue `"`qvalue'"';

end;

prog def _whichlist, rclass;
version 16.0;
/*
 Input a list of which input items
 and optionally a package list
 and output lists of present and absent items
 and complete and incomplete packages.
*/


syntax anything(name=itemlist) [ , Packagelist(namelist) NOIsily ];
*
 packagelist() specifies a list of packages
   for the items to belong to.
 noisily specifies that whichlist will have the output generated by which
   for each item in the item list.
*;
local Nitem: word count `itemlist';

*
 Extend packagelist if required
*;
if "`packagelist'"!="" {;
  local Npackage: word count `packagelist';
  if `Npackage' < `Nitem' {;
    local lastpackage: word `Npackage' of `packagelist';
    forv i1=`=`Npackage'+1'(1)`Nitem' {;
      local packagelist "`packagelist' `lastpackage'";
    };
  };
};


*
 Create present, absent, complete, and incomplete lists
*;
if "`packagelist'"=="" {;
  * Create present and absent lists only *;
  forv i1=1(1)`Nitem' {;
    local itemcur: word `i1' of `itemlist';
    cap `noisily' which `itemcur';
    if _rc local absent `"`absent' `itemcur'"';
    else local present `"`present' `itemcur'"';
  };
};
else {;
  * Create present, absent, complete, and incomplete lists *;
  forv i1=1(1)`Nitem' {;
    local itemcur: word `i1' of `itemlist';
    local packagecur: word `i1' of `packagelist';
    cap `noisily' which `itemcur';
    if _rc {;
      local absent `"`absent' `itemcur'"';
      local incomplete "`incomplete' `packagecur'";
    };
    else {;
      local present `"`present' `itemcur'"';
      local complete "`complete' `packagecur'";
    };
  };
  local incomplete: list uniq incomplete;
  local incomplete: list sort incomplete;
  local complete: list uniq complete;
  local complete: list complete - incomplete;
  local complete: list sort complete;
};
local present: list uniq present;
local present: list sort present;
local absent: list uniq absent;
local absent: list sort absent;


*
 List results
*;
if `"`present'"'!="" {;
  disp as text "Present items:";
  disp as result `"`present'"';
};
if `"`absent'"'!="" {;
  disp as text "Absent items:";
  disp as result `"`absent'"';
};
if "`complete'"!="" {;
  disp as text "Complete packages:";
  disp as result `"`complete'"';
};
if "`incomplete'"!="" {;
  disp as text "Incomplete packages:";
  disp as result `"`incomplete'"';
};


*
 Return results
*;
foreach R in incomplete complete absent present {;
  return local `R' `"``R''"';
};


end;
