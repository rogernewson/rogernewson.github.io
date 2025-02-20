#delim ;
prog def whichlist, rclass;
version 16.0;
/*
 Input a list of which input items
 and optionally a package list
 and output lists of present and absent items
 and complete and incomplete packages.
*!Author: Roger Newson
*!Date: 09 December 2021
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