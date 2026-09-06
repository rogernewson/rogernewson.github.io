#delim ;
version 18.0;
*
 Example 1 from Roger Newsob's 2025 London Stata Conference presentation.
 SSC packages required:
 xauto xcollapse sencode xframeappend jformat eclplot insingap ingap ltop docxtab
 Files created:
 example2.docx
 figseq*.pdf for * from 1 to 10
*;

clear all;
set scheme rbn4mono;
set linesize 128;

* Input xauto data *;
xauto, clear;
* Replace dataset with secondary resultsset *;
frame create rframe;
foreach X of var price npm rep78 trunk headroom tons length turn displacement gear_ratio {;
  local Xlab: var lab `X';
  xcollapse (count) N=`X' (mean) mean=`X' (sd) sd=`X'
    (min) p0=`X' (p25) p25=`X' (p50) p50=`X' (p75) p75=`X' (max) p100=`X',
    by(us) idstr("`Xlab'") frame(tframe, replace);
  frame rframe: xframeappend tframe, drop;
};
frame copy rframe default, replace;
rename idstr quanvar;
sencode quanvar, replace;
lab var quanvar "Quantitative variable";
jformat quanvar us;
keyby quanvar us;
format N %8.0g;
format mean sd p* %8.2f;
foreach X of var N mean sd p* {;
  local Xlab: var lab `X';
  local Xlab=subinstr("`Xlab'","price","X",1);
  lab var `X' "`Xlab'";
};
desc, fu;
list, abbr(32) sepby(quanvar);

* Create resultsplots of medians, IQRs and ranges *;
levelsof quanvar, lo(quanvars);
foreach QV of num `quanvars' {;
  local QVlab: lab (quanvar) `QV';
  preserve;
  keep if quanvar==`QV';
  gene us2=us;
  sdecode us, replace;
  lab drop us;
  replace us=us+" models (N="+string(N)+")";
  sencode us, replace gsort(us2);
  eclplot p50 p25 p75 us, hori eplot(scatter) estopts(msym(diamond) msize(3))
    rplot(rbar) ciopts(barwidth(0.25) bfcolor(white))
    baddplot(rspike p0 p100 us, hori)
    yscale(range(0.5 2.5))
    ylab(1 2)
    xlab(, format(%8.0g))
    xtitle("Median (with IQR and range) for:" "`QVlab'", justification(left) margin(zero) size(3))
    ysize(4.5) xsize(4.5);
  graph export figseq`QV'.pdf, replace;
  more;
  restore;
};

*
 Decode statistics
 and reshape resultsset to have 1 obs per variable per origin per statistic
*;
msdecode N, gene(stat1);
msdecode mean sd, delim(" (") suff(")") gene(stat2);
msdecode p50 p25 p75, delim(" (" ", ") suff(")")
  gene(stat3);
msdecode p0 p100, pref("(") delim(", ") suff(")")
  gene(stat4);
lab def statseq 1 "N" 2 "Mean (SD)" 3 "Median (IQR)"
  4 "Range";
drop N mean sd p*;
xrelong stat, i(quanvar us) j(statseq) jlabel(statseq);
jformat statseq stat;
lab var statseq "Statistic sequence";
lab var stat "Statistic value";
desc, fu;
by quanvar: list us statseq stat, abbr(32) sepby(quanvar us);

*
 Reshape dataset to have 1 obs per quantitative variable per statistic
*;
xrewide stat, i(quanvar statseq) j(us) cjlabel(varname);
desc, fu;
by quanvar: list statseq stat0 stat1, abbr(32) subvar;

* Decode row label *;
sdecode statseq, gene(rowlabel);
lab var rowlabel "Row label";
chardef rowlabel, char(varname) val("Quantitative variable");

* Insert gap rows *;
insingap quanvar, grdecode(quanvar) row(rowlabel) suffix(:)
  innerorder(statseq) neworder(rowseq) gapind(gapobs);
desc, fu;
list rowlabel stat0 stat1, abbr(32) subvar sepby(quanvar) clean noobs;

* Group rows into pages *;
ltop pageseq [weight=gapobs+1], iby(quanvar)
  maxlperp(40);
xcontract pageseq, list(, abbr(32));
keyby pageseq quanvar rowseq;
desc, fu;
by pageseq: list rowlabel stat0 stat1, abbr(32) subvar;

*
 Beginning of document-generating block
*;
cap putdocx clear;
local fname `"example1"';
local title `"Example of a resultstable generated from a resultsset"';
tempname docxh1;
putdocx begin, pagenum(decimal) pagesize(A4) 
  font("Times New Roman",12,black) header(`docxh1');
cap n {;

*
 Add header
*;
putdocx paragraph, halign(left) font("Times New Roman",12,black)
  toheader(`docxh1');
putdocx text (`"`fname'.docx"'), italic font("Times New Roman",12,black);
putdocx text (`", Page "'), italic;
putdocx pagenumber, italic;
putdocx text (" of "), italic;
putdocx pagenumber, totalpages italic;

*
 Output document title and subtitle
*;
putdocx paragraph, style(Heading1);
putdocx text (`"`title'"'),
  underline(none) font("","",black);
putdocx paragraph, style(Heading2);
putdocx text (`"Roger Newson, 2025 London Stata Conference"'),
  underline(none) font("","",black);

* Create pages for Table XYZ *;
summ pageseq, meanonly;
local PSmax=r(max);
levelsof pageseq, lo(pageseqs);
foreach PS of num `pageseqs' {;
  preserve;
  keep if pageseq==`PS';
  putdocx pagebreak;
  putdocx paragraph;
  putdocx text (`"Table XYZ. Statistics for quantitative variables by car model origin in the xauto data. Page `PS' of `PSmax'."'),
    bold;
  docxtab rowlabel stat0 stat1, tablename(tableXYZ_`PS')
    headchars(varname) headformat(italic shading(lightgray))
    layout(autofitcontents) trowseq(tabrow);
  putdocx describe tableXYZ_`PS';
  levelsof tabrow if gapobs==1, lo(gaprows);
  levelsof tabrow if gapobs==0, lo(nongaprows);
  putdocx table tableXYZ_`PS'(`gaprows',1), bold halign(left);
  putdocx table tableXYZ_`PS'(`nongaprows',1), halign(right);
  restore;
};

};
putdocx save `"`fname'.docx"', replace;
*
 End of document-generating block
*; 

exit;
