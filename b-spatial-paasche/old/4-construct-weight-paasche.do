********************************************************************************
***                                                                          ***
***     B. Laspeyres Spatial                                                 ***
***         4. Construct weights for Paache                                  ***
***                                                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/b-0-4-construct-weight-spatial.txt", replace

********************************************************************************
***                                                                          ***
***     4.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
********************************************************************************

foreach t in 02 06 10 14 18 22 {
    use "${gdTemp}/3-0-spatial-p-v-q-ur-`t'.dta", clear
    keep provcode urban urut kode v wert weind
    destring kode, replace
    reshape wide v,i(provcode urban urut) j(kode)
    foreach var of varlist v* {
        replace `var' = 0 if `var'==.
    }
    save "${gdTemp}/4-0-spatial-weights-`t'.dta", replace
    
    *** Plutocratic share (item consumption and total consumption first before creating share)
    use "${gdTemp}/4-0-spatial-weights-`t'.dta", clear
    egen tv = rowtotal(v*)
    collapse (mean) v* tv [aw=wert],by(provcode urban)
    foreach p of varlist v* {
        gen s_`p' = `p'/tv
    }
    
    keep provcode urban s_v*
    reshape long s_v, i(provcode urban) j(kode)
    drop if s_v==0
    save "${gdTemp}/4-1-spatial-paache-plutocratic-`t'.dta", replace
    
    *** Democratic share (Averaging share of items)
    use "${gdTemp}/4-0-spatial-weights-`t'.dta", clear
    egen tv = rowtotal(v*)
    foreach p of varlist v* {
        gen s_`p' = `p'/tv 
    }
    collapse (mean) s_v* [aw=weind], by(provcode urban)
    reshape long s_v, i(provcode urban) j(kode)
    drop if s_v==0
    save "${gdTemp}/4-1-spatial-paache-democratic-`t'.dta", replace
}
    
    