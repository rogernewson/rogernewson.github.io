#delim ;
version 13.1;
*
 Crib for Stata 13 semicolon-delimited do-files
 for use with -dolog- and -htmlutil-
*;

clear all;
set scheme rbn4mono;

*
 Beginning of document-generating block
*;
local fname `"htmcrib13"';
local title `"My HTML document"';
tempname htmb1;
sleep 1;
htmlopen `htmb1' using `"`fname'.htm"', replace head body title(`"`title'"');
cap n {;

*
 Output document title
 and initialize figure and table counters
*;
file write `htmb1'
  _n `"<h1>`title'</h1>"'
  _n `"<h2>A. U. Thor, `c(current_date)'</h2>"'
  _n;
local figseq=0;
local tabseq=0;

};
htmlclose `htmb1', body;
*
 End of document-generating block
*;

*
 Zip output files
*;
zipfile `"`fname'.htm"' `"`fname'_*.*"' , saving(`"`fname'.zip"', replace);
exit;
