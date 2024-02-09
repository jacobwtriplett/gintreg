{smcl}
{* *! version 3.0 06feb2024}{...}
{vieweralsosee "gintreg" "help gintreg"}{...}
{viewerjumpto "Syntax" "gintreg##syntax"}{...}
{viewerjumpto "Description" "gintreg##description"}{...}
{viewerjumpto "Options" "gintreg##options"}{...}
{viewerjumpto "Remarks" "gintreg##remarks"}
{viewerjumpto "Examples" "gintreg##examples"}{...}
{viewerjumpto "Stored results" "gintreg##results"}{...}
{viewerjumpto "Authors" "gintreg##authors"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{cmd:gintreg} {hline 2}}Plot distribution fit by {cmd:gintreg}{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:gintregplot}
[({it:stat})] {varlist} [ [({it:stat})] {it:...} ]
{ifin}
[{cmd:,} {it:options}]

{pstd}
and {it:stat} is one of{p_end}

{p2colset 9 22 24 2}{...}
{p2col :{opt mean}}means (default){p_end}
{p2col :{opt median}}medians{p_end}
{p2col :{opt p1}}1st percentile{p_end}
{p2col :{opt p2}}2nd percentile{p_end}
{p2col :{it:...}}3rd{hline 1}49th percentiles{p_end}
{p2col :{opt p50}}50th percentile (same as {cmd:median}){p_end}
{p2col :{it:...}}51st{hline 1}97th percentiles{p_end}
{p2col :{opt p98}}98th percentile{p_end}
{p2col :{opt p99}}99th percentile{p_end}
{p2col :{opt max}}maximums{p_end}
{p2col :{opt min}}minimums{p_end}
{p2colreset}{...}

{pstd}
If {it:stat} is not specified, {opt mean} is assumed.

{synoptset 15 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opth hist(varname)}}overlay histogram of {varlist}{p_end}
{synopt :{opth twoway_options}}}options for graph{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gintregplot} draws the conditional distribution of {it:depvar1} and 
{it:depvar2} estimated by {helpb gintreg}.  {it:indepvars} are taken at {it:stat}
or {opt mean} by default.



{marker options}{...}
{title:Options}

{synoptset 15 tabbed}{...}
{synopt :{opth hist(varname)}} overlay a histogram of {it:varname}; see {helpb histogram:[R] histogram}.{p_end} 
{synopt :{helpb twoway_options}} control the look and other aspects of the graph drawn by {cmd:gintregplot}; {opt range(numlist)} recommended;
see {helpb twoway_options:[G-3] twoway options}{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
We have a dataset containing wages, truncated and in categories.  Some of
the observations on wages are

        wage1    wage2
{p 8 27 2}20{space 7}25{space 6} meaning  20000 <= wages <= 25000{p_end}
{p 8 27 2}50{space 8}.{space 6} meaning 50000 <= wages

{pstd}Setup{p_end}
{phang2}{cmd:. webuse intregxmpl}{p_end}

{pstd}SGT interval regression{p_end}
{phang2}{cmd:. gintreg wage1 wage2 age age2 nev_mar rural school tenure, dist(sgt)}

{pstd}Draw graph with {it:indepvars} at {opt mean}{p_end}
{phang2}{cmd:. gintregplot, range(0 60)}

{pstd}Draw graph with select {it:indepvars} at {opt median}{p_end}
{phang2}{cmd:. gintregplot (median) nev_mar rural, range(0 60)}

{pstd}Compare fit of distributions visually{p_end}
{phang2}{cmd:. gintreg wage1 wage2, dist(normal)}{p_end}
{phang2}{cmd:. gintregplot, range(0 60)}{p_end}
{phang2}{cmd:. local normal `r(graphfn)'}{p_end}

{phang2}{cmd:. gintreg wage1 wage2, dist(snormal)}{p_end}
{phang2}{cmd:. gintregplot, range(0 60)}{p_end}
{phang2}{cmd:. local snormal `r(graphfn)'}{p_end}

{phang2}{cmd:. graph twoway (function=`normal') (function=`snormal')}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:gintregplot} stores the following in {cmd:r()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Macros}{p_end}
{synopt:{cmd:r(graphfn)}}function used to draw graph, as in {cmd:twoway function y={it:graphfn}, {it:twoway_options}}


{marker authors}{...}
{title:Authors}

{pstd}Jacob Triplett{p_end}
{pstd}Carnegie Mellon University{p_end}
{pstd}jacobtri@andrew.cmu.edu{p_end}
