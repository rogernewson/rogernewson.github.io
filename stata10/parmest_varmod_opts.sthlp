{smcl}
{hline}
{cmd:help parmest_varmod_opts}{right:(Roger Newson)}
{hline}


{title:Variable-modifying options for {helpb parmest} and {helpb parmby}}


{title:Syntax}

{synoptset 24}
{synopthdr}
{synoptline}
{synopt:{opt ren:ame(renaming_list)}}Rename variables in the output dataset{p_end}
{synopt:{opt fo:rmat(formatting_list)}}Display formats for variables in the output dataset{p_end}
{synopt:{opt float}}Set storage type of numeric variables to {cmd:float} or lower precision{p_end}
{synopt:{cmdab::no}{cmdab:dou:ble}}Alternative option for specifying {cmd:float}{p_end}
{synoptline}

{pstd}
where {it:renaming_list} is a list of {help varname: variable names} of form

{pstd}
{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}

{pstd}
and {it:formatting_list} is a list of form

{pstd}
{it:{help varlist:varlist_1} {help format:format_1} ... {help varlist:varlist_n} {help format:format_n}}


{title:Description}

{pstd}
These options allow the user to change the {help varname:names}, {help format:display formats} and {help datatype:storage types}
of variables in the output dataset (or resultsset) created by {helpb parmest} or {helpb parmby}.


{title:Options}

{p 4 8 2}
{cmd:rename(}{it:oldvarname_1 newvarname_1 ... oldvarname_n newvarname_n}{cmd:)}
specifies a list of pairs of variable names.
The first variable name of each pair specifies a
variable in the {helpb parmest} output dataset, which is renamed to the second
variable name of the pair.
This option may be used to change the names of output variables
to prevent name clashes, especially with variables specified in the {cmd:by()} option of {helpb parmby},
which cannot be renamed using the {cmd:rename()} option.

{p 4 8 2}
{cmd:format(}{it:varlist_1 format_1 ... varlist_n format_n}{cmd:)}
specifies a list of pairs of {help varlist:variable lists} and {help format:display formats}.
The {help format:formats} will be allocated to
the variables in the output dataset specified by the corresponding {help varlist:{it:varlist}s}.
If {cmd:rename()} is specified, then
any variable names specified by the {cmd:format()} option must be the new names.

{p 4 8 2}
{cmd:float} specifies that there will be no variables in the output dataset of storage type {help double}.
If {cmd:float} is not specified, then all numeric variables in the
output dataset will be of type {help double}, and therefore stored to double
precision, except if they can be compressed without loss of precision, in which
case they will be compressed as far as possible without loss of precision.
If {cmd:float} is specified, then variables of type {help double} in the output dataset
will be converted to type {help datatypes:float}, even if this results in loss of precision.
(See help for {helpb recast}.)

{p 4 8 2}
{cmd:nodouble} is an alternative way of specifying {cmd:float}.


{title:Notes}

{pstd}
See {help parmest_resultssets:{it:parmest_resultssets}}
for details of the variables in datasets created by {helpb parmest} and {helpb parmby}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[D] rename}, {hi: [D] format}, {hi: [D] recast}, {hi: [D] data types}, {hi: [U] 11.4 varlists}
{p_end}
{p 4 13 2}
On-line: help for {helpb rename}, {helpb format}, {helpb recast}, {help datatypes}, {varname}, {varlist}
{break} help for {helpb parmest}, {helpb parmby},
{help parmest_outdest_opts:{it:parmest_outdest_opts}}, {help parmest_ci_opts:{it:parmest_ci_opts}},
{help parmest_varadd_opts:{it:parmest_varadd_opts}}, {help parmby_only_opts:{it:parmby_only_opts}},
{help parmest_resultssets:{it:parmest_resultssets}}
{p_end}
