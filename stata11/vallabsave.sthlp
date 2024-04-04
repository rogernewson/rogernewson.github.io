{smcl}
{hline}
help for {cmd:vallabsave} and {cmd:vallabload}{right:(Roger Newson)}
{hline}

{title:Save and load label-only Stata datasets}

{p 8 21 2}
{cmd:vallabsave} [ {it:namelist} ] {cmd:using} {help filename:{it:filename}} [, {opt replace} {opth dsl:abel(string)} ]

{p 8 21 2}
{cmd:vallabload}  {cmd:using} {help filename:{it:filename}} [, {cmd:no}{cmdab:note:s} ]

{pstd}
where {it:namelist} is a list of names, assumed to belong to {help label:value labels}.


{title:Description}

{pstd}
The {cmd:vallabsave} package contains 2 modules, {cmd:vallabsave} and {cmd:vallabload}.
{cmd:vallabsave} saves a list of {help label:value labels} (defaulting to all value labels in the current dataset)
to a label-only Stata dataset in a disk file, containing no observations and no variables.
{cmd:vallabload} appends a label-only Stata dataset in a disk file
to the Stata dataset currently in memory,
after checking that the Stata dataset in the disk file is a label-only Stata dataset.
Label-only Stata datasets are a sensible way of storing value labels in a disk file,
if the labels may have text values that cannot be enclosed in {help quotes:compound quotes}.
Such labels cannot be stored using {helpb label:label save},
or generated using {helpb label:label define},
but they may be generated using {helpb encode},
or usng the {help ssc:SSC} packages {helpb sencode} and {helpb vallabdef}.


{title:Options for {cmd:vallabsave}}

{phang}
{opt replace} specifies that any existing file with the same name as the {helpb using} file
will be overwritten.

{phang}
{opth dslabel(string)} specifies a {help label:dataset label}
for the newly created label-only dataset.


{title:Options for {cmd:vallabload}}

{phang}
{opt nonotes} specifies that {help notes:notes} in the {cmd:using} dataset
will not be copied to the existing dataset in memory.


{title:Examples}

{pstd}
The following example demonstrates the creation of a value label {cmd:reprec},
which is then saved to a label-only dataset {cmd:myvallabs.dta} using {cmd:vallabsave}.
The value label is then added to the {helpb sysuse:auto} data using {cmd:vallabload},
and then assigned to the variable {cmd:rep78}.

{pstd}
Create the value label:

{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. label define reprec 1 "One" 2 "Two" 3 "Three" 4 "Four" 5 "Five"}{p_end}
{phang2}{cmd:. label dir}{p_end}
{phang2}{cmd:. label list}{p_end}

{pstd}
Save the value label in a label-only dataset:

{phang2}{cmd:. vallabsave reprec using myvallabs.dta, replace}{p_end}

{pstd}
Load the value labels into the {helpb sysuse:auto} dataset:

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. vallabload using myvallabs.dta}{p_end}
{phang2}{cmd:. label dir}{p_end}
{phang2}{cmd:. label list}{p_end}
{phang2}{cmd:. label value rep78 reprec}{p_end}
{phang2}{cmd:. tab rep78, miss}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {manhelp label D}, {manhelp save D}, {manhelp append D}, {manhelp encode D}
{p_end}
{p 4 13 2}
On-line: help for {helpb label}, {helpb save}, {helpb append}, {helpb encode}
{break} help for {helpb sencode}, {helpb vallabdef} if installed

{p_end}
