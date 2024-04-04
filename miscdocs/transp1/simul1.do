#delim ;
version 7.0;
*
 Simulations of loglinear regression of death rate
 with respect to smoking and drinking,
 with different proportions with unknown smoking status
*;

clear;

*
 Create data set
 with 1 obs per possible probability of smoking given drinking
*;
#delim cr;
input psad
0.50
0.55
0.60
0.65
0.70
0.75
0.80
0.85
0.90
end
#delim ;
lab var psad "Pr(smoker|drinker)";

*
 Generate true proportions who drink and smoke
 assuming that half the people drink, half the people smoke,
 and probability (smoker|drinker) is given by psad
*;
gene ps=0.5;gene pd=0.5;
gene pds=pd*psad;gene pdns=pd*(1-psad);
gene pnds=(1-pd)*(1-psad);gene pndns=(1-pd)*psad;
lab var ps "Pr(smoker)";lab var pd "Pr(drinker)";
lab var pds "Pr(drinker and smoker)";
lab var pdns "Pr(drinker and non-smoker)";
lab var pnds "Pr(non-drinker and smoker)";
lab var pndns "Pr(non-drinker and non-smoker)";

*
 Expand data set to create new data set
 with 1 obs per combination of Pr(smoker|drinker) and Pr(unknown smoking status)
*;
local npunk=100;
expgen npunk=`npunk',copy(punkseq);
gene punk=(punkseq-1)/`npunk';
lab var npunk "Number of punk values";
lab var punkseq "Sequence number of punk value";
lab var punk "Pr(unknown smoking status)";
sort psad punk;

*
 Expand data set to ceate new data set
 with 1 obs per combination of Pr(smoker|drinker), Pr(unknown smoking status)
 and smoking status
*;
expgen =3,copy(smoke);
lab def smoke 1 "Non-smoker" 2 "Smoker" 3 "Unknown";
lab var smoke "Smoking status";lab val smoke smoke;
char smoke[omit] 1;
sort psad punk smoke;

*
 Expand data set to ceate new data set
 with 1 obs per combination of Pr(smoker|drinker), Pr(unknown smoking status),
 smoking status and drinking status
*;
expgen =2,copy(drink);
lab def drink 1 "Non-drinker" 2 "Drinker";
lab var drink "Drinking status";lab val drink drink;
char drink[omit] 1;
sort psad punk smoke drink;

xi i.smoke i.drink;

*
 Define baseline number of deaths
 if all the population were non-smoking nondrinkers,
 and relative risks of drinking and smoking
*;
scal ndbase=1000000;
scal rrsmoke=2.00;
scal rrdrink=1.00;

*
 Define exposure levels (relative person-years at risk)
 as a function of smoking and drinking status
*;
gene rpyar=1;
replace rpyar=rpyar*(1-punk)*pndns if (drink==1)&(smoke==1);
replace rpyar=rpyar*(1-punk)*pnds if (drink==1)&(smoke==2);
replace rpyar=rpyar*punk*(pndns+pnds) if (drink==1)&(smoke==3);
replace rpyar=rpyar*(1-punk)*pdns if (drink==2)&(smoke==1);
replace rpyar=rpyar*(1-punk)*pds if (drink==2)&(smoke==2);
replace rpyar=rpyar*punk*(pdns+pds) if (drink==2)&(smoke==3);
lab var rpyar "Relative person-years at risk";

*
 Define expected numbers of deaths
*;
gene deaths=ndbase;
replace deaths=deaths*(1-punk)*pndns if (drink==1)&(smoke==1);
replace deaths=deaths*(1-punk)*pnds*rrsmoke if (drink==1)&(smoke==2);
replace deaths=deaths*punk*(pndns+pnds*rrsmoke) if(drink==1)&(smoke==3);
replace deaths=deaths*(1-punk)*pdns*rrdrink if (drink==2)&(smoke==1);
replace deaths=deaths*(1-punk)*pds*rrdrink*rrsmoke if (drink==2)&(smoke==2);
replace deaths=deaths*punk*(pdns*rrdrink+pds*rrdrink*rrsmoke) if(drink==2)&(smoke==3);
replace deaths=round(deaths,1);
lab var deaths "Number of deaths";

desc;

*
 Calculate relative risks
 and create new data set with 1 obs per combination
 of psad, punk and parameter of the poisson model
*;
gene byte baseline=1;
lab var baseline "Baseline level";
tempfile tf0;
descsave smoke drink,do(`tf0');
qui parmby "poisson deaths baseline _I* if rpyar>0,expo(rpyar) irr noconst",
 by(psad punk) label eform;
factext smoke drink;run `tf0';
desc;
save simul1.dta,replace;

exit;

