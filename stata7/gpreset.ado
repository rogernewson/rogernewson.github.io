#delim ;
prog def gpreset,rclass;
version 7.0;
args cnum;
*/
 Reset -gprefs- scheme custom`cnum' to its state as shipped
 (ie custom1 is reset to black, custom2 is reset to white,
 and custom3 is reset to mono)
*/

confirm integer number `cnum';

* Get all preferences of appropriate scheme *;
if `cnum'==1 {;qui gprefs query black;};
else if `cnum'==2 {;qui gprefs query white;};
else if `cnum'==3 {;qui gprefs query mono;};
else{;disp as error "Invalid custom number - `cnum'";error 498;};

* Reset background color *;
gprefs set custom`cnum' background_color `r(background_color)';

* Reset pen preferences *;
foreach P of numlist 1(1)9 {;
  gprefs set custom`cnum' pen`P'_color `r(pen`P'_color)';
  gprefs set custom`cnum' pen`P'_thick `r(pen`P'_thick)';
};

* Reset symbol magnifications *;
foreach SYM in O S T x o d p {;
  gprefs set custom`cnum' symmag_`SYM' `r(symmag_`SYM')';
};

* Save revised preferences to -return- *;
qui gprefs query custom`cnum';
return add;

end;
