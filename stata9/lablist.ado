#delim ;
prog def lablist;
version 9.0;
/*
 List value labels (if possible) for variables in a varlist.
*!Author: Roger Newson
*!Date: 18 July 2000
*/

syntax [varlist] [, VARlabel ];

*
 List labels for each variable with a value label
*;
foreach X of var `varlist' {;
  disp _n as text "Variable: " as result "`X'";
  if "`varlabel'"!="" {;
    local Xvarlab: variable label `X';
    if `"`Xvarlab'"'=="" {;
      disp as text "No variable label present";      
    };
    else {;
      disp as text "Variable label: " as result `"`Xvarlab'"';
    };
  };
  local Xlab: value label `X';
  if `"`Xlab'"'=="" {;
    disp as text "No value label present";
  };
  else {;
    disp as text "Value label: " as result "`Xlab'";
    lab list `Xlab';
  };
};

end;
