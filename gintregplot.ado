program define gintregplot, rclass

        syntax  [anything]      /*
        */      [if] [in] [,    /*
        */      hist(varlist)   /*
        */      *               /* -graph twoway- options
        */      ] 
        
        if ("`e(cmd)'"!="gintreg") {
                di as err "gintreg was not the last estimation command"
                exit 301
        }
        
        // list indepvars from all eqns
        local indepvars : colvarlist e(b)
        local indepvars : list uniq indepvars 
        local constant _cons
        local indepvars : list indepvars - constant
        
        // remove indepvar if specified in `anything'
        foreach any of local anything {
                capture unab any : `any'
                if (!_rc) local indepvars : list indepvars - any
        }
        
        // collapse `anything' plus other indepvars at mean
        preserve
        capture collapse `indepvars' `anything' `if' `in', fast
        
        // get predicted values for each parameter equation
        foreach eqn in model `e(auxnames)' {
                tempvar `eqn'
                _predict double ``eqn''_p in 1, eq(`eqn')
                local `eqn' = ``eqn''_p[1]
        }
        if inlist("`e(distribution)'","gb2","br12","br3","ggamma","gamma","weibull") {
                local a = 1/exp(`lnsigma')
                local b = exp(`model')
        }
        
        // get graph function
        if inlist("`e(distribution)'","","normal") {
                local graphfn "normalden(x,`model',exp(`lnsigma'))"
        }
        else if inlist("`e(distribution)'","sged","ged","slaplce","laplace","snormal") {
                local G = exp(lngamma(1/`p'))
                local graphfn "[`p'*exp(-(abs(x-`model')^`p'/((1+`lambda'*sign(x-`model'))^`p'*exp(`lnsigma')^`p')))] / [2*exp(`lnsigma')*`G']"
        }
        else if inlist("`e(distribution)'","sgt","st","gt","t") {
                local B = exp(lngamma(1/`p')+lngamma(`q')-lngamma(1/`p'+`q'))
                local graphfn "`p'/[(2*exp(`lnsigma')*`q'^(1/`p')*`B')*(1+(abs(x-`model')^`p')/(`q'*exp(`lnsigma')^`p'*(1+`lambda'*sign(x-`model'))^`p'))^(`q'+1/`p')]"
        }
        else if inlist("`e(distribution)'","lognormal","lnormal") {
                local graphfn "[exp(-ln(x))-`model')^2/2*exp(`lnsigma')^2] / sqrt(2*c(pi)*x*exp(`lnsigma'))"
        }
        else if inlist("`e(distribution)'","ggamma","gamma","weibull") {
                local G = exp(lngamma(`p'))
                local graphfn "[abs(`a')*(x/`b')^(`a'*`p')*exp(-(x/`b')^`a')]/[x*`G']"
        }
        else if inlist("`e(distribution)'","gb2","br12","br3") {
                local B =  exp(lngamma(`p')+lngamma(`q')-lngamma(`p'+`q'))
                local graphfn "[abs(`a')*(x/`b')^(`a'*`p')]/[x*(`B')*(1+(x/`b')^`a')^(`p'+`q')]"
        }
        
        // clean up 
        if (!_rc) restore
        return local graphfn "`graphfn'"
        
        // draw graph
        if ("`hist'"!="") {
                hist `hist', plot(function y=`graphfn', `options')
        }
        else    graph twoway function y=`graphfn', `options'

end