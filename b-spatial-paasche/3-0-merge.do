	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */

forval t=0/5 {
    use "${gdOutput}/spdef-med-hh-2010-`t'.dta", clear
    forval j=2011/2022 {
        append using "${gdOutput}/spdef-med-hh-`j'-`t'.dta"
        }
    save "${gdOutput}/01-spdef-hh-`t'-2010-2022.dta", replace
    }    
    
* PIP

forval t=0/5 {
    /* Province */
    use "${gdOutput}/01-spdef-hh-`t'-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov year) 
    replace pdef=1 if pdef==.
    rename pdef pdef`t'
    tempfile prv`t'
    save `prv`t'', replace
    
    /* Stratum */    
    use "${gdOutput}/01-spdef-hh-`t'-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov urban year) 
    replace pdef=1 if pdef==.
    rename pdef pdef`t'
    tempfile str`t'
    save `str`t'', replace
    
    /* Regency */    
    use "${gdOutput}/01-spdef-hh-`t'-2010-2022.dta", clear    
    collapse (median) pdef [weight = popw] , by(prov rege year) 
    replace pdef=1 if pdef==.
    rename pdef pdef`t'
    tempfile rgc`t'
    save `rgc`t'', replace    
    }

/* Province */
use `prv0', clear
forval t=1/5 {
    merge 1:1 prov year using `prv`t'', nogen
    }
la var pdef0 "Spatial deflator - food fuel rent"
la var pdef1 "Spatial deflator - food fuel nonfood rent"
la var pdef2 "Spatial deflator - food fuel nonfood"
la var pdef3 "Spatial deflator - food fuel"
la var pdef4 "Spatial deflator - nonfood"
la var pdef5 "Spatial deflator - rent"
save "${gdOutput}/02-spdef-prv-2010-2022", replace 

/* Stratum */
use `str0', clear
forval t=1/5 {
    merge 1:1 prov urban year using `str`t'', nogen
    }
la var pdef0 "Spatial deflator - food fuel rent"
la var pdef1 "Spatial deflator - food fuel nonfood rent"
la var pdef2 "Spatial deflator - food fuel nonfood"
la var pdef3 "Spatial deflator - food fuel"
la var pdef4 "Spatial deflator - nonfood"
la var pdef5 "Spatial deflator - rent"
save "${gdOutput}/02-spdef-str-2010-2022", replace 

/* Regency */
use `rgc0', clear
forval t=1/5 {
    merge 1:1 prov rege year using `rgc`t'', nogen
    }
la var pdef0 "Spatial deflator - food fuel rent"
la var pdef1 "Spatial deflator - food fuel nonfood rent"
la var pdef2 "Spatial deflator - food fuel nonfood"
la var pdef3 "Spatial deflator - food fuel"
la var pdef4 "Spatial deflator - nonfood"
la var pdef5 "Spatial deflator - rent"
save "${gdOutput}/02-spdef-rgc-2010-2022", replace 

*add 2013 & 2014 	
// /* Compile rent deflator */
// 	* use stratum level 
//     use "${gdOutput}/spdef-med-str-2010-2022.dta", clear
// 	merge 1:1 year prov urban using "${gdOutput}/rent-price-all-3.dta", keepusing(prent_pi)
// 	keep if _merge==3
// 	drop _merge
//	
// 	la var prent_pi "Rent deflator"
//	
// 	save "${gdOutput}/spdef-med-str-rent-2010-2022.dta", replace
// 	export excel "${gdOutput}/spdef-med-str-rent-2010-2022.xlsx", firstrow(varlabels) replace