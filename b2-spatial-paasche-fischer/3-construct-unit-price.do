********************************************************************************
***                                                                          ***
***     B3. Laspeyres Spatial                                                ***
***         3. Construct unit price                                          ***
***             - Base price is national level                               ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/b-0-3-spatial-unit-price.txt", replace

********************************************************************************
***                                                                          ***
***     3.1. Calculate for food + fuel + energy                              ***
***                                                                          ***
********************************************************************************

foreach t in 02 06 10 14 18 22 {
    use "${gdOutput}/SUS_Mod`t'.dta", clear
    
    *** 0. Generate price data
    keep year urut provcode urban kode q v weind wert
    gen p = v/q

    *** 1. Merge with inclusion criteria
    merge m:1 kode using "${gdOutput}/2-1-spatial-inclusion-all-`t'.dta"
    keep if inclusion_all==1
    drop _merge inclusion_all
    save "${gdTemp}/3-0-spatial-p-v-q-ur-`t'.dta", replace

    ** Calculate price
    *po
    preserve
        collapse (mean) po=p [aw=wert],by(year urban kode)
        sort year urban kode
        compress
        save "${gdTemp}/3-1-spatial-po-`t'.dta", replace
    restore
    
    *pi
    use "${gdTemp}/3-0-spatial-p-v-q-ur-`t'.dta", clear
    collapse (mean) pi=p [aw=wert], by(year urban provcode kode)
    merge m:1 year urban kode using "${gdTemp}/3-1-spatial-po-`t'.dta", keepusing(po)
    
    ** --------------------------------- NOTE ------------------------------- **
    ** If there are some regions not consuming the item even at               **
    ** above 1% share at national level, we will use higher aggregation data  **
    ** ---------------------------------------------------------------------- **
    replace pi = po if pi==.
    save "${gdTemp}/3-2-spatial-po-pi-`t'.dta", replace
}

