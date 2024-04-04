#delim ;
prog def dsconcat;
version 6.0;
*
 Concatenate a sequence of data sets into the memory.
 Author: Roger Newson
 Date: 24 March 2002
*;

local ndset:word count `0';

preserve;

*
 Concatenate input data sets in list
*;
* dsin indicates whether an input data set is in memory *;
local dsin=0;
local i1=0;
while(`i1'<`ndset'){;local i1=`i1'+1;
  local dscur:word `i1' of `0';
  if(!`dsin'){;
    use `"`dscur'"',clear;
    local dsin=1;
  };
  else{;append using `"`dscur'"';};
};

restore,not;

end;
