#delim ;
program robit8;
version 16.0;
/*
 Robit link function with 8 degrees of freedom.
*!Author: Roger Newson
*!Date: 20 October 2021
*/

args todo eta mu return;

if `todo' == -1 {;
  /* Set global macros for output */
  global SGLM_lt "Robit with 8 d.f.";
  global SGLM_lf "invt(8,u)";
  exit;
};
if `todo' == 0 {;
  /* set eta(mu) */
  generate double `eta' = invt(8,`mu');
  exit;
};
if `todo' == 1 {;
  /* set mu(eta) */
  generate double `mu' = t(8,`eta');
  exit;
};
if `todo' == 2 {;
  /* set return = dmu/deta */
  generate double `return' = tden(8,`eta');
  exit;
};
if `todo' == 3 {;
  /* set return = d2mu/deta2 */
  generate double `return' = exp( lngamma((8+1)/2)  - lngamma(8/2) )/sqrt(8*_pi) ;
  replace `return' = `return' * (-(8+1)/2) * (1 + (`eta'*`eta')/8)^(-(8+3)/2) ;
  replace `return' = `return' * 2*`eta'/8 ;
  exit;
};
display as error "Unknown call to glm link function";
exit 198;
end;
