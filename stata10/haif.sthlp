{smcl}
{hline}
help for {cmd:haif} and {cmd:haifcomp}{right:(Roger Newson)}
{hline}

{title:Homoskedastic adjustment inflation factors for model selection}

{p 8 21 2}
{cmd:haif} [ {help varlist:{it:corevarlist}} ] {ifin} {weight} , {opth a:ddvars(varlist)} [ {opt noc:onstant} ]

{p 8 21 2}
{cmd:haifcomp} [ {help varlist:{it:corevarlist}} ] {ifin} {weight} , {opth da:ddvars(varlist)} {opth na:ddvars(varlist)} [ {opt noc:onstant} ]

{pstd}
where {help varlist:{it:corevarlist}} is a {varlist} (possibly empty).

{pstd}
{cmd:aweight}s, {cmd:fweight}s, and {cmd:iweight}s are allowed; see help for {help weight}.


{title:Description}

{pstd}
{cmd:haif} calculates homoskedastic adjustment inflation factors (HAIFs) for core variables in the {help varlist:{it:corevarlist}},
caused by adjustment by the additional variables specified by {cmd:addvars()}.
HAIFs are calculated for the variances and standard errors of estimated {help regress:linear regression} parameters
corresponding to the core variables.
For each variance (or standard error),
the HAIF is defined as the ratio between that variance (or standard error) of that parameter,
in a model containing both the core variables and the additional variables,
to the corresponding variance (or standard error) of the same parameter,
in a model containing only the core variables,
calculated assuming that the second model is true,
and also assuming that the outcome variable is homoskedastic
(meaning that it has equal variances in all subpopulations defined by the predictor variables).
{cmd:haifcomp} calculates the ratios between the HAIFs for the same core variables
caused by adjustment for two alternative lists of additional variables,
namely a numerator list and a denominator list.
{cmd:haif} and {cmd:haifcomp} are intended for use in model selection,
allowing the user to choose a model based on the joint distribution of the exposures and confounders,
before estimating the parameters of the model from the data on the outcome variable.


{title:Options for {cmd:haif} and {cmd:haifcomp}}

{phang}
{opt noconstant} specifies that the models being compared contain no constant term.
If {cmd:noconstant} is not specified,
then it is assumed that the models being compared contain a constant term, labelled {hi:_cons},
and HAIFs (or HAIF ratios) are calculated for the variance and standard error of that constant term.


{title:Options for {cmd:haif} only}

{phang}
{opth addvars(varlist)} specifies a list of additional variables,
which must not contain any of the core variables.
The HAIFs will then be scale factors
by which the variances and standard errors of the parameters of the core variables are scaled
by including in the model the additional variables specified by {cmd:addvars()},
assuming that these additional variables do not really have any effect,
and that the outcome variable is homoskedastic.


{title:Options for {cmd:haifcomp} only}

{phang}
{opth daddvars(varlist)} specifies a list of additional variables,
known as the denominator list,
which must not contain any of the core variables.
The HAIFs for the core variables, caused by adjustment for these additional variables,
will then be defined as for the {cmd:addvars()} option of {cmd:haif},
and will be the denominators of the HAIF ratios.

{phang}
{opth naddvars(varlist)} specifies a second list of additional variables,
known as the numerator list,
which also must not contain any of the core variables,
although it may contain variables in common with the list specified by {cmd:daddvars()}.
The HAIFs for the core variables, caused by adjustment for this second list of additional variables,
will then be defined as for the {cmd:addvars()} option of {cmd:haif},
and will be the numerators of the HAIF ratios.


{title:Remarks}

{pstd}
Homoskedastic adjustment inflation factors (or HAIFs) measure the loss of power
to measure the effects of core predictors on an outcome,
caused by the inclusion in the model of unnecessary additional predictors.
If these predictors are indeed unnecessary,
and the true model is a homoskedastic (or equal-variance) linear regression model including only the core predictors,
then it can be shown that the population variances and standard errors of the estimated core variable effects
will be no smaller if the unneccessary variables are included than if they are not included.
(See Subsections 3.7 and 5.4 of Seber, 1977.)
The variance HAIFs (and standard error HAIFs) are the scale factors by which these variances (and standard errors) are scaled up
by the inclusion of the unnecessary additional variables.
The standard error HAIF is interpreted
as the factor by which the confidence interval width for a core variable coefficient is scaled up
by adjusting for the unnecessary additional variables.
The variance HAIF is interpreted as the factor by which the experimenter would have to scale up the size of the experiment,
in order to counteract the effect on the confidence interval width of adjusting for the unnecessary additional variables.

{pstd}
Note that, if the additional variables are not unnecessary,
then including them in the model will not necessarily increase the variance of the coefficients of the core variables.
If the additional variables predict the outcome well,
given each value of the core variables,
then including the additional variables may even decrease the variance of the coefficients of the core variables.
The HAIFs therefore represent a "worst case" scenario,
based on the values of the core and additional predictor variables,
assuming that we have no knowledge of the distribution of the outcome variable.


{title:Methods and formulas}

{pstd}
Let {it:X} denote the matrix whose columns are the core variables,
let {it:A} denote the matrix whose columns are the additional variables specified by the {cmd:addvars()} option of {cmd:haif},
and let {it:D} denote the diagonal matrix of weights.
The variance HAIF of the {it:k}th variable in {it:X} is then a ratio,
whose numerator is the {it:k}th diagonal entry in the matrix

{pstd}
{it: inverse( (X,A)' * D * (X,A) )}

{pstd}
and whose denominator is the {it:k}th diagonal entry in the matrix

{pstd}
{it: inverse( X' * D * X )}

{pstd}
The standard error (SE) HAIF is the square root of the corresponding variance HAIF.

{pstd}
{cmd:haifcomp} inputs two alternative lists of additional variables.
Let {it:B} denote the matrix of additional variables specified by the {cmd:daddvars()} option,
and let {it:C} denote the matrix of additional variables specified by the {cmd:naddvars()} option.
Then the variance HAIF ratio for the {it:k}th variable in {it:X} is then a ratio,
whose numerator is the {it:k}th diagonal entry in the matrix

{pstd}
{it: inverse( (X,C)' * D * (X,C) )}

{pstd}
and whose denominator is the {it:k}th diagonal entry in the matrix

{pstd}
{it: inverse( (X,B)' * D * (X,B) )}

{pstd}
and the SE HAIF ratio is the square root of the corresponding variance HAIF ratio.
The HAIF ratios produced by {cmd:haifcomp} are especially useful if the columns of {it:B}
are linearly dependent on the columns of {it:C},
implying that the model with design matrix {it:X,B}
is a sub-model of the model with design matrix {it:X,C}.
For example, {it:X} might have a single column which is an interesting exposure variable whose effect we wish to know,
{it:B} might have a single column whose entries are all 1,
and {it:C} might have multiple columns,
containing indicators of the membership of a row (or observation}
in each of a set of multiple mutually exclusive strata.
The HAIFs will then measure the effect, on the variance and standard error of the slope for {it:X},
of fitting a multiple-intercept model (with a separate intercept for each stratum)
instead of a single-intercept model (with one common intercept for all strata),
assuming that the single-intercept model is true and that the outcome is homoskedastic.

{pstd}
Note that the rows of the matrices correspond to observations with non-missing values
for all variables in all {varlist}s input to {cmd:haif} or {cmd:haifcomp}.
Therefore, missing values are deleted listwise.


{title:Examples}

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.haif weight, add(foreign length)}{p_end}
{phang2}{cmd:.haif weight foreign, add(length headroom)}{p_end}
{phang2}{cmd:.haif weight, add(foreign)}{p_end}

{pstd}
The following example demonstrates the use of {cmd:haifcomp} in measuring the effect
of fitting an unnecessary 2-intercept model in {hi:weight},
with separate intercepts for US car models and non-US car models,
when a single-intercept model in {hi:weight} is true,
and the outcome variable is homoskedastic.

{phang2}{cmd:.sysuse auto, clear}{p_end}
{phang2}{cmd:.gene byte baseline=1}{p_end}
{phang2}{cmd:.xi i.foreign, noomit}{p_end}
{phang2}{cmd:.haifcomp weight, noc dadd(baseline) nadd(_I*)}{p_end}


{title:Saved results}

{pstd}
{cmd:haif} and {cmd:haifcomp} save the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(haif)}}Variance and standard error HAIFs or HAIF ratios{p_end}
{p2colreset}{...}

{pstd}
The matrix {cmd:r(haif)} has 1 row for each variable in the list of core variables,
and also an additional row for the constant term, if {cmd:noconstant} is not specified.
It has 2 columns, the first containing variance HAIFs (or HAIF ratios),
and the second containing standard eror (SE) HAIFs (or HAIF ratios).
This matrix is also listed to the Stata log, unless the user specifies the {helpb quietly} prefix.

{pstd}
{cmd:haif} also saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(addvars)}}{varlist} specified by {cmd:addvars()}{p_end}
{p2colreset}{...}

{pstd}
{cmd:haifcomp} also saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(daddvars)}}{varlist} specified by {cmd:daddvars()}{p_end}
{synopt:{cmd:r(naddvars)}}{varlist} specified by {cmd:naddvars()}{p_end}
{p2colreset}{...}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Seber, G. A. F. {it:Linear Regression Analysis.} New York, NY: John Wiley & Sons; 1977.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] regress}
{p_end}
{p 4 13 2}
On-line: help for {helpb regress}
{p_end}
