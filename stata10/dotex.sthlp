{smcl}
{.-}
help for {cmd:dotex} {right:(Roger Newson)}
{.-}


{title:Execute commands from a file, creating a log file in SJ LaTeX}

{p 8 27}
{cmd:dotex} {it:filename} [ {it:arguments} ]


{title:Description}

{p}
{cmd:dotex} causes Stata to execute the commands stored in {it:filename}
as if they were entered from the keyboard, and echos the commands as it
executes them, creating a log file {it:filename}.tex in Stata Journal (SJ) LaTeX.
The LaTeX log file (or parts of it) can then be included in a {help sjlatex:SJ LaTeX file}
(eg a SJ submission), using the SJ LaTeX {cmd:stlog} environment.
If {it:filename} is specified without an extension, {it:filename}.do is assumed.
If {it:filename} is specified with an extension, then the log file will have {hi:.log}
as an additional extension (so {cmd:dotex} will not overwrite the original do-file).
Arguments are allowed (as with {helpb do}), but the {cmd:nostop} option is not available.


{title:Remarks}

{p 0 0}
{cmd:dotex} is adapted from  {helpb dolog}, which creates a generic text log file
instead of a SJ LaTeX file.
One do-file can be run
with either {cmd:dotex}, {helpb dolog} or {helpb do},
creating, respectively, a SJ LaTeX log, a generic text log or no log.
Further information on SJ LaTeX can be found at the
{browse "http://www.stata-journal.com/":SJ website}.
Note that it is usually sensible to include a {helpb version} statement
at the start of a do-file to be executed by {helpb do}, {helpb dolog} or {cmd:dotex},
so that the do-file will be executed in the {help version:Stata version} specified,
instead of being executed by the {help version:Stata version}
of the current version of Stata, {helpb dolog} or {cmd:dotex}.


{title:Examples}

{p 8 16}{inp:. dotex example1}{p_end}

{p 8 16}{inp:. dotex example1 argone argtwo}{p_end}


{title:Author}

{p}
Roger Newson, National Heart and Lung Institute, Imperial College London, UK.{break}
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:Also see}

{p 0 21}
{bind: }Manual:  {hi:[R] do}, {hi:[R] log}, {hi:[P] version}
{p_end}
{p 0 21}
On-line:  help for {helpb sjlatex}, {helpb log}, {helpb do}, {helpb run}, {helpb doedit}, {helpb version}
{p_end}
{p 10 21}
help for {helpb dolog} if installed
{p_end}
