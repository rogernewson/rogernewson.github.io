#delim ;
prog def stcmd;
version 6.0;
*
 Run the Stat/Transfer st command
 with parameters and switches supplied by the user.
 Author: Roger Newson
 Date: 21 November 2000
*;

********************************************************************************
 IMPORTANT TECHNICAL NOTE: SETTING THE LOCAL MACRO path
 stcmd, inputst and outputst will only work if Stat/Transfer is installed on
 the user's system, and the path for the Stat/Transfer st command on the user's
 system is the same as the setting of the local macro path in the user's copy
 of stcmd.ado. In the distributed version of stcmd.ado, the macro path is set
 to st. This means that stcmd will only call Stat/Transfer if the directory in
 which Stat/Transfer is installed on the user's system is on the user's default
 path (or is the current directory). If the Stat/Transfer directory is not on
 the user's default path, then the user must edit his/her copy of stcmd.ado and
 change the setting of the local macro path so as to specify the path of the
 Stat/Transfer st command on the user's system. For instance, if Stat/Transfer
 is installed in the directory c:\Program Files\StatTransfer5, then the user
 must edit stcmd.ado and alter the command
 local path "st"
 to
 local path "c:\Program Files\StatTransfer5\st"
********************************************************************************
;
local path "st";

* Run program *;
if("$S_OS"=="Windows"){
  *
   Path is very likely to contain spaces
   and should therefore be quoted
  *;
  shell "`path'" `0';
};
else{
  *
   OS is Unix/Linux,
   so path should not contain spaces
  *;
  shell `path' `0';
};

end;
