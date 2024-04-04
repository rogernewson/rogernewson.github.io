#delim ;
prog def stcmd;
version 9.0;
/*
 Run the Stat/Transfer st command
 with parameters and switches supplied by the user.
*!Author: Roger Newson
*!Date: 04 June 2007
*/

local stpath `"$StatTransfer_path"';
if `"`stpath'"'=="" {;
  local stpath "st";
};
shell "`stpath'" `0' ;

end;
