#delim ;
prog def tocgen;
version 17.0;
/*
  Create a file stata.toc
  in each Stata sub-directory of the current working directory
  using information from the .pkg files in the same sub-directory,
  unzip package files using 7-zip,
  create a HTML page with the full table of packages in the current directory,
  and create do-files for describing, installing and uninstalling sets of packages.
*! Author: Roger Newson
*! Date: 15 October 2025
*/

*
 Set default directory to a non-UNC directory.
 THIS IS INELEGANT AS IT COMMITS ME TO A PARTICULAR NAME FOR THE WORKING DIRECTORY,
 BUT THE Windows 10 CMD.EE DOES NOT ALWAYS ALLOW UNC PATHS.
 THIS WAS COMMENTED OUT FOLLOWING A MOVE OF THE WEBSITE
 TO KING'S COLLEGE LONDON IN 2021,
 BUT MIGHT POSSIBLY BE UNCOMMENTED AND/OR MODIFIED IN FUTURE.
*;
* cd h:\rnewson\website\r.newson;

*
 Local macros for .toc filenames
 and maximum package description length
*;
local stoc `"stata.toc"';
local htoc `"stata_h.toc"';
local ttoc `"stata_t.toc"';
local mlen=96;

*
 Create dataset with 1 obs per subdirectory
*;
xdir, dirname(.) pattern(stata*) ftype(dirs) fast rename(filename sdname) keep(sdname);
compress sdname;
lab var sdname "Subdirectory name";
gene sdversion=real(subinstr(sdname,"stata","",1));
compress sdversion;
lab var sdversion "Subdirectory Stata version";
desc, fu;
list, abbr(32);
summ sdversion, meanonly;
local maxsdversion=r(max);

*
 Store subdirectory names in local macros
*;
local nsd=_N;
forv i1=1(1)`nsd' {;
  local sd`i1'=sdname[`i1'];
};

*
 Create dataset with 1 obs per Stata package name per Stata version
*;
forv i1=1(1)`nsd' {;
  tempfile sdf`i1';
  xdir, dirname("`sd`i1''") pattern(*.pkg) ftype(files) fast rename(dirname sdname filename pkgfname) keep(sdname pkgfname);
  compress;
  save `"`sdf`i1''"',replace;
};
clear;
forv i1=1(1)`nsd' {;
  append using `"`sdf`i1''"';
};
order sdname pkgfname;
lab var sdname "Subdirectory name";
lab var pkgfname "Package file name";
gene version=real(subinstr(sdname,"stata","",1));
gene str`mlen' pkgname=subinstr(pkgfname,".pkg","",1);
compress;
lab var pkgname "Package name";
lab var version "Stata version";
keyby pkgname version;

*
 Store package filenames into local macros
*;
local npkg=_N;
forv i1=1(1)`npkg' {;
  local pf`i1'=sdname[`i1']+"/"+pkgfname[`i1'];
};

*
 Extract titles of packages from .pkg files into local macros
*;
preserve;
local mlenp2=`mlen'+2;
forv i1=1(1)`npkg' {;
  clear;
  infix str ltype 1-2 str line 3-`mlenp2' using `"`pf`i1''"',clear;
  format ltype %-2s;
  format line %-`mlen's;
  keep if ltype=="d";
  keep if _n==1;
  local tit`i1'=line[1];
};
restore;

*
 Copy local macros into new variable title containing package titles
*;
gene str1 title="";
forv i1=1(1)`npkg' {;
  replace title=`"`tit`i1''"' in `i1';
};
lab var title "Title line";

*
 Resolve titles into package names and descriptive information *;
*;
split title, parse(": ") gene(S_);
rename S_1 pkgn2;
rename S_2 descript;
assert pkgname==pkgn2;
drop title pkgn2;
lab var descript "Description";
keyby pkgname version;
desc, fu;
list, sepby(pkgname);

*
 Save Stata dataset with 1 obs per package
*;
save package,replace;

*
 Unzip files using 7-zip
*;
disp as text "Preparing to extract contents of .zip files...";
forv i1=1(1)`npkg' {;
  local sdcur=sdname[`i1'];
  local pkgcur=pkgname[`i1'];
  local shellcmd `""c:\Program Files (x86)\7-zip\7z.exe" e ".\\`sdcur'\\`pkgcur'.zip" -o.\\`sdcur' -aoa"';
  disp as text "Executing: " as result `"`shellcmd'"';
  shell `shellcmd';
};
disp as text "Contents of .zip files extracted.";

*
 Output package descriptions to stata.toc files in each subdirectory
*;
tempfile tf0 tf1 tf2 tf3;
forv i1=1(1)`nsd' {;
  preserve;
  keep if sdname==`"`sd`i1''"';
  gene str2 p_="p ";
  gene str1 space=" ";
  lab var p_ "Line prefix";lab var space "Space";
  *
   Output p-lines to file tf0
  *;
  outfile p_ pkgname space descript using `"`tf0'"',runtogether replace;
  *
   Create output file stata.toc
  *;
  infix str line 1-`mlen' using `"`sd`i1''/`htoc'"',clear;
  save `"`tf1'"',replace;
  infix str line 1-`mlen' using `"`tf0'"',clear;
  save `"`tf2'"',replace;
  infix str line 1-`mlen' using `"`sd`i1''/`ttoc'"',clear;
  save `"`tf3'"',replace;
  clear;
  append using `"`tf1'"' `"`tf2'"' `"`tf3'"';
  outfile line using `"`sd`i1''/`stoc'"',runtogether replace;  
  restore;
};

*
 Output package descriptions to .html table in main directory
*;
preserve;
gsort pkgname -version;
gene str1 pkgtt="";
gene str1 pkganch="";
replace pkgtt="<code>"+pkgname+"</code>";
replace pkganch=`"<a href="./stata"'+string(version)+"/"+pkgname+`".zip">Download</a>"';
listtab pkgtt descript version pkganch using "packages.htm", rs(html) replace;
inccat stata_r.htm,to(stata.htm) pre(<!--insert) post(-->) replace;
restore;

*
 Create files descasisay.do, instasisay.do and uninstasisay.do
 to describe, install and uninstall all Roger Newson's main-repository packages from SSC
*;
preserve;
collapse (count) Nversions=version (min) minversion=version (max) maxversion=version, by(pkgname);
compress;
disp _n as text "Packages in all Stata versions";
list, abbr(32);
sort maxversion pkgname;
gene desccom="cap noi ssc desc " + pkgname;
gene instcom="cap noi ssc inst " + pkgname + ", replace";
gene uninstcom="cap noi ssc uninstall "+pkgname;
lab var desccom "ssc describe command";
lab var instcom "ssc install command";
lab var uninstcom "ssc uninstall command";
outfile desccom using ./instasisay/descasisay.do, replace runtogether;
outfile instcom using ./instasisay/instasisay.do, replace runtogether;
outfile uninstcom using ./instasisay/uninstasisay.do, replace runtogether;
restore;

*
 Create files descasisay_x.do, instasisay_x.do and uninstasisay_x.do
 to describe, install and uninstall all Roger Newson's main-repository packages
 from Roger Newson's website
*;
qui summ version;
local vermax=max(r(max),`maxsdversion');
local vermin=9;
forv V=`vermax'(-1)`vermin' {;
  preserve;
  collapse (count) Nversions=version (min) minversion=version (max) maxversion=version if version<=`V', by(pkgname);
  compress;
  disp _n as text "Packages in Stata versions up to: " as result "`V'";
  list, abbr(32);
  sort maxversion pkgname;
  gene desccom="cap noi net desc " + pkgname + ", from(http://www.rogernewsonresources.org.uk/stata" + string(maxversion) + ")";
  gene instcom="cap noi net inst " + pkgname + ", replace from(http://www.rogernewsonresources.org.uk/stata" + string(maxversion) + ")";
  gene uninstcom="cap noi ado uninstall " + pkgname;
  lab var desccom "net describe command";
  lab var instcom "net install command";
  lab var uninstcom "ado uninstall command";
  outfile desccom using ./instasisay/descasisay_`V'.do, replace runtogether;
  outfile instcom using ./instasisay/instasisay_`V'.do, replace runtogether;
  outfile uninstcom using ./instasisay/uninstasisay_`V'.do, replace runtogether;
  restore;
};

end;
