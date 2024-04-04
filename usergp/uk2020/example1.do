#delim ;
version 16.1;
*
 Run examples for presentation.
 SSC add-on packages required:
 invdesc, keyby, vallabdef, xdir, descgen.
*;

clear all;
set scheme rbn4mono;

*
 Input descriptive dataset mydesc
 from generic worksheet
 and save to data frame and disk file
*;
frame create mydesc;
frame mydesc {;
  import delimited using mydesc.txt, stringcols(_all) varnames(1) clear;
  desc, fu;
  sinvdesc;
  desc, fu;
  tab dset, m;
  keybygen dset, gene(order);
  label data "Variables in all datasets";
  desc, fu;
  by dset: list name type format vallab varlab, abbr(32);
  list, abbr(32) sepby(dset);
  save mydesc.dta, replace;
};

*
 Input variable labels data
 from generic worksheet
 and save to data frame and disk file
*;
frame create myvallabs;
frame myvallabs {;
  import delimited using myvallabs.txt, stringcols(_all) varnames(1) clear;
  desc, fu;
  invdesc, dframe(mydesc);
  desc, fu;
  keyby vallabname value;
  label data "Value labels";
  desc, fu;
  list, abbr(32) sepby(vallabname);
  save myvallabs.dta, replace;
  label list;
  vallabdef vallabname value label;
  label list;
};

*
 Input extended auto data
 from generic worksheet
 and save to disk file
*;
import delimited using myxauto.txt, stringcols(_all) varnames(1) clear;
desc, fu;
invdesc, dframe(mydesc) lframe(myvallabs);
desc, fu;
keyby foreign make;
label data "Extended auto data";
desc, fu;
char list;
save myxauto.dta, replace;
table us, miss;
scatter npm tons, by(us) ysize(4.6) xsize(4.6);;
graph export figseq1.pdf, replace;
more;

*
 List metadata on datasets
*;
xdir, dir(.) pattern(*.dta) fast;
desc, fu;
list, abbr(32);
descgen, label;
desc, fu;
list filename nobs nvar size sortedby dslabel, abbr(32);

exit;
