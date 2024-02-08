{smcl}
{* *! version 3.0 06feb2024}{...}
{vieweralsosee "[R] intreg" "help intreg"}{...}
{viewerjumpto "Syntax" "gintreg##syntax"}{...}
{viewerjumpto "Description" "gintreg##description"}{...}
{viewerjumpto "Options" "gintreg##options"}{...}
{viewerjumpto "Remarks" "gintreg##remarks"}
{viewerjumpto "Postestimation syntax" "gintreg##postestimation"}{...}
{viewerjumpto "Examples" "gintreg##examples"}{...}
{viewerjumpto "Stored results" "gintreg##results"}{...}
{viewerjumpto "Authors" "gintreg##authors"}{...}
{viewerjumpto "References" "gintreg##references"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{cmd:gintreg} {hline 2}}Generalized interval regression{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:gintreg}
{it:{help depvar:depvar1}}
{it:{help depvar:depvar2}}
[{indepvars}]
{ifin}
[{it:{help intreg##weight:weight}}]
[{cmd:,} {it:options}]

{pstd}
{it:depvar1} and {it:depvar2} should have the following form:

             Type of data {space 16} {it:depvar1}  {it:depvar2}
             {hline 46}
             point data{space 10}{it:a} = [{it:a},{it:a}]{space 4}{it:a}{space 8}{it:a} 
             interval data{space 11}[{it:a},{it:b}]{space 4}{it:a}{space 8}{it:b}
             left-censored data{space 3}(-inf,{it:b}]{space 4}{cmd:.}{space 8}{it:b}
             right-censored data{space 2}[{it:a},+inf){space 4}{it:a}{space 8}{cmd:.}
             missing{space 26}{cmd:.}{space 8}{cmd:.} 
             {hline 46}

{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model}
{synopt :{opth dist:ribution(gintreg##distname:distname)}}specify distribution; default is {cmd:dist(normal)}{p_end}
{synopt :{opt nocons:tant}}suppress constant term of model equation{p_end}
{synopt :{cmdab:lnsigma(}{varlist} [{cmd:,} {opt nocons:tant}]{cmd:)}}independent
variables to model the variance; use {opt noconstant} to suppress constant
term{p_end}
{synopt :{cmdab:lambda(}{varlist} [{cmd:,} {opt nocons:tant}]{cmd:)}}independent
variables to model the skewness; use {opt noconstant} to suppress constant
term{p_end}
{synopt :{cmdab:p(}{varlist} [{cmd:,} {opt nocons:tant}]{cmd:)}}independent
variables to model the shape; use {opt noconstant} to suppress constant
term{p_end}
{synopt :{cmdab:q(}{varlist} [{cmd:,} {opt nocons:tant}]{cmd:)}}independent
variables to model the shape; use {opt noconstant} to suppress constant
term{p_end}
{synopt :{opth off:set(varname)}}include {it:varname} in model with coefficient
constrained to 1{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab :SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim},
{opt r:obust}, {opt cl:uster} {it:clustvar}, {opt opg}, {opt boot:strap},
or {opt jack:knife}{p_end}
{synopt :{opt robust}}use robust standard errors{p_end}
{synopt :{opth cluster(varname)}}cluster standard errors with respect to sampling
unit {varname}{p_end}


{syntab :Reporting}
{synopt :{opt gini}}display gini coefficient; operable with {opt dist:ribution(weibull | gamma | br3 | br12)}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}
{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{it:{help intreg##display_options:display_options}}}control
INCLUDE help shortdes-displayoptall

{syntab :Maximization}
{synopt :{opt from(distname | init_specs)}}if {it:distname}, use {cmd:gintreg} with {opt dist:ribution(distname)} to find starting values; if {it:init_specs}, see {it:{help gintreg##maximize_options:maximize_options}}{p_end}
{synopt :{it:{help gintreg##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{synopt:{opt col:linear}}keep collinear variables{p_end}
INCLUDE help shortdes-coeflegend
{synoptline}

{marker distname}{...}
{synoptset 27}{...}
{synopthdr:distname}
{synoptline}
{synopt :{opt normal}}normal distribution; the default{p_end}
{synopt :{opt snormal}}skewed normal distribution{p_end}
{synopt :{opt laplace}}Laplace distribution{p_end}
{synopt :{opt slaplace}}skewed Laplace distribution{p_end}
{synopt :{opt ged}}generalized error distribution{p_end}
{synopt :{opt sged}}skewed generalized error distribution{p_end}
{synopt :{opt t}}t distribution{p_end}
{synopt :{opt st}}skewed t distribution{p_end}
{synopt :{opt gt}}generalized t distribution{p_end}
{synopt :{opt sgt}}skewed generalized t distribution{p_end}
{synopt :{opt lognormal}}lognormal distribution{p_end}
{synopt :{opt lnormal}}synonym for {cmd:lognormal}{p_end}
{synopt :{opt weibull}}Weibull distribution{p_end}
{synopt :{opt gamma}}gamma distribution{p_end}
{synopt :{opt ggamma}}generalized gamma distribution{p_end}
{synopt :{opt br3}}Burr 3 distribution{p_end}
{synopt :{opt br12}}Burr 12 distribution{p_end}
{synopt :{opt gb2}}generalized beta of the second kind distribution{p_end}
{synoptline}
{p2colreset}{...}

{p2colreset}{...}
INCLUDE help fvvarlist2
{p 4 6 2}
{it:depvar1}, {it:depvar2}, {it:indepvars}, and {it:varlist} may contain
time-series operators; see {help tsvarlist}.{p_end}
{p 4 6 2}
{opt aweight}s, {opt fweight}s, {opt iweight}s, and {opt pweight}s are
allowed; see {help weight}.{p_end}
{p 4 6 2}
See {help gintreg:postestimation:postestimation} for features
available after estimation.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:gintreg} fits a linear model with an outcome measured as
point data, interval data, left-censored data, or right-censored data.  As
such, it is a generalization of the models fit by {helpb intreg} and yields
identical estimates to {helpb intreg} when the normal distribution is specified.  
Unlike {cmd: intreg}, {cmd: gintreg} allows the underlying variable of interest
to be distributed according to a more general distribution.  
{help gintreg##distname:Supported distributions} are those in the Skewed Generalized t (SGT) family and Generalized
Beta of the Second Kind (GB2) family.  Auxillary parameters affecting variance, 
skewness and shape of these distributions may be modeled as linear functions of 
{help indepvars}.

{pstd}
The assumed model for interval regression in {it:y = Xb + u} for the SGT family
and {it:ln(y) = Xb + u} for the GB2 family, where only thresholds containing the
latent variable {it:y} are observed, {it:X} is a vector of explanatory variables
with a corresponding coefficient vector {it:b} and the random disturbance {it:u}
is assumed to be independently and identically distributed according to the 
specified distribution.

{pstd}
Let {it:U} and {it:L} denote the upper and lower thresholds of {it:y}, F denote
the cumulative density function (CDF) of the random disturbances, and {it:theta}
denote a vector of distributional parameters.  Then,
the conditional probability that {it:y} is in the interval ({it:L,U}) is:
Pr({it:L} <= {it:y} <= {it:U}}) = F({it:eps = U - Xb: theta}) - F({it:eps = L - Xb: theta}).


{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opth dist:ribution(gintreg##distname:distname)} specifies the distribution of 
the random disturbances.

{phang}
{opt noconstant}; see 
{helpb estimation options##noconstant:[R] Estimation options}.

{phang}
{cmd:lnsigma(}{varlist}[{opt , noconstant}]{cmd:)} specifies that
the natural logarithm of the parameter {bf:sigma} be modeled as a linear combination
of {it:varlist}.  The constant is included unless {cmd:noconstant} is
specified.

{phang}
{cmd:lambda(}{varlist}[{opt , noconstant}]{cmd:)} specifies that
the hyperbolic tangent of the parameter {bf:lambda} be modeled as a linear combination
of {it:varlist}.  The constant is included unless {cmd:noconstant} is
specified.

{phang}
{cmd:p(}{varlist}[{opt , noconstant}]{cmd:)} specifies that
the parameter {bf:p} be modeled as a linear combination
of {it:varlist}.  The constant is included unless {cmd:noconstant} is
specified.

{phang}
{cmd:q(}{varlist}[{opt , noconstant}]{cmd:)} specifies that
the parameter {bf:q} be modeled as a linear combination
of {it:varlist}.  The constant is included unless {cmd:noconstant} is
specified.

{phang}
{opth offset(varname)}, {opt constraints(constraints)}; see
{helpb estimation options:[R] Estimation options}.

{dlgtab:SE/Robust}

INCLUDE help vce_asymptall

{phang}
{opt robust} is a synonym for {cmd:vce(robust)}.{p_end}

{phang}
{opth cluster(varlist)} is a synonym for {cmd:vce(cluster {help varlist})}.{p_end}

{dlgtab:Reporting}

{phang}
{opt gini} computes, reports, and returns the Gini Inequality Index.  It is only
operational with these distributions: {it:weibull, gamma, br3, br12}.  To find
the Gini Inequality Index of a GB2 distribution, see {cmd:gb2dist} on {cmd:ssc}.{p_end}

{phang}
{opt level(#)}, {opt nocnsreport}; see
     {helpb estimation options:[R] Estimation options}.

INCLUDE help displayopts_list

{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{opt from(distname | init_specs)} can assist in the maximization process by 
providing starting values for the vector of estimates.{p_end}

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
{opt iter:ate(#)},
[{cmd:no}]{opt log},
{opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance}, and
{opt from(init_specs)};
see {helpb maximize:[R] Maximize}.  These options are seldom used.

{pmore}
Setting the optimization type to {cmd:technique(bhhh)} resets the default
{it:vcetype} to {cmd:vce(opg)}.

{pstd}
The following options are available with {opt intreg} but are not shown in the
dialog box:

{phang}
{opt collinear}, {opt coeflegend}; see
     {helpb estimation options:[R] Estimation options}.

     
{marker remarks}{...}
{title:Remarks}

{pstd}
If convergence is not being achieved, try using the options {opt diff:icult} 
and/or {opth from:(gintreg##distname:distname)}, where 
{it:{help gintreg##distname:distname}} is a nested distribution of the one with
convergence issues. 


{marker postestimation}{...}
{title:Postestimation syntax}

{pstd}
{helpb gintregplot} draws the conditional distribution of {it:depvar1} and 
{it:depvar2} estimated by {cmd:gintreg}.{p_end}

{pstd}
{helpb predict} obtains linear predictions using all parameter equations estimated by 
{cmd:gintreg} with the following syntax:
        
        {cmd:predict} [{help type}] {newvar} {ifin} [, {help predict##options:noOFFset}]

{pstd}
The following built-in postestimation commands are also available after {cmd:gintreg}:

TODO test these and remove those which fail

{synoptset 17 tabbed}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
INCLUDE help post_contrast
INCLUDE help post_estatic
INCLUDE help post_estatsum
INCLUDE help post_estatvce
INCLUDE help post_svy_estat
INCLUDE help post_estimates
INCLUDE help post_etable
INCLUDE help post_hausman_star
INCLUDE help post_lincom
INCLUDE help post_lrtest_star
{synopt:{helpb intreg_postestimation##margins:margins}}marginal
        means, predictive margins, marginal effects, and average marginal
        effects{p_end}
INCLUDE help post_marginsplot
INCLUDE help post_nlcom
{synopt :{helpb intreg postestimation##predict:predict}}{findalias p_intreg}{p_end}
INCLUDE help post_predictnl
INCLUDE help post_pwcompare
INCLUDE help post_suest
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}
{p 4 6 2}

     
{marker examples}{...}
{title:Examples}

{pstd}
TODO! 


We have a dataset containing wages, truncated and in categories.  Some of
the observations on wages are

        wage1    wage2
{p 8 27 2}20{space 7}25{space 6} meaning  20000 <= wages <= 25000{p_end}
{p 8 27 2}50{space 8}.{space 6} meaning 50000 <= wages

{pstd}Setup{p_end}
{phang2}{cmd:. webuse intregxmpl}{p_end}

{pstd}Interval regression{p_end}
{phang2}{cmd:. intreg wage1 wage2 age c.age#c.age nev_mar rural school tenure}

{pstd}Same as above, but suppress constant term{p_end}
{phang2}{cmd:. intreg wage1 wage2 age c.age#c.age nev_mar rural school tenure,}
           {cmd:noconstant}


{marker results}{...}
{title:Stored results}

{pstd}
TODO!


{cmd:intreg} stores the following in {cmd:e()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_unc)}}number of uncensored observations{p_end}
{synopt:{cmd:e(N_lc)}}number of left-censored observations{p_end}
{synopt:{cmd:e(N_rc)}}number of right-censored observations{p_end}
{synopt:{cmd:e(N_int)}}number of interval observations{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_aux)}}number of auxiliary parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations in {cmd:e(b)}{p_end}
{synopt:{cmd:e(k_eq_model)}}number of equations in overall model test{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(ll_0)}}log likelihood, constant-only model{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}{it:p}-value for model chi-squared test{p_end}
{synopt:{cmd:e(sigma)}}sigma{p_end}
{synopt:{cmd:e(se_sigma)}}standard error of sigma{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(rank0)}}rank of {cmd:e(V)} for constant-only model{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{p2col 5 23 26 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:intreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}names of dependent variables{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(offset)}}linear offset variable{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald} or {cmd:LR}; type of model chi-squared
        test{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. err.{p_end}
{synopt:{cmd:e(het)}}{cmd:heteroskedasticity}, if {cmd:het()} specified{p_end}
{synopt:{cmd:e(ml_score)}}program used to implement {cmd:scores}{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform
                         maximization or minimization{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(marginsok)}}predictions allowed by {cmd:margins}{p_end}
{synopt:{cmd:e(asbalanced)}}factor variables {cmd:fvset} as {cmd:asbalanced}{p_end}
{synopt:{cmd:e(asobserved)}}factor variables {cmd:fvset} as {cmd:asobserved}{p_end}

{p2col 5 23 26 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}

{p2col 5 23 26 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

INCLUDE help rtable


{marker authors}{...}
{title:Authors}

{pstd}
Originally authored in 2016 by James McDonald and Jacob Orchard at Brigham Young
University.  Will Cockriel, Bryan Chia, Jonny Jensen and Jacob Triplett have
joined James McDonald as additional collaborators over the years.  Jacob 
Triplett brought the program to version 3.0 in 2024.  He can be contacted for 
support at "jacobtri@andrew.cmu.edu".


{marker references}{...}
{title:References}

{phang}
James B. McDonald, Olga Stoddard, and Daniel Walton. 2018.
{it:On using interval response data in experimental economics},
Behavioral and Experimental Economics, 72:9-16.

{phang}
James B. McDonald, Daniel Walton and Bryan Chia. 2020.
{it: Distributional Assumptions and the Estimation of Contingent Valuation Models},
Computational Economics, 52:431-460.

{phang}
Michal Brzezinki. 2012. {cmd:gb2dist} Stata command.
"http://coin.wne.uw.edu.pl/mbrzezinski/software".

{phang}
Skewed Generalized t Distribution, Wikipedia,
"https://en.wikipedia.org/wiki/Skewed_generalized_t_distribution".{p_end}

{phang}
Generalized Beta of the Second Kind Distribution, Wikipedia,
"https://en.wikipedia.org/wiki/Generalized_beta_distribution#Generalized_beta_of_the_second_kind_(GB2)".{p_end}
