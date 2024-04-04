#delim ;
version 7.0;
*
 Plot relative risks associated with smoking and drinking
 (ELIMINATING INDIVIDUALS WITH MISSING SMOKING STATUS FROM ANALYSIS
 IN RESPONSE TO SUE'S QUERY)
*;

use simul2.dta,clear;desc;
tab smoke drink,m;

set textsize 120;
grap estimate punk if drink==2,by(psad) c(L) s(.) xlab(0(0.25)1) ylab(1(0.25)2)
 l1("Estimated RR associated with drinking");
more;
grap estimate punk if smoke==2,by(psad) c(L) s(.) xlab(0(0.25)1) ylab(1(0.25)2)
 l1("Estimated RR associated with smoking");
more;
grap estimate punk if smoke==3,by(psad) c(L) s(.) xlab(0(0.25)1) ylab(1(0.25)2)
 l1("Estimated RR for unknown smoking status");
more;

exit;

