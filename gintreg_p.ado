capture program drop gintreg_p
program define gintreg_p
        syntax newvarname [if] [in] [, xb stdp noOFFset]

        if ("`e(cmd)'"!="gintreg") {
                di as err "gintreg was not the last estimation command"
                exit 301
        }
        
        marksample doit, novarlist
        
        if ("`stdp'"!="") {
                _predict `typlist' `varlist' if `doit', stdp `offset'
                label var `varlist' "S.E. of the prediction"
                exit
        }
        
        tempvar ones 
        gen byte `ones' = 1 if `doit'
        
        local dist     "`e(distribution)'"
        local auxnames "`e(auxnames)'"
        
        // symmetric distributions
        if inlist("`dist'","","normal","ged","laplace","gt","t") {
                _predict `typlist' `varlist' if `doit', xb
                exit
        }
        
        // possibly asymmetric distributions...
        // ... find Xb for individual parameters
        // TODO: REPLACE WITH
        // foreach ... { _predict double ``eqn'', xb eq(`eqn')}
        tempname mX mXmodel mXlnsigma mXsigma mXp mXq mXlambda
        tempvar Xmodel Xlnsigma Xsigma Xp Xq Xlambda predicted    
        foreach eqn in model `auxnames' {
                if ("`e(`eqn'_nocns)'"=="") {
                        mkmat `e(`eqn'vars)' `ones', mat(`mX')
                }
                else    mkmat `e(`eqn'vars)', mat(`mX')
                mat `mX`eqn'' = e(b)[1,"`eqn':"]'
                mat `mX`eqn'' = `mX'*`mX`eqn''
                svmat `mX`eqn'', names(`X`eqn'')
        }
        qui gen double `Xsigma' = exp(`Xlnsigma') if `doit'
        
        // ... then calculate predicted values
        if inlist("`dist'","snormal","laplace","slaplace","ged","sged") {
                qui gen `predicted' = `Xmodel'+2*`Xlambda'*`Xsigma'           /*
                */ *(exp(lngamma(2/`Xp'))/exp(lngamma(1/`Xp')))        if `doit'
        }
        else if inlist("`dist'","t","gt","st","sgt") {
                qui gen `predicted' = `Xmodel'+2*`Xlambda'*`Xsigma'           /*
                */ *((`Xq'^(1/`Xp'))*(exp(lngamma(2/`Xp')+lngamma(`Xq'        /*
                */ -(1/`Xp'))-lngamma((1/`Xp')+`Xq'))/exp(lngamma(1/`Xp')     /*
                */ +lngamma(`Xq'))-lngamma((1/`Xp')+`Xq')))            if `doit'
        }
        else if inlist("`dist'","lognormal","lnormal") {
                qui gen `predicted' = exp(`Xmodel'+(`Xsigma'^2/2))     if `doit'
        }
        else if inlist("`dist'","weibull","gamma","ggamma") {
                qui gen `predicted' = exp(`Xmodel')                           /*
                */ *[exp(lngamma(`Xp'+`Xsigma'))/(exp(lngamma(`Xp')))] if `doit'
        }
        else if inlist("`dist'","br3","br12","gb2") {
                qui gen `predicted' = exp(`Xmodel')                           /*
                */ *[exp(lngamma(`Xp'+`Xsigma'))*exp(lngamma(`Xq'-`Xsigma'))  /*
                */ /(exp(lngamma(`Xp'))*exp(lngamma(`Xq')))]           if `doit'
        }
        qui gen `typlist' `varlist' = `predicted' if `doit'
end
