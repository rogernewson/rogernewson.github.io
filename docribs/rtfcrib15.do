#delim ;
version 15.1;
*
 Crib for Stata 15 semicolon-delimited do-files
 for use with -dolog- and -rtfutil-
*;

clear all;
set scheme rbn4mono;

*
 Beginning of document-generating block
*;
tempname rtfb1;
rtfopen `rtfb1' using `"rtfcrib15.rtf"', replace
  paper(a4) margins(720 720 720 720) template(fnmono2);
cap n {;

*
 Output document title
 and initialize figure and table counters
*;
file write `rtfb1'
  _n "{\pard\b My RTF document\par}"
  _n "\line"
  _n "{\pard\b A. U. Thor, `c(current_date)'\par}"
  _n "\line"
  _n;
local figseq=0;
local tabseq=0;

};
rtfclose `rtfb1';
*
 End of document-generating block
*;

exit;
