{smcl}
{hline}
help for {cmd:addinby}{right:(Roger Newson)}
{hline}

{title:Add in data from a disk dataset using a foreign key}

{p 8 21 2}
{cmd:addinby} {help varlist:{it:keyvarlist}} {cmd:using} {it:filename} [ ,
  {opt m:issing} {opt un:matched(action_spec)} {opt noc:omplete} {cmdab:fast} {break}
  {opth keep(varlist)} {opt nol:abel} {opt nonote:s} {opt update} {opt replace}
  ]

{pstd}
where {help varlist:{it:keyvarlist}} is a {varlist} specifying a list of key variables,
and {it:action_spec} may be {cmd:drop}, {cmd:keep} or {cmd:fail}.


{title:Description}

{pstd}
{cmd:addinby} is a "cleaner" alternative version of {helpb merge},
designed to reduce the lines of code in Stata do-files.
It adds variables and/or values to existing observations in the dataset currently in memory
(the master dataset)
from a Stata-format dataset stored in the file {it:filename}
(the using dataset),
using a foreign key of variables specified by the {help varlist:{it:keyvarlist}}
to identify observations in the using dataset.
The using dataset must be sorted by the variables in the {help varlist:{it:keyvarlist}},
and these variables must identify observations in the using dataset uniquely.
Unlike {helpb merge}, {cmd:addinby} always preserves the master dataset
in its original sorting order,
and does not add any merge-status variables or additional observations.
However, {cmd:addinby} checks that the foreign key uniquely identifies observations
in the using dataset,
and may optionally check that there are no unmatched observations in the master dataset,
and/or check that there are no missing values
in the foreign key variables in the master dataset.


{title:Options}

{phang}
{opt missing} specifies that missing values in the variables are allowed
in the {help varlist:{it:keyvarlist}} in the master dataset.
If {cmd:missing} is not specified,
then missing values in the variables in the {help varlist:{it:keyvarlist}} cause {cmd:addinby} to fail.

{phang}
{opt unmatched(action_spec)} specifies the action to be taken with observations in the master dataset
which are unmatched by the foreign key in the using dataset.
The possible values of {it:action_spec} are {cmd:drop}, {cmd:keep} and {cmd:fail}.
If {cmd:drop} is specified, then unmatched observations are dropped from the master dataset,
 and {cmd:addinby} completes execution without error.
If {cmd:keep} is specified, then unmatched observations are kept in the master dataset,
and {cmd:addinby} completes execution without error.
If {cmd:fail} is specified,
then {cmd:addinby} fails with an error message if there are any unmatched observations in the master dataset.
If the {cmd:unmatched()} option is not specified, then {cmd:unmatched(fail)} is assumed.

{phang}
{opt nocomplete} is a shorthand for {cmd:unmatched(keep)}.
It is ignored if the {cmd:unmatched()} option is specified.

{phang}
{opt fast} is an option for programmers.
It specifies that {cmd:addinby} will take no action
to restore the existing dataset in memory in the event of failure.
If {cmd:fast} is not specified, then {cmd:addinby} will take this action,
which uses an amount of time depending on the size of the dataset in memory.

{phang}
{opth keep(varlist)} specifies the variables to be kept from the using dataset.
If {opt keep()} is not specified, then all variables are kept.

{phang}
{opt nolabel} prevents Stata from copying the value label definitions from the
using dataset into the result.
Even if you do not specify this
option, label definitions from the using dataset do not replace label
definitions in the master dataset.

{phang}
{opt nonotes} prevents {help notes} in the using data from being incorporated
into the result.
The default is to incorporate notes from the using data that
do not already appear in the master dataset.

{phang}
{opt update} specifies that the values from the using dataset be retained in
cases where the master dataset contains missing.
By default, the master
dataset is held inviolate -- values from the master dataset are retained
when the variables are found in both datasets.

{phang}
{opt replace}, allowed with {opt update} only, specifies that even when the
master dataset contains nonmissing values, they are to be replaced with
corresponding values from the using dataset when the corresponding values are
not equal.
A nonmissing value, however, will never be replaced with a missing
value.


{title:Remarks}

{pstd}
{cmd:addinby} was designed to be used with master datasets and using datasets
keyed using the {helpb keyby} package, which can be downloaded from {help ssc:SSC}.
Both {helpb keyby} and {cmd:addinby} are designed to enforce the relational database model,
in which a dataset is viewed as a function,
whose domain is the set of existing value combinations of the primary key variables,
and whose range is the set of all possible value combinations of the non-key variables.
A dataset therefore has one observation per {it:thing} (identified by the primary key variables),
and data on {it:attributes_of_things} (specified by the non-key variables).
A foreign key is defined as a list of variables in a dataset (typically the master dataset)
which is also the primary key of a second dataset (typically the using dataset).
{helpb keyby} ensures that a dataset is sorted, and its observations uniquely identified,
by a primary key.
{cmd:addinby} then adds variables and/or values to existing observations in a master dataset,
using a foreign key specified by the {help varlist:{it:keyvarlist}}
to identify observations from the using dataset in which the values for the variables are to be found.
Therefore, {helpb keyby} is a "clean" version of {helpb sort},
which ensures that the observations in a dataset are identified, as well as sorted, by the key variables.
And {cmd:addinby} is a "clean" version of {helpb merge},
which ensures that these observations stay identified, and sorted,
after the additional data have been merged in.


{title:Examples}

{phang2}{cmd:.webuse autotech, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.describe using http://www.stata-press.com/data/r10/autocost}{p_end}
{phang2}{cmd:.addinby make using http://www.stata-press.com/data/r10/autocost}{p_end}
{phang2}{cmd:.describe}{p_end}

{phang2}{cmd:.webuse dollars, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list}{p_end}
{phang2}{cmd:.webuse sforce, clear}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list}{p_end}
{phang2}{cmd:.addinby region using http://www.stata-press.com/data/r10/dollars}{p_end}
{phang2}{cmd:.describe}{p_end}
{phang2}{cmd:.list}{p_end}


{title:Author}

{pstd}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] sort}, {hi:[D] gsort}, {hi:[D] merge}, {hi: [D] order}, {hi:[U] 12.2.1 Missing values}
{p_end}
{p 4 13 2}
On-line: help for {helpb sort}, {helpb gsort}, {helpb merge}, {helpb order}, {helpb missing}
{break} help for {helpb keyby} if installed
{p_end}
