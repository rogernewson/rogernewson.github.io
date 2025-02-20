#delim ;
prog def gphepssj;
version 7.0;
*
 Translate a sequence of .gph files to .eps files
 with the default -xsize- and -ysize- for Stata Journal.
 Author: Roger Newson
 Date: 21 August 2002
*;

local xsdef=3.12;local ysdef=2.392;

disp as text "Default xsize: " as result `xsdef' _n as text "Default ysize: " as result `ysdef';

foreach FN of any `0' {;
  translate `"`FN'.gph"' `"`FN'.eps"' , xsize(`xsdef') ysize(`ysdef') logo(off) replace;
};

end;
