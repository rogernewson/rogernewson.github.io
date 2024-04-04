#delim cr
/*
 Examples for the 4th German Stata User Meeting
 on 31 March 2006.
 This do-file uses the following SSC packages:
 metaparm, parmest, regaxis, scheme_rbn1mono, sencode, sdecode
 It creates the following output files in the local directory
 (replacing any existing files with the same names):
 figure4.eps
*/

clear
set memory 1m
set scheme rbn1mono

/*
 Input data from Glasziou and MacKerras (1993)
 with 1 observation per study,
 quoted as an example of a meta-analysis in:
 Bland M. An introduction to medical statistics. 3rd ed.
 Oxford: Oxford University Press; 2000.
 Downloadable from:
 http://www-users.york.ac.uk/~mb55/intro/introcon.htm#third
*/
input studyseq str24 doseregime deaths1  number1  deaths0  number0
1  "200,000 IU six-monthly"  101  12991  130  12209  
2  "200,000 IU six-monthly"  39  7076  41  7006  
3  "8,333 IU weekly"  37  7764  80  7755  
4  "200,000 IU four-monthly"  152  12541  210  12264  
5  "200,000 IU once"  138  3786  167  3411  
end
compress
sort studyseq
by studyseq: assert _N==1
describe

/*
 Reshape data to have 1 observation per study per treatment group
*/
reshape long deaths number, i(studyseq doseregime) j(vitamina)
lab var studyseq "Study sequence number"
lab var doseregime "Dose regime"
lab var vitamina "Vitamin A supplementation"
lab var deaths "Number of deaths"
lab var number "Number of subjects"
lab def vitamina 0 "No" 1 "Yes"
lab val vitamina vitamina
describe
list, sepby(studyseq)

/*
 Define labelled numeric variable study
 identifying study sequence and regime
 and sort data by study and treatment group
*/
gene study=string(studyseq)+" ("+doseregime+")"
sencode study, replace
lab var study "Study (dose regime)"
order study
sort study vitamina
by study vitamina: assert _N==1
describe
list study vitamina number deaths, sepby(study)

/*
 Logistic regression
*/
parmby "blogit deaths number vitamina, or", by(study) eform norestore label ///
   escal(N) rename(es_1 N) format(estimate min* max* %8.2f p %-8.2g) ///
   idstr("Individual study")
describe
list study parm label N estimate min* max* p, sepby(study)

/*
 Keep odds ratios
 and add summarized odds ratio
*/
keep if parm=="vitamina"
tempfile mf1
metaparm [awei=N], eform sumvar(N) saving(`mf1', replace) idstr("Meta-analysis")
append using `mf1'
sencode idstr, gene(studytype)
lab var studytype "Study type"
sdecode study, replace
replace study="Weighted geometric mean" if studytype==2
sencode study, replace
sort study
describe
list studytype study N estimate min* max* p, sepby(studytype)

/*
 Cochrane forest plot
 (using the SSC package regaxis to define the axes)
*/
regaxis study, cy(1) marg(0.5) lrange(yrange) ltick(ylabs)
logaxis estimate min* max*, inc(1) base(2) scale(1(2)7) lrange(xrange) ltick(xlabs)
eclplot estimate min* max* study, hori supby(studytype) legend(off) ///
  estopts1(msym(square), [fweight=N]) estopts2(msym(diamond) msize(vhuge)) ///
  ciopts(msize(huge)) ///
  xscale(log range(`xrange')) xlab(`xlabs', format(%8.4g)) ///
  xline(1) xtitle("Odds ratio (95% CI)") ///
  yscale(range(`yrange')) ylab(`ylabs') ///
  plot(scatter study min95, msym(none) mlab(N) mlabsize(medsmall) mlabpos(9)) ///
  xsize(6) ysize(5)
graph export figure4.eps, replace
more

exit
