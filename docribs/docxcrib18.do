#delim ;
version 18.0;
*
 Crib for Stata 18 semicolon-delimited do-files
 for use with dolog and putdocx
*;

clear all;
set scheme rbn4mono;

*
 Beginning of document-generating block
*;
local fname `"docxcrib18"';
local title `"My .docx document"';
tempname docxh1;
putdocx begin, pagenum(decimal) pagesize(A4) 
  font("Times New Roman",12,black) header(`docxh1');
cap n {;

*
 Add header
*;
putdocx paragraph, halign(left) font("Times New Roman",12,black)
  toheader(`docxh1');
putdocx text (`"`fname'.docx"'), italic font(Courier New);
putdocx text (`", Page "'), italic;
putdocx pagenumber, italic;
putdocx text (" of "), italic;
putdocx pagenumber, totalpages italic;

*
 Output document title and subtitle
 and initialize figure and table counters
*;
putdocx paragraph, style(Heading1);
putdocx text (`"`title'"'),
  underline(none) font("","",black);
putdocx paragraph, style(Heading2);
putdocx text (`"A. U. Thor, `c(current_date)'"'),
  underline(none) font("","",black);
local figseq=0;
local tabseq=0;


*
 Insert other document-populating commands
 using carriage return as the delimiter.
*;
#delim cr

putdocx paragraph, spacing(line,12pt)
putdocx textblock append
We are supposed to populate the document, 
using other document-populating commands. 
This text is intended to demonstrate line spacing, line breaks, 
and font changes, using 
putdocx textblock end
putdocx text ("putdocx textblock"), font("Courier New")
putdocx textblock append
. 
This might be important 
when quoting code.
putdocx textblock end

putdocx paragraph, spacing(line,12pt)
putdocx textblock append
This paragraph shows 
that we can have more than one paragraph in a document. 
Note that the line spacing (unlike the font) 
needs to be respecified for each paragraph. 
It should probably be the same number of points as the default font 
for the document.
putdocx textblock end

putdocx paragraph, spacing(line,12pt)
putdocx textblock append
And the following paragraph 
contains a few lines of Stata code, 
with each line except the last ending in a linebreak, like a line of poetry:
putdocx textblock end

putdocx paragraph, spacing(line,12pt) font("Courier New")
putdocx text ("program myprog;"), linebreak(1)
putdocx text (`"  disp "Hello, world!!!";"'), linebreak(1)
putdocx text ("end;")

putdocx paragraph, spacing(line,12pt)
putdocx textblock append
And this paragraph should return to the default spacing, 
as it has specifically been asked to do so. 
(Let me know if it doesn't.)
putdocx textblock end

#delim ;


};
putdocx save `"`fname'.docx"', replace;
*
 End of document-generating block
*;

exit;
