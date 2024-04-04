#delim ;
prog def stcmd;
version 10.0;
/*
 Run the Stat/Transfer st command
 with parameters and switches supplied by the user.
*!Author: Roger Newson
*!Date: 06 August 2008
*/

local stpath `"$StatTransfer_path"';
if `"`stpath'"'=="" {;
  local stpath "st";
};
local stcommand `""`stpath'" `0'"';
disp as text "Stat/Transfer command submitted:" _n as result `"`stcommand'"';
shell `stcommand' ;

end;
