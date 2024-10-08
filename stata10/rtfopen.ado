#delim ;
prog def rtfopen;
version 10.0;
/*
 Open a file for output using RTF.*|Author: Roger Newson
*!Date: 12 November 2009
*/

syntax name using/ [ , replace TEmplate(name) PAper(string) MArgins(numlist >=0 integer min=4 max=4) ];
/*
  replace specifies that the output must replace an existing file of the same name.
  template() specifies a named RTF template, with formatting specifications.
  paper() specifies paper width and height (in twips or as a keyword).
  margins() specifies the margins (in twips: left, right, top, bottom).
*/

*
 Set default template
 and check that it is in the list of available templates.
*;
if "`template'"=="" {;local template "minimal";};
if !inlist("`template'","minimal","fnmono1") {;
  disp as error "Invalid template(`template')";
  error 498;
};

*
 Set default paper dimensions and margins
 and extract local dimension macros
*;
local paper=lower(trim(`"`paper'"'));
if `"`paper'"'=="us" {;
  local paper "12240 15840";
};
else if `"`paper'"'=="a4" {;
  local paper "11909 16834";
};
papermargins, paper(`paper') margins(`margins');
foreach LM in paperw paperh margl margr margt margb {;
  local `LM'="`r(`LM')'";
};

file open `namelist' using `"`using'"' , text write `replace';
file write `namelist' "{\rtf1" _n;

*
 Fill in template-specific RTF commands
*;
if "`template'"=="minimal" {;
  if `"`paper'"'!="" {;
    file write `namelist'
      "\paperh`paperh'\paperw`paperw'" _n;
  };
  if `"`margins'"'!="" {;
    file write `namelist'
      "\margl`margl'\margr`margr'\margt`margt'\margb`margb'" _n;
  };
};
else if "`template'"=="fnmono1" {;
  local fname: subinstr local using "\" "\'5c", all;
  file write `namelist'
    "\ansi\deff0" _n
    "{\fonttbl" _n
    "{\f0\froman Times New Roman;}" _n
    "{\f1\fswiss Arial;}" _n
    "{\f2\fmodern Courier New;}" _n
    "}" _n
    "\deflang1024\plain\fs24\widowctrl\hyphauto\ftnbj" _n;
  if `"`paper'"'!="" {;
    file write `namelist'
      "\paperh`paperh'\paperw`paperw'" _n;
  };
  if `"`margins'"'!="" {;
    file write `namelist'
      "\margl`margl'\margr`margr'\margt`margt'\margb`margb'" _n;
  };
  file write `namelist'
    "{\header\pard\ql\plain\f0\fs24\i `fname', \'23 \chpgn\par}" _n;
};

end;

prog def papermargins, rclass;
version 10.0;
/*
 Extract paper dimensions and margins from the provided options
*/
syntax , [ PAper(numlist >0 integer min=2 max=2) MArgins(numlist >=0 integer min=4 max=4) ];
/*
  paper() specifies paper width and height (in twips).
  margins specifies paper margins (in twips: left, right, top, bottom). 
*/

local paperw: word 1 of `paper';
local paperh: word 2 of `paper';
local margl: word 1 of `margins';
local margr: word 2 of `margins';
local margt: word 3 of `margins';
local margb: word 4 of `margins';

retu local margb="`margb'";
retu local margt="`margt'";
retu local margr="`margr'";
retu local margl="`margl'";
retu local paperw="`paperw'";
retu local paperh="`paperh'";

end;
