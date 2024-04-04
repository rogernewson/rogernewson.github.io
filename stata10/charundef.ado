#delim ;
prog def charundef, rclass;
version 10.0;
/*
 Clear a list of characteristics for a varlist.
%!Author: Roger Newson
*!Date: 21 June 2011
*/

syntax [ varlist ] [ , Charlist(string) ];
/*
 charlist() specifies the list of characteristics
   (namelist or "*" for all characteristics).
*/

*
 Set default charlist if required
 and check that charlist() is valid.
*;
if inlist(`"`charlist'"',"","*") {;
  local charlist "";
  foreach X of var `varlist' {;
    local charcur: char `X'[];
    local charlist "`charlist' `charcur'";
  };
  local charlist: list uniq charlist;
};
local charlist: list sort charlist;
if "`charlist'"!="" {;
  cap confirm names `charlist';
  if _rc!=0 {;
    disp as error "charlist() must be either a namelist or *";
    error 498;
  };
};

*
 Undefine characteristics.
*;
foreach X of var `varlist' {;
  foreach C in `charlist' {;
    char `X'[`C'] "";
  };
};

*
 Save results
*;
return local charlist "`charlist'";

end;
