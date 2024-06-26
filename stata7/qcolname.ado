#delim ;
prog def qcolname,rclass;
version 7.0;
/*
  Create list of quoted column names for a matrix.
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
local ncol=colsof(`matname');
local eq "";
local name "";
local fullname "";
tempname tempmat;
forv i1=1(1)`ncol' {;
  mat def `tempmat'=`matname'[1..1,`i1'];
  local eqcur:coleq `tempmat';
  local namecur:colnames `tempmat';
  local fullcur:colfullnames `tempmat';
  local eq `"`eq' `"`eqcur'"'"';
  local name `"`name' `"`namecur'"'"';
  local fullname `"`fullname' `"`fullcur'"'"';
};

* Echo lists *;
if "`noisily'"!="" {;
  disp as text "Column equation names: " as result `"`eq'"'
    _n as text "Column names:          " as result `"`name'"'
    _n as text "Column full names:     " as result `"`fullname'"';
};

* Return results *;
retu scalar ncol=`ncol';
retu local eq `"`eq'"';
retu local name `"`name'"';
retu local fullname `"`fullname'"';

end;
