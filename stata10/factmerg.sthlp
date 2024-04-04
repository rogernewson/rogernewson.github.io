{smcl}
{hline}
help for {cmd:factmerg} {right:(Roger Newson)}
{hline}


{title:Merge factors to create string variables containing values, names and labels}

{p 8 15}{cmd:factmerg} [{it:varlist}] [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [ {cmd:,}
 {cmdab:fv:alue}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:fn:ame}{cmd:(}{it:newvarname}{cmd:)} {cmdab:fl:abel}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:mv:alue}{cmd:(}{it:string_expression}{cmd:)}
 {cmdab:mn:ame}{cmd:(}{it:string_expression}{cmd:)} {cmdab:ml:abel}{cmd:(}{it:string_expression}{cmd:)}
 {cmdab:fm:issing}{cmd:(}{it:newvarname}{cmd:)}
 {cmdab:xmls:ub}
 {cmdab:pv:alue}{cmd:(}{it:string}{cmd:)} {cmdab:pn:ame}{cmd:(}{it:string}{cmd:)} {cmdab:pl:abel}{cmd:(}{it:string}{cmd:)}
 {cmdab:sv:alue}{cmd:(}{it:string}{cmd:)} {cmdab:sn:ame}{cmd:(}{it:string}{cmd:)} {cmdab:sl:abel}{cmd:(}{it:string}{cmd:)}
 ]


{title:Description}

{p}
{cmd:factmerg} takes, as input, a list of variables (numeric or string), representing discrete factors in a model.
It creates, as output, one to three string variables, containing, in each observation,
a value, a factor name or a factor variable label, respectively,
copied from the first factor variable in the input variable list with a non-missing value for that observation.
{cmd:factmerg} is intended for use with a list of input variables created by {helpb factext}
after a call to {helpb parmby} or {helpb parmest}. The output variables are intended to be used in creating
row labels for output tables and/or plots, possibly using the {helpb sencode} package.
The input factors are usually either created in a {helpb parmest} or {helpb parmby} output data set
by using the {helpb factext} package, or are in a data set created by concatenating multiple
{helpb xcontract} output data sets using the {helpb dsconcat} package.


{title:Options}

{phang}
{cmd:fvalue(}{it:newvarname}{cmd:)} specifies a string output variable containing,
in each observation, a value derived from the first variable in the input {it:varlist} with a non-missing value
for that observation. Values from string input variables are copied.
Values from numeric input variables are decoded using value labels if these are present,
or using formats otherwise.

{phang}
{cmd:fname(}{it:newvarname}{cmd:)} specifies a string output variable containing, in each observation,
the name of the input variable from which the value of the {cmd:fvalue()} variable is copied for that observation.

{phang}
{cmd:flabel(}{it:newvarname}{cmd:)} specifies a string output variable containing, in each observation,
the variable label of the input variable from which the value of the {cmd:fvalue()} variable is copied
for that observation.

{phang}
{cmd:mvalue(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:fvalue()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:mname(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:fname()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:mlabel(}{it:string_expression}{cmd:)} specifies a string expression, used to define values for the
{cmd:flabel()} variable for observations with missing values for all variables in the input {it:varlist}.

{phang}
{cmd:fmissing(}{it:newvarname}{cmd:)} specifies the name of a new binary variable to be generated,
containing missing values for observations excluded by the {helpb if} and {helpb in} qualifiers,
1 for other observations in which all the input factors are missing, and 0 for other observations
in which at least one of the input factors is nonmissing.

{phang}
{cmd:xmlsub} specifies that,
in the string output variables indicated by the options {cmd:fvalue()} and {cmd:flabel()},
the substrings {cmd:"&"}, {cmd:"<"} and {cmd:">"} will be replaced throughout with the XML entity references
{cmd:"&amp;"}, {cmd:"&lt;"} and {cmd:"&gt;"}, respectively.
This is useful if the string output variables are intended for output
to a table in a document in XHTML, or in other XML-based languages.

{phang}
{cmd:pvalue(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:fvalue()} output variable.

{phang}
{cmd:pname(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:fname()} output variable.

{phang}
{cmd:plabel(}{it:string}{cmd:)} specifies a prefix to be added to the {cmd:flabel()} output variable.

{phang}
{cmd:svalue(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:fvalue()} output variable.

{phang}
{cmd:sname(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:fname()} output variable.

{phang}
{cmd:slabel(}{it:string}{cmd:)} specifies a suffix to be added to the {cmd:flabel()} output variable.


{title:Remarks}

{p}
{cmd:factmerg} is typically used with {helpb factext}, which is used with {helpb parmby}, {helpb parmest} and
{helpb descsave} to create a list of factors. The output {cmd:fvalue()} variable created by {cmd:factmerg}
may be output using {helpb outsheet} or {helpb listtex} to create a table with one row per model parameter and data
on the estimates, confidence limits and/or P-values.
Alternatively, the {cmd:fvalue()} variable may be encoded to
a numeric variable using {cmd:sencode} and then plotted, using {helpb graph}, {helpb hplot} or {helpb eclplot},
to create a confidence interval plot with one axis label per model parameter.
The {cmd:fvalue}, {cmd:fname} and/or {cmd:flabel}
variables may be used in string expressions to generate labels for the rows of the table,
or for positions on the axis of a confidence interval plot, specifying the parameters in a
human-readable format.
The packages {helpb descsave}, {helpb eclplot}, {helpb factext}, {helpb factref}, {helpb hplot}, {helpb listtex},
{helpb parmby}, {helpb parmest}, {helpb sdecode} and {helpb sencode}
are not supplied with official Stata, but can be installed from {help ssc:SSC}.
Further information on the use of some of these packages can be found in Newson (2003).


{title:Examples}

{p}
The following example will work with the {hi:auto} data if {helpb descsave}, {helpb parmest}, {helpb parmby}
and {helpb factext} are installed.

{p 16 20}{inp:. tempfile tf0}{p_end}
{p 16 20}{inp:. descsave rep78 foreign, do(`"`tf0'"',replace)}{p_end}
{p 16 20}{inp:. parmby "xi: regress mpg weight i.rep78 i.foreign, robust", label norestore format(estimate min* max* %8.2f p %8.2g)}{p_end}
{p 16 20}{inp:. factext, do(`"`tf0'"')}{p_end}
{p 16 20}{inp:. factmerg foreign rep78, fn(faname) fl(falab) fv(faval) mn(parm) ml(label)}{p_end}
{p 16 20}{inp:. list parm label rep78 foreign faname falab faval}{p_end}


{title:Author}

{p}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{p}Newson, R. 2003. Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0043":the {it:Stata Journal} website}.


{title:Also see}

{p 0 10}
On-line:   help for {helpb describe}, {helpb tabulate}, {helpb xi}, {helpb graph}
 {break}   help for {helpb descsave}, {helpb eclplot}, {helpb factext}, {helpb factref}, {helpb hplot}, {helpb listtex}, {helpb parmby}, {helpb parmest}, {helpb sdecode}, {helpb sencode}, {helpb xcontract} if installed
{p_end}
