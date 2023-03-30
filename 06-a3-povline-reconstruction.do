********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Poverty Line Reconstruction & Asset Index
*	Subtask			: Merging HH Aggregate Expenditure data to Spatial Laspeyres
*	Input			: -
*	Note			: -
********************************************************************************

clear all
set more off
log using "${gdLog}/a3-6-povline-reconstruction.txt", replace
	
save "${gdTemp}/susenas-combine-2002-2022.dta", replace	
    
**** Merge with new spatial deflator 
use "$gdOutput/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 - ffe.dta", clear
tostring provcode_urban, replace
gen provcode = substr(provcode_urban,1,2)
gen urban = (substr(provcode_urban,3,2) == "01")
destring provcode, replace
drop provcode_urban
rename index laspeyres_ffe
tempfile provur01
save `provur01'

use "${gdTemp}/susenas-combine-2002-2022.dta", clear
merge m:1 provcode urban year using `provur01'
drop if _merge == 1
drop _merge
save "$gdOutput/Exppl - Laspeyres Merged 2002-2022 - ffe.dta", replace
	