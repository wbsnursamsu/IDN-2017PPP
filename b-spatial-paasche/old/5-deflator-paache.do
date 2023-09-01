********************************************************************************
***                                                                          ***
***     B. Laspeyres Spatial                                                 ***
***         5. Calculate spatial deflator - Paache                           ***
***                                                                          ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/b-0-5-deflator-paache.txt", replace

********************************************************************************
***                                                                          ***
***     5.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
******************************************************************************** 

foreach t in 02 06 10 14 18 22 {
    *** Combine dataset
    use "${gdTemp}/3-2-spatial-po-pi-`t'.dta", clear
    destring kode, replace
    *use plutocratic share
    merge m:1 provcode urban kode using "${gdTemp}/4-1-spatial-paasche-plutocratic-`t'.dta", nogen


    *** Calculate index
    gen paache_share = (s_v*po/pi)
    collapse (sum) paache_share, by(provcode urban year)
    gen paache_index = paache_share^(-1)
    label var paache_index "Spatial Paache UR"

    save "${gdTemp}/5-1-spatial-paache-index-`t'.dta", replace    
}