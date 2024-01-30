*! version 3.8.0  22mar2018 // TODO: UPDATE (this if from intreg)
program define gintreg, eclass byable(onecall) ///
                        prop(svyb svyj svyr swml bayes)
        if _by() {
                local BY `"by `_byvars'`_byrc0':"'
        }
        `BY' _vce_parserun gintreg, numdepvars(2) alldepsmissing ///
                mark(Het OFFset CLuster) : `0'
        if "`s(exit)'" != "" {
                version 10: ereturn local cmdline `"gintreg `0'"'
                exit
        }

        version 8.1, missing
        if _caller() < 8 {
                di as err "gintreg requires Stata 8 or newer"
				error 498
                exit
        }
        if replay() {
                if `"`e(cmd)'"'!="gintreg" {
                        error 301
                }
                if _by() {
                        error 190
                }
                DiGintreg `0' /* display results */
                error `e(rc)'
                exit
        }
        if _caller() >= 11 {
                local vv : di "version " string(_caller()) ":"
        }
        `vv' `BY' Estimate `0'
        version 10: ereturn local cmdline `"gintreg `0'"'
end

program Estimate, eclass byable(recall)
        if _caller() >= 11 {
                local vv : di "version " string(max(11,_caller())) ", missing:"
        }
        version 8.1, missing
/* Parse and check options. */

        syntax  varlist(min=2 numeric fv ts)    /*
        */      [aw fw pw iw] [if] [in]         /*
        */      [,                              /*
        */      DISTribution(string)            /* gintreg
        */      Level(cilevel)                  /*
        */      NOLOg LOg                       /*
        */      OFFset(varname numeric)         /*
        */      noCONstant                      /*
        */      Robust                  /*
        */      CLuster(passthru)       /*
        */      VCE(passthru)           /*
        */      noDISPLAY               /*
        */      CONSTraints(string)     /*
        */      FROM(string)            /* +gintreg
        */      lnsigma(string)         /* gintreg
        */      p(string)               /* gintreg 
        */      q(string)               /* gintreg 
        */      lambda(string)          /* gintreg
        */      CRITTYPE(passthru)      /*
        */      Verbose                 /*
        */      moptobj(passthru)       /* NOT DOCUMENTED
        */      *                       /*
        */      ]

        GetDistOpts `distribution'
        local title "`r(title)'"
        local llf "`r(llf)'"
        local auxnames `r(auxnames)'
        local auxconstr `r(auxconstr)'
        local k_aux_eq : word count `auxnames'
        local k_eq = 1+`k_aux_eq'
        
        _vce_parse, argopt(CLuster) opt(OIM OPG Robust) old     ///
                : [`weight'`exp'], `vce' `robust' `cluster'
        local robust `r(robust)'
        local cluster `r(cluster)'
        local vce `"`r(vceopt)'"'

        _get_diopts diopts options, `options'
        mlopts mlopts, `options' const(`constraints' `auxconstr') `log' `nolog'
        local coll `s(collinear)'
        local mlopts `mlopts' `crittype'

        gettoken y1 rhs : varlist
        _fv_check_depvar `y1', depname(depvar1)
        tsunab y1 : `y1'
        gettoken y2 rhs : rhs
        _fv_check_depvar `y2', depname(depvar2)
        tsunab y2 : `y2'
        
        if "`constant'"!="" & "`rhs'"=="" {
                di as err /*
                */ "independent variables required with noconstant option"
                exit 100
        }
        if "`weight'"!="" {
                if "`weight'"!="fweight" {
                        local wt "aweight"
                }
                else    local wt "fweight"
        }
        if "`offset'"!="" {
                tempvar offvar
                qui gen double `offvar' = `offset'
                local offopt offset(`offvar')
        }
        global S_ML_off `offset'
        global S_ML_ofv `offvar'
		
        foreach aux of local auxnames {
                if ("``aux''"!="") {
                        ParseHet ``aux''
                        local `aux'_var "`r(varlist)'"
                        local `aux'_nocns "`r(constant)'"
                }
        }

/* Mark/markout. */

        tempvar doit z

        mark `doit' [`weight'`exp'] `if' `in'
        qui replace `doit' = 0 if `y1'>=. & `y2'>=.
        
        if inlist("`distribution'","lognormal","lnormal","weibull","gamma",   /*
        */ "ggamma","br3","br12","gb2") {
                qui replace `doit' = 0 if (`y2'<=0)
        }

/* Check that `y1'<=`y2' and markout independent variables. */

        capture assert `y1'<=`y2' if `y1'<. & `y2'<. & `doit'
        if _rc {
                di as err `"observations with `y1' > `y2' not allowed"'
                exit 498
        }
        markout `doit' `rhs' `offset' `lnsigma_var' `p_var' `q_var' `lambda_var'
        if "`cluster'"!="" {
                markout `doit' `cluster', strok
        }

/* Index by data type; used in evaluator files */

        tempvar idx
        qui gen byte `idx' =              ///
                cond(`y1'==`y2', 1,       /// uncensored
                cond(`y1'>=. & `y2'<., 2, /// left-censored
                cond(`y1'<. & `y2'>=., 3, /// right-censored
                cond(`y1'<. & `y2'<., 4,  /// interval
                .)))) if `doit'           //  

/* Count number of observations (and issue error 2000 if necessary). */

        _nobs `doit' [`weight'`exp']
        local N `r(N)'
        _nobs `doit' [`weight'`exp'] if `y1'==`y2', min(0)
        local Nunc `r(N)'
        _nobs `doit' [`weight'`exp'] if `y1'>=., min(0)
        local Nlc `r(N)'
        _nobs `doit' [`weight'`exp'] if `y2'>=., min(0)
        local Nrc `r(N)'

/* Remove collinearity. */
        
        fvexpand `rhs'
        local rhsorig `r(varlist)'      
        if "`y1'" == "`y2'" {
                `vv' ///
                _rmdcoll `y1' `rhs' [`weight' `exp'] if `doit', ///
                        `constant' `coll'
                local rhs `r(varlist)'
        }
        else {
                `vv' ///
                cap _rmdcoll `y1' `rhs' [`weight' `exp'] if `doit',     ///
                        `constant' `coll'
                if _rc == 459 {
                `vv' ///
                cap _rmdcoll `y2' `rhs' [`weight' `exp'] if `doit',     ///
                        `constant' `coll'
                }
                if _rc != 0 {
                        if _rc == 459 {
                                dis as err /*
                */ "`y1' and `y2' collinear with independent variables"
                                exit 459
                        }
                        error _rc
                }               
                local rhs `r(varlist)'
        }
        // collinearity report
        local i 1
        foreach var of local rhs {
                local xname : word `i' of `rhsorig'
                _ms_parse_parts `var'
                if `r(omit)' {
                        _ms_parse_parts `xname'
                        if !`r(omit)' {
                                noi di as txt "note: `xname' omitted" /*
                                        */ " because of collinearity"
                        }
                }
                local ++i
        }

        // alternate notation for gb2 tree (except lognormal)
        if inlist("`distribution'","gb2","br12","br3","ggamma","gamma","weibull") {
                if ("`lnsigma'"=="")    local diparm diparm(lnsigma, function(exp(-@)) derivative(-exp(-@)) label("a"))
                if ("`rhs'"=="")        local diparm `diparm' diparm(model, exp label("b"))
        }
                
        foreach aux of local auxnames {
                // remove collinearity from auxillary equations...
                if ("``aux''"!="") {
                        `vv' ///
                        _rmcoll ``aux'_var' [`weight' `exp'] if `doit', ///
                                ``aux'_nocns' `coll'
                        local `aux'_var `r(varlist)'
                }                
                // ... or report transformed parameters (sigma & lambda only)
                else if ("`aux'"=="lnsigma") {
                        local diparm `diparm' diparm(lnsigma, exp label("sigma"))
                }
                else if ("`aux'"=="lambda") { 
                        local diparm `diparm' diparm(lambda, tanh)
                }
                        
                local auxeq `auxeq' (`aux': ``aux'_var', ``aux'_nocns') // full model 
                local auxeq_cns `auxeq_cns' (`aux':)                    // constant only
        }

/* Starting values */
        
        if "`from'" != "" {
                // fit preliminary model if from(distribution) specified...
                if inlist("`from'","sged","ged","slaplace","laplace", ///
                          "snormal","sgt","gt","st","t")              ///
                   | inlist("`from'","gb2","burr12","burr3","ggamma", ///
                            "gamma","weibull")                        /// 
                   | inlist("`from'","","normal","lognormal","lnormal") { 
                
                        // remove from() option from cmd
                        local i0 = subinstr("`0'","from(`from')","",.)
                        // replace dist(`dist') with dist(`from')
                        local i0 = subinstr("`i0'","(`distribution')","(`from')",1)
                        
                        if "`log'"=="" {
                                di as txt _n "Fitting model with `from' distribution:"
                        }
                        gintreg `i0' nodisplay
                        
                        tempname b0 bp bq
                        matrix `b0' = e(b)
                        
                        // override default initial value from 0 to 1 for p,q
                        // ... if p,q not supplied by from(dist)
                        foreach aux in "p" "q" { 
                                if strpos("`auxnames'","`aux'") ///
                                & !strpos("`e(auxnames)'","`aux'") {
                                        matrix `b`aux'' = 1
                                        matrix colnames `b`aux'' = `aux':_cons
                                        matrix `b0' = (`b0', `b`aux'')
                                }
                        }
                        local initopt "init(`b0', skip)"
                }
                // ... or pass through from() --> init()
                else    local initopt "init(`from')"
        }

        else if "`lnsigma'`p'`q'`lambda'" == "" {

/* Generate variable `z' to get starting values. */

                qui gen double `z' =                      ///
                        cond(`y1'<.&`y2'<.,(`y1'+`y2')/2, ///
                        cond(`y1'<.,`y1',`y2'))  if `doit'

                qui summarize `z' [`wt'`exp'] if `doit', d

/* Set up initial values for the constant-only model. */

                if "`constant'"=="" { 
                        tempname b00
                        matrix `b00' = (r(mean), ln(r(sd)), 1, 1, (r(mean)-r(p50))/r(sd))
                        matrix colnames `b00' = model:_cons lnsigma:_cons p:_cons q:_cons lambda:_cons
                }
                
/* Get initial values for the full model. */

                if "`constraints'" != "" | "`rhs'" != "" {
                        tempname bs b0
                        `vv' ///
                        qui _regress `z' `rhs' [`wt'`exp'] if `doit', `constant'
                        if "`constraints'" == "" {
                                matrix `bs' = ln(e(rmse))
                                matrix `b0' = `bs'*e(b)
                                matrix colnames `bs' = lnsigma:_cons
                        }
                        else {
                                matrix `bs' = ln(e(rmse))
                                matrix `b0' = e(b)
                                matrix colnames `bs' = lnsigma:_cons
                        }
                        matrix coleq `b0' = model
                        matrix `b0' = `b0' , `bs'
                        *local initopt init(`b0', skip) // seems to work better with `continue' post-constantonly than with this active too. Maybe take this route only if `constant'~=noconstant ? (do by making THIS -if- block an -if else- block)
                }

                _parse_iterlog, `log' `nolog'
                local log "`s(nolog)'"

/* Fit constant-only model. */
		
                if "`constant'"=="" {
                        if "`log'"=="" {
                                di as txt _n "Fitting constant-only model:"
                        }
                        
                        `vv' ///
                        ml model lf `llf'               /*
                        */ (model: `y1' `y2' `idx'=)        /*
                        */ `auxeq_cns'                  /*
                        */ [`weight'`exp'] if `doit',   /*
                        */ init(`b00', skip)            /*
                        */ `mlopts'                     /*
                        */ noout                        /*
                        */ missing                      /*
                        */ collinear                    /*
                        */ nopreserve                   /*
                        */ obs(`N')                     /*
                        */ maximize                     /*
                        */ search(off)                   /* off
                        */ `robust'                     /*
                        */ nocnsnotes                   /*
                        */ `negh'

                        local contin continue
                }
        }

/* Heteroskedasticity */

        else {
                qui gintreg `y1' `y2' `rhs' [`weight'`exp'] if `doit', ///
                        dist(`distribution') `constant' `coll' const(`constraints')
                
                tempname b0 b00
                mat `b0' = e(b)
                mat `b00' = e(b)[1,1..colsof(e(b))-`k_aux_eq']
                
                foreach aux of local auxnames {
                        if ("``aux''"=="") {
                                mat `b00' = (`b00', `b0'[1,"`aux':_cons"])
                        }
                        else {
                                tempvar `aux'_con
                                gen double ``aux'_con' = `b0'[1,"`aux':_cons"] if `doit'
                                `vv' qui _regress ``aux'_con' ``aux'_var' [`wt'`exp'] if `doit', ``aux'_nocns'
                                mat `b00' = (`b00', e(b))
                        }
                }
                local initopt "init(`b00', copy)"
        }
        
/* Branch off for fitting full [constrained] model */
        if "`log'"=="" {
                di _n as txt "Fitting full model:"
        }
        
        if ("`constant'"=="") {
                local search search(off)
        }
        else    local search search(on)

/* Fit full model. */

        `vv' ///
        ml model lf `llf'                               /*
                */ (model: `y1' `y2' `idx'= `rhs', `constant' `offopt') /*
                */ `auxeq'                              /*
                */ [`weight'`exp'] if `doit',           /*
                */ `initopt'                            /*
                */ `mlopts'                             /*
                */ `vce'                                /*
                */ /*`score'*/                              /*
                */ `contin'                             /*
                */ noout                                /*
                */ missing                              /*
                */ collinear                            /*
                */ nopreserve                           /*
                */ obs(`N')                             /*
                */ maximize                             /*
                */ `search'                          /* off
                */ `diparm'                             /*
                */ `negh'                               /*
                */ `moptobj'

        ereturn local cmd
        global S_E_cmd

        ereturn scalar N_unc = `Nunc'
        ereturn scalar N_lc  = `Nlc'
        ereturn scalar N_rc  = `Nrc'
        ereturn scalar N_int = e(N) - e(N_unc) - e(N_lc) - e(N_rc)
        
        ereturn scalar k_eq     = `k_eq'
        ereturn scalar k_aux_eq = `k_aux_eq'
        
        // the following are used by gintreg_p.ado
        ereturn local distribution "`distribution'" 
        ereturn local depvars  "`y1' `y2'"
        *ereturn local indepvars "`rhs'"
        *ereturn local constant  "`constant'"
        ereturn local modelvars "`rhs'"
        ereturn local model_cns  "`constant'"
        ereturn local auxnames "`auxnames'"
        ereturn local lnsigmavars "`lnsigma_var'"
        ereturn local lnsigma_cns "`lnsigma_cns'"
        ereturn local pvars "`p_var'"
        ereturn local p_cns "`p_cns'"
        ereturn local qvars "`q_var'"
        ereturn local q_cns "`q_cns'"
        ereturn local lambdavars "`lambda_var'"
        ereturn local lambda_cns "`lambda_cns'"
        

        if strpos("`auxnames'","lnsigma") & ("`lnsigma'"=="") {
                ereturn scalar sigma = exp([lnsigma]_cons)
                ereturn scalar se_sigma = exp([lnsigma]_cons)*[lnsigma]_se[_cons]
        }
        if strpos("`auxnames'","lambda") & ("`lambda'"=="") {
                ereturn scalar lambda = tanh([lambda]_cons)
                ereturn scalar se_lambda = tanh([lambda]_cons)*[lambda]_se[_cons]
        }
        
        ereturn local predict "gintreg_p"
        ereturn local marginsok default                 ///
                                XB                      ///
                                Pr(passthru)            ///
                                E(passthru)             ///
                                YStar(passthru)

        foreach aux of local auxnames {
                if ("``aux''"!="") {
                        ereturn local het_`aux' "heteroskedasticity"
                }
        }

        if "$S_BADLC"!="" {
                ereturn scalar N_lcout = $S_BADLC
                        /* # outlier intervals approximated as LC */
                global S_BADLC
        }
        if "$S_BADRC"!="" {
                ereturn scalar N_rcout = $S_BADRC
                        /* # outlier intervals approximated as RC */
                global S_BADRC
        }
        ereturn local title  "`title'"
        ereturn local depvar `y1' `y2'
        ereturn local offset `offset'

/* Double save in S_E_. */

        global S_E_nobs `e(N)'
        global S_E_depv `e(depvar)'
        global S_E_ll   `e(ll)'
        global S_E_sig  `e(sigma)'
        global S_E_sesg `e(se_sigma)'

        global S_E_ll0  `e(ll_0)'
        global S_E_chi2 `e(chi2)'
        global S_E_mdf  `e(df_m)'

        ereturn local ml_score intrg_ll2
        ereturn local cmd "gintreg"
        global S_E_cmd `e(cmd)'
        
        * Clean up 
        constraint drop `auxconstr'

/* Display results. */

        if "`display'" == "" {
                DiGintreg, level(`level') `diopts' neq(`k_eq') // Jacob added neq() bc hetvars not reported elsewise. why?
                error `e(rc)'
        }
end

program ParseHet, rclass
		syntax varlist(fv ts numeric) [, noCONStant]
		return local varlist "`varlist'"
		return local constant `constant'
end

program define DiGintreg
        syntax [, Level(cilevel) *]

        _get_diopts diopts else, `options'
        version 9: ml display, level(`level') nofootnote `diopts' `else'
        _prefix_footnote

/* Note:  Wald test for sigma on boundary -- not reported.*/

if !missing(e(N_lcout)) | !missing(e(N_rcout)) {

/* The following messages should be VERY rare. */

        if e(N_lcout) == 1 {
                di _n as txt "Note: 1 interval observation was an " /*
                */ "extreme outlier (large negative residual)" _n /*
                */ "      and was handled by assuming it was a " /*
                */ "left-censored observation."
        }
        else if e(N_lcout) <. {
                di _n as txt "Note: `e(N_lcout)' interval observations " /*
                */ "were extreme outliers (all with large negative" _n /*
                */ "      residuals) and were handled by " /*
                */ "assuming they were left-censored observations."
        }
        if e(N_rcout) == 1 {
                di _n as txt "Note: 1 interval observation was an " /*
                */ "extreme outlier (large positive residual)" _n /*
                */ "      and was handled by assuming it was a " /*
                */ "right-censored observation."
        }
        else if e(N_rcout) <. {
                di _n as txt "Note: `e(N_rcout)' interval observations " /*
                */ "were extreme outliers (all with large positive" _n /*
                */ "      residuals) and were handled by " /*
                */ "assuming they were right-censored observations."
        }
        di as txt /*
        */ "      This is an excellent approximation for all intervals " /*
        */ "except for those" _n "      that are very narrow."

}  // if

end

program define GetDistOpts, rclass

	if inlist("`1'","","normal") {
		local title "Interval regression"
		local llf "intllf_normal"
                local auxnames "lnsigma"
	}
        else if ("`1'"=="sged") {
		local title "SGED interval regression"
		local llf "intllf_sged"
                local auxnames "lnsigma p lambda"
	}
        else if ("`1'"=="ged") {
		local title "GED interval regression"
		local llf "intllf_sged"
                local auxnames "lnsigma p lambda"
                constraint free
                constraint define `r(free)' [lambda]_cons=0
                local auxconstr `r(free)'
	}
        else if ("`1'"=="slaplace") {
		local title "Skewed Laplace interval regression"
		local llf "intllf_sged"
                local auxnames "lnsigma p lambda"
                constraint free
                constraint define `r(free)' [p]_cons=1
                local auxconstr `r(free)'
	}
        else if ("`1'"=="laplace") {
		local title "Laplace interval regression"
		local llf "intllf_sged"
                local auxnames "lnsigma p lambda"
                constraint free
                constraint define `r(free)' [lambda]_cons=0
                local auxconstr "`r(free)'"
                constraint free
                constraint define `r(free)' [p]_cons=1
                local auxconstr "`auxconstr' `r(free)'"
        }
        else if ("`1'"=="snormal") {
		local title "Skewed normal interval regression"
		local llf "intllf_sged"
                local auxnames "lnsigma p lambda"
                constraint free
                constraint define `r(free)' [p]_cons=2
                local auxconstr `r(free)'
        }
        else if inlist("`1'","lognormal","lnormal") {
		local title "Lognormal interval regression"
		local llf "intllf_lognormal"
                local auxnames "lnsigma"
	}
        else if ("`1'"=="sgt") {
		local title "Skewed Generalized t interval regression"
		local llf "intllf_sgt"
                local auxnames "lnsigma p q lambda"
	}
        else if ("`1'"=="gt") {
		local title "Generalized t interval regression"
		local llf "intllf_sgt"
                local auxnames "lnsigma p q lambda"
                constraint free
                constraint define `r(free)' [lambda]_cons=0
                local auxconstr `r(free)'
	}
        else if ("`1'"=="st") {
		local title "Skewed t interval regression"
		local llf "intllf_sgt"
                local auxnames "lnsigma p q lambda"
                constraint free
                constraint define `r(free)' [p]_cons=2
                local auxconstr `r(free)'
	}
        else if ("`1'"=="t") {
		local title "t interval regression"
		local llf "intllf_sgt"
                local auxnames "lnsigma p q lambda"
                constraint free
                constraint define `r(free)' [lambda]_cons=0
                local auxconstr "`r(free)'"
                constraint free
                constraint define `r(free)' [p]_cons=2
                local auxconstr "`auxconstr' `r(free)'"
        }
        else if ("`1'"=="ggamma") {
                local title "Generalized gamma interval regression"
                local llf "intllf_ggamma"
                local auxnames "lnsigma p"
        }
        else if ("`1'"=="gamma") {
                local title "Gamma interval regression"
                local llf "intllf_ggamma"
                local auxnames "lnsigma p"
                constraint free
                constraint define `r(free)' [lnsigma]_cons=0
                local auxconstr "`r(free)'"
        }
        else if ("`1'"=="weibull") {
                local title "Weibull interval regression"
                local llf "intllf_ggamma"
                local auxnames "lnsigma p"
                constraint free
                constraint define `r(free)' [p]_cons=1
                local auxconstr "`r(free)'"
        }
        else if ("`1'"=="gb2") {
                local title "Generalized beta of the second kind interval regression"
                local llf "intllf_gb2"
                local auxnames "lnsigma p q"
        }
        else if ("`1'"=="br12") {
                local title "Burr-12 interval regression"
                local llf "intllf_gb2"
                local auxnames "lnsigma p q""
                constraint free
                constraint define `r(free)' [p]_cons=1
                local auxconstr "`r(free)'"
        }
        else if ("`1'"=="br3") {
                local title "Burr-3 interval regression"
                local llf "intllf_gb2"
                local auxnames "lnsigma p q"
                constraint free
                constraint define `r(free)' [q]_cons=1
                local auxconstr "`r(free)'"
        }
        else {
                di as err "option distribution() specified incorrectly"
                error 198
        }

	
	return local title "`title'"
	return local llf "`llf'"
        return local auxnames "`auxnames'"
        return local auxconstr "`auxconstr'"
end