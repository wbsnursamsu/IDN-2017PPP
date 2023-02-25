********************************************************************************
***                                                                          ***
***     A3. Laspeyres Temporal                                               ***
***         3. Construct unit price                                          ***
***             - Base year is 2017                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off

** 0. Data setup -> Merge with inclusion
use "${gdTemp}/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all==1
drop _merge inclusion_all
compress
save "${gdTemp}/3-0-p1-unit-price-inclusion.dta", replace

use "${gdTemp}/3-0-p0-unit-price.dta", clear
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all==1
drop _merge inclusion_all
compress
save "${gdTemp}/3-0-p0-unit-price-inclusion.dta", replace

********************************************************************************
***                                                                          ***
***     3.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
********************************************************************************

*** Aggregate to national level all year for p1
use "${gdTemp}/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_ffe==1
drop _merge inclusion_all_ffe
collapse (mean) p1 [aw=wert], by(year urban code_all)
sort urban year code_all
compress
save "${gdTemp}/3-1-p1-ur-ffe.dta", replace

*** Aggregate only 2017 for p0
use "${gdTemp}/2-0-p0-unit-price.dta", clear
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_ffe==1
drop _merge inclusion_all_ffe
collapse (mean) p0 [aw=wert], by(urban code_all)
sort urban code_all
compress
save "${gdTemp}/3-1-p0-ur-ffe.dta", replace


********************************************************************************
***                                                                          ***
***     3.2. Calculate for food only                                         ***
***                                                                          ***
********************************************************************************

*** Aggregate to national level all year for p1
use "${gdTemp}/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_f==1 & persistentcat=="food"
drop _merge inclusion_all_f
collapse (mean) p1 [aw=wert], by(year urban code_all)
sort urban year code_all
save "${gdTemp}/3-1-p1-ur-f.dta", replace

*** Aggregate only 2017 for p0
use "${gdTemp}/2-0-p0-unit-price.dta", clear
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_f==1 & persistentcat=="food"
drop _merge inclusion_all_f
collapse (mean) p0 [aw=wert], by(urban code_all)
sort urban code_all
save "${gdTemp}/3-1-p0-ur-f.dta", replace


********************************************************************************
***                                                                          ***
***     3.3. Calculate for energy + fuel                                     ***
***                                                                          ***
********************************************************************************

*** Aggregate to national level all year for p1
use "${gdTemp}/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_fe==1 & inlist(persistentcat,"fuel","energy")
drop _merge inclusion_all_fe
collapse (mean) p1 [aw=wert], by(year urban code_all)
sort urban year code_all
save "${gdTemp}/3-1-p1-ur-fe.dta", replace

*** Aggregate only 2017 for p0
use "${gdTemp}/2-0-p0-unit-price.dta", clear
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-all.dta"
keep if inclusion_all_fe==1 & inlist(persistentcat,"fuel","energy")
drop _merge inclusion_all_fe
collapse (mean) p0 [aw=wert], by(urban code_all)
sort urban code_all
save "${gdTemp}/3-1-p0-ur-fe.dta", replace