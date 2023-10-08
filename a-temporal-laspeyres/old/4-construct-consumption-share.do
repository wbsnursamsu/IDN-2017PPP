********************************************************************************
***                                                                          ***
***     A3. Laspeyres Temporal                                               ***
***         4. Construct consumption share                                   ***
***             - Base year is 2017                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/a3-0-4-construct-weights.txt", replace

********************************************************************************
***                                                                          ***
***     4.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
******************************************************************************** 

use "${gdTemp}/Sample/3-0-p0-p-v-q-ur-ffe.dta", clear
keep provcode urban urut code_all v wert weind
reshape wide v,i(provcode urban urut) j(code_all)
foreach var of varlist v* {
    replace `var' = 0 if `var'==.
}
save "${gdTemp}/Sample/4-0-share-2017-ur-ffe.dta", replace 

*** Plutocratic share (item consumption and total consumption first before creating share)
use "${gdTemp}/Sample/4-0-share-2017-ur-ffe.dta", clear
egen tv = rowtotal(v*)
collapse (mean) v* tv [aw=wert], by(urban)
foreach p of varlist v* {
    gen s_`p' = `p'/tv 
}
keep urban s_v* 
reshape long s_v, i(urban) j(code_all)
drop if s_v==0
save "${gdTemp}/Sample/4-1-plutocratic-2017-ur-ffe.dta", replace 

*** Democratic share (Averaging share of items)
use "${gdTemp}/Sample/4-0-share-2017-ur-ffe.dta", clear
egen tv = rowtotal(v*)
foreach p of varlist v* {
    gen s_`p' = `p'/tv 
}
collapse (mean) s_v* [aw=weind], by(urban)
reshape long s_v, i(urban) j(code_all)
drop if s_v==0
save "${gdTemp}/Sample/4-1-democratic-2017-ur-ffe.dta", replace 

********************************************************************************
***                                                                          ***
***     4.2. Calculate for food only                                         ***
***                                                                          ***
******************************************************************************** 

use "${gdTemp}/Sample/3-0-p0-p-v-q-ur-f.dta", clear
keep provcode urban urut code_all v wert weind
reshape wide v,i(provcode urban urut) j(code_all)
foreach var of varlist v* {
    replace `var' = 0 if `var'==.
}
save "${gdTemp}/Sample/4-0-share-2017-ur-f.dta", replace 

*** Plutocratic share (item consumption and total consumption first before creating share)
use "${gdTemp}/Sample/4-0-share-2017-ur-f.dta", clear
egen tv = rowtotal(v*)
collapse (mean) v* tv [aw=wert], by(urban)
foreach p of varlist v* {
    gen s_`p' = `p'/tv 
}
keep urban s_v* 
reshape long s_v, i(urban) j(code_all)
drop if s_v==0
save "${gdTemp}/Sample/4-1-plutocratic-2017-ur-f.dta", replace 

*** Democratic share (Averaging share of items)
use "${gdTemp}/Sample/4-0-share-2017-ur-f.dta", clear
egen tv = rowtotal(v*)
foreach p of varlist v* {
    gen s_`p' = `p'/tv 
}
collapse (mean) s_v* [aw=weind], by(urban)
reshape long s_v, i(urban) j(code_all)
drop if s_v==0
save "${gdTemp}/Sample/4-1-democratic-2017-ur-f.dta", replace 

