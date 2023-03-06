********************************************************************************
***                                                                          ***
***     A3. Laspeyres Temporal                                               ***
***         3. Construct unit price                                          ***
***             - Base year is 2017                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/a3-0-3-construct-unit-price.txt", replace

********************************************************************************
***                                                                          ***
***     3.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
********************************************************************************

*** Aggregate to national level all year for p1
use "${gdTemp}/Sample/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
keep if inclusion_all_ffe==1
drop _merge inclusion_all_ffe
save "${gdTemp}/Sample/3-0-p1-p-v-q-ur-ffe.dta", replace

** Calculate price
collapse (mean) p1 [aw=wert], by(year urban code_all)
sort urban year code_all
compress
save "${gdTemp}/Sample/3-1-p1-ur-ffe.dta", replace

*** Aggregate only 2017 for p0
use "${gdTemp}/Sample/2-0-p0-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
keep if inclusion_all_ffe==1
drop _merge inclusion_all_ffe
save "${gdTemp}/Sample/3-0-p0-p-v-q-ur-ffe.dta", replace

** Calculate price
collapse (mean) p0 [aw=wert], by(urban code_all)
sort urban code_all
compress
save "${gdTemp}/Sample/3-1-p0-ur-ffe.dta", replace


********************************************************************************
***                                                                          ***
***     3.2. Calculate for food only                                         ***
***                                                                          ***
********************************************************************************

*** Aggregate to national level all year for p1
use "${gdTemp}/Sample/2-0-p1-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
keep if inclusion_all_f==1 & persistentcat=="food"
drop _merge inclusion_all_f
save "${gdTemp}/Sample/3-0-p1-p-v-q-ur-f.dta", replace

** Calculate price
collapse (mean) p1 [aw=wert], by(year urban code_all)
sort urban year code_all
save "${gdTemp}/Sample/3-1-p1-ur-f.dta", replace

*** Aggregate only 2017 for p0
use "${gdTemp}/Sample/2-0-p0-unit-price.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
keep if inclusion_all_f==1 & persistentcat=="food"
drop _merge inclusion_all_f
save "${gdTemp}/Sample/3-0-p0-p-v-q-ur-f.dta", replace

** Calculate price
collapse (mean) p0 [aw=wert], by(urban code_all)
sort urban code_all
save "${gdTemp}/Sample/3-1-p0-ur-f.dta", replace


// ********************************************************************************
// ***                                                                          ***
// ***     3.3. Calculate for energy + fuel                                     ***
// ***                                                                          ***
// ********************************************************************************
//
// *** Aggregate to national level all year for p1
// use "${gdTemp}/Sample/2-0-p1-unit-price.dta", clear
// merge m:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
// keep if inclusion_all_fe==1 & inlist(persistentcat,"fuel","energy")
// drop _merge inclusion_all_fe
// collapse (mean) p1 [aw=wert], by(year urban code_all)
// sort urban year code_all
// save "${gdTemp}/Sample/3-1-p1-ur-fe.dta", replace
//
// *** Aggregate only 2017 for p0
// use "${gdTemp}/Sample/2-0-p0-unit-price.dta", clear
// merge 1:1 urban code_all using "${gdTemp}/Sample/2-1-inclusion-all.dta"
// keep if inclusion_all_fe==1 & inlist(persistentcat,"fuel","energy")
// drop _merge inclusion_all_fe
// collapse (mean) p0 [aw=wert], by(urban code_all)
// sort urban code_all
// save "${gdTemp}/Sample/3-1-p0-ur-fe.dta", replace
