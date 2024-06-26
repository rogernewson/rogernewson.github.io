#delim ;
prog def qrowname,rclass;
version 7.0;
/*
  Create list of quoted row names for a matrix.
*! Author: Roger Newson
*! Date: 13 November 2002
*/

gettoken matname 0 : 0 , parse(", ");

confirm name `matname';

syntax [ , Noisily ];
/*
  -noisily- specifies that the quoted lists will be echoed to the log file
*/

* Create lists *;
local nrow=rowsof(`matname');
local eq "";
local name "";
local fullname "";
tempname tempmat;
forv i1=1(1)`nrow' {;
  mat def `tempmat'=`matname'[`i1',1..1];
  local eqcur:roweq `tempmat';
  local namecur:rownames `tempmat';
  local fullcur:rowfullnames `tempmat';
  local eq `"`eq' `"`eqcur'"'"';
  local name `"`name' `"`namecur'"'"';
  local fullname `"`fullname' `"`fullcur'"'"';
};

* Echo lists *;
if "`noisily'"!="" {;
  disp as text "Row equation names: " as result `"`eq'"'
    _n as text "Row names:          " as result `"`name'"'
    _n as text "Row full names:     " as result `"`fullname'"';
};

* Return results *;
retu scalar nrow=`nrow';
retu local eq `"`eq'"';
retu local name `"`name'"';
retu local fullname `"`fullname'"';

end;
