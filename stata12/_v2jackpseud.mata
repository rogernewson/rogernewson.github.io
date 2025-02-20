version 10.0
mata:

void _v2jackpseud(numeric matrix phiidot,
 | numeric matrix phiii, real colvector fweight)
{
/*
  Replace the contents of matrix phiidot
  (assumed to be a matrix of columns of totals
  of degree-2 Von Mises kernel values)
  with the corresponding jackknife pseudovalues
  for the corresponding degree-2 Von Mises statistics,
  using the degree-2 kernels of observations with themselves
  in the matrix phiii
  and frequency weights in the vector fweight.
  phiidot contains the degree-2 kernel totals on input
    and the jackknife pseudovalues on output.
  phiii contains the kernels of the observations with themselves.
  fweight contains the frequency weights.
*! Author: Roger Newson
*! Date: 1 August 2005
*/
real scalar narg, nobs, nvar, nobs2, nvar2, ntot
real rowvector phidotdot

/*
  Extract dimensions of phiidot
*/
nobs=rows(phiidot)
nvar=cols(phiidot)

/*
  Initialise absent arguments
*/
narg=args();
if (narg<3) {;fweight=1;}
if (narg<2) {;phiii=0;}

/*
  Conformability checks
*/
nobs2=rows(phiii)
nvar2=cols(phiii)
if((nvar2!=nvar) & (nvar2!=1)){;
  exit(error(3200))
}
if((nobs2!=nobs) & (nobs2!=1)) {
  exit(error(3200))
}
nobs2=rows(fweight)
nvar2=cols(fweight)
if(nvar2!=1){
  exit(error(3200))
}
if((nobs2!=nobs) & (nobs2!=1)){
  exit(error(3200))
}

/*
  Calculate total sample number and weighted sum of phiidot
*/
if(nobs2==nobs) {
  ntot=quadcolsum(fweight)
}
else if(nobs2==1) {
  ntot=nobs*fweight[1,1]
}

/*
  Reassign phiidot
*/
if(ntot<2) {
  phiidot = phiii
}
else {
  phidotdot = quadcolsum(fweight :* phiidot)
  phiidot = ( phidotdot :/ ntot ) :- ( (phidotdot :- (2*phiidot) :+ phiii) :/ (ntot-1) )
}

}
end
