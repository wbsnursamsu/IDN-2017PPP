	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */

use "${gdOutput}/spdef-med-hh-2002-0.dta", clear
forval t=2003/2023 {
    append using "${gdOutput}/spdef-med-hh-`t'-0.dta"
    }    
save "${gdOutput}/01-spdef-hh-fix-2002-2023.dta", replace
    
/* Province */
use "${gdOutput}/01-spdef-hh-fix-2002-2023.dta", clear
collapse (median) pdef [weight = popw] , by(prov year) 
replace pdef=1 if pdef==.
la var pdef "Spatial deflator"
save "${gdOutput}/02-spdef-prv-2002-2023-fix.dta", replace 

/* Stratum */    
use "${gdOutput}/01-spdef-hh-fix-2002-2023.dta", clear
collapse (median) pdef [weight = popw] , by(prov urban year) 
replace pdef=1 if pdef==.
la var pdef "Spatial deflator"
save "${gdOutput}/02-spdef-str-2002-2023-fix.dta", replace 

/* Regency */    
use "${gdOutput}/01-spdef-hh-fix-2002-2023.dta", clear    
collapse (median) pdef [weight = popw] , by(prov rege year) 
replace pdef=1 if pdef==.
la var pdef "Spatial deflator"
save "${gdOutput}/02-spdef-rgc-2002-2023-fix.dta", replace 

    /* For urban deflator */
use "${gdOutput}/01-spdef-hh-fix-2002-2023.dta", clear    
collapse (median) pdef [weight = popw] , by(urban year)
drop if urban==0
drop urban
rename pdef udef 
gen udef2017 = udef if year==2017
egen maxa = max(udef2017)
drop udef2017 
rename maxa udef2017
gen udef2011 = udef if year==2011
egen maxb = max(udef2011)
drop udef2011 
rename maxb udef2011
save "${gdOutput}/02-udef-2002-2023.dta", replace
     
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