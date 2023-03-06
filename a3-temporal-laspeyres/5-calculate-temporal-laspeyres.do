********************************************************************************
***                                                                          ***
***     A3. Laspeyres Temporal                                               ***
***         5. Construct consumption share                                   ***
***             - Base year is 2017                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/a3-0-5-calculate-temporal-laspeyres.txt", replace

********************************************************************************
***                                                                          ***
***     5.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
******************************************************************************** 

*** Combine dataset
use "${gdTemp}/Sample/3-1-p1-ur-ffe.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/3-1-p0-ur-ffe.dta", nogen
*use plutocratic share
merge m:1 urban code_all using "${gdTemp}/Sample/4-1-plutocratic-2017-ur-ffe.dta", nogen

*** Calculate index
gen tlasp_ffe_2017 = s_v*p1/p0
collapse (sum) tlasp_ffe_2017, by(urban year)
label var tlasp_ffe_2017 "Temporal laspeyres UR FFE 2017base"

save "${gdTemp}/5-1-temp-lasp-ur-2017-ffe.dta", replace

********************************************************************************
***                                                                          ***
***     5.2. Calculate for food only                                         ***
***                                                                          ***
******************************************************************************** 

*** Combine dataset
use "${gdTemp}/Sample/3-1-p1-ur-f.dta", clear
merge m:1 urban code_all using "${gdTemp}/Sample/3-1-p0-ur-f.dta", nogen
*use plutocratic share
merge m:1 urban code_all using "${gdTemp}/Sample/4-1-plutocratic-2017-ur-f.dta", nogen

*** Calculate index
gen tlasp_f_2017 = s_v*p1/p0
collapse (sum) tlasp_f_2017, by(urban year)
label var tlasp_f_2017 "Temporal laspeyres UR F 2017base"

save "${gdTemp}/5-1-temp-lasp-ur-2017-f.dta", replace