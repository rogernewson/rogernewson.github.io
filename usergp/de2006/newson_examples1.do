#delim cr
version 9.1
/*
 Examples for the 4th German Stata User Meeting
 on 31 March 2006.
 This do-file uses the following SSC packages:
 descsave, estout, factext, listtex, parmest, scheme_rbn1mono, sencode, xcontract
 It creates the following output files in the local directory
 (replacing any existing files with the same names):
 estout1.txt, figure2.eps, figure1.eps, spread1.txt
*/

clear
set memory 1m
set scheme rbn1mono

/*
 Input dataset and add variables firm and country
*/
sysuse auto, clear
gene firm=word(make,1)
tab firm, m
lab var firm "Firm"
xcontract foreign firm, list(,)
gene country="US" if !foreign
replace country="Germany" if inlist(firm,"Audi","BMW","VW")
replace country="Japan" if inlist(firm,"Datsun","Honda","Mazda","Subaru","Toyota")
replace country="Italy" if inlist(firm,"Fiat")
replace country="France" if inlist(firm,"Peugeot","Renault")
replace country="Sweden" if inlist(firm,"Volvo")
lab def country 1 "US" 2 "Japan" 3 "Germany" 4 "France" 5 "Italy" 6 "Sweden"
sencode country, replace
lab var country "Country of origin of firm"
desc
xcontract country firm, list(, sepby(country))

/*
 Save attributes of variable country in a do-file for reconstruction
*/
tempfile df1
descsave country, do(`df1')
type `df1'

/*
 Create results
*/
tab country, gene(c_)
regress weight c_*, noconst nohead

/*
 Create resultsspreadsheet using estout
*/
preserve
estout using estout1.txt, ///
  cells("b(fmt(%8.2f)) ci_l(fmt(%8.2f)) ci_u(fmt(%8.2f))") ///
  replace label collabels(, lhs(label)) mlabels(, none)
insheet using estout1.txt, clear
list, clean noobs
factext, string
sencode country, replace
describe
list country b min95 max95, clean noobs
eclplot b min95 max95 country, hori ///
  estopts(msize(vlarge)) ciopts(msize(huge)) ///
  yscale(range(0.5 6.5)) ylab(1(1)6) xlab(0(500)4500, format(%8.0g)) ///
  xtitle("Mean weight (US pounds) with 95% CI (and number of cars)") ///
  ytitle("Country of origin of firm") ///
  xsize(6) ysize(5)
graph export figure2.eps, replace
more
restore

drop c_*
tab country, nolabel gene(c_)

/*
 Create resultssets
*/
tempfile tf1
xcontract country, saving(`tf1') list(, clean noobs)
regress weight c_*, noconst nohead
parmest, label norestore  format(estimate min95 max95 %8.2f) ///
  list(parm label estimate min95 max95, clean noobs)
factext, do(`df1')
list parm label country estimate min95 max95, clean noobs
sort country
merge country using `tf1'
sort country
list country _freq estimate min95 max95, clean noobs

/*
 Create resultsplot
*/
gene freqlab="("+string(_freq)+")";
eclplot estimate min95 max95 country, hori ///
  estopts(msize(vlarge)) ciopts(msize(huge)) ///
  yscale(range(0.5 6.5)) ylab(1(1)6) xlab(0(500)4500, format(%8.0g)) ///
  xtitle("Mean weight (US pounds) with 95% CI (and number of cars)") ///
  plot(scatter country min95, msym(none) mlab(freqlab) mlabpos(9) mlabsize(medlarge)) ///
  xsize(6) ysize(5)
graph export figure1.eps, replace
more

/*
 Create resultsspreadsheets using listtex
*/
sdecode min95, replace prefix("(") suffix(",")
sdecode max95, replace suffix(")")
listtex country _freq estimate min95 max95, rstyle(tabular) type ///
  head( ///
    "\begin{tabular}{rrrrr}" ///
    "\textit{Country}&\textit{N}&\textit{Mean}&\textit{(95\%}&\textit{CI)}\\" ///
  ) ///
  foot("\end{tabular}")
outsheet country _freq estimate min95 max95 using spread1.txt, noquote replace
listtex country _freq estimate min95 max95, type ///
  head("Country&N&Mean&(95%&CI)")

exit
