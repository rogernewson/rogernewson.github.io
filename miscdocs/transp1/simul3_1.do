#delim ;
version 7.0;
*
 Plot relative risks associated with smoking and drinking
 (INCLUDING ALL SMOKING/DRINKING INTERACTIONS
 IN RESPONSE TO MARTIN'S QUERY)
*;

use simul3.dta,clear;desc;
tab smoke drink,m;

set textsize 120;

sort label psad parmseq;
by label:grap estimate punk,by(psad) c(L) s(.) xlab(0(0.25)1) ylab(1(0.25)2)
 l1("Estimated RR");

exit;

