	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

/* Regency - Food Fuel - 2023 */    
use "${gdOutput}/spdef-med-hh-2023-foodfuel-comp.dta", clear    
collapse (median) pdef [weight = popw] , by(prov rege year) 
replace pdef=1 if pdef==.
la var pdef "Spatial deflator - Food Fuel"
rename pdef pdef_ff
save "${gdOutput}/02-spdef-rgc-ff-2023-comp.dta", replace 

/* Regency - ALL - 2022 */    
use "${gdOutput}/spdef-med-hh-2022-all-comp.dta", clear    
collapse (median) pdef [weight = popw] , by(prov rege year) 
replace pdef=1 if pdef==.
la var pdef "Spatial deflator - All items"
rename pdef pdef_all
save "${gdOutput}/02-spdef-rgc-all-2022-comp.dta", replace 

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