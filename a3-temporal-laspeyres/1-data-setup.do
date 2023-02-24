***                                                                          ***
***                          Laspeyres Temporal                              ***
***                             1. Data setup                                ***
***                                                                          ***

clear 
set more off

*** Data setup for crosswalk categories
use "${gdData}/Crosswalk/consumption_module_crosswalk_cat.dta", clear

** Decide which commodity codes that are persistent over time 
gen persistentitem = !inlist("",item02,item04,item05,item06,item15,item17,item18)

** Define categories for all items
gen allcategories = item18
replace allcategories = item17 if missing(allcategories)
replace allcategories = item15 if missing(allcategories)
replace allcategories = item06 if missing(allcategories)
replace allcategories = item05 if missing(allcategories)
replace allcategories = item04 if missing(allcategories)
replace allcategories = item02 if missing(allcategories)

** Define categories that are persistent over time
gen persistentcat = allcategories if persistentitem==1

** Generate new commodity number for persistent items over time
preserve
    tempfile editdat
    drop if persistentitem==0
    gen code_all = _n
    save `editdat', replace
restore

merge 1:1 code02 name02 code04 name04 code05 name05 code06 name06 code15 name15 code17 name17 code18 name18 using `editdat', keepusing(code_all)
drop _merge

save "${gdTemp}/consumption-module-crosswalk-2002-2022.dta", replace

*** Data setup for SUSENAS consumption by making commodities consistent over time

foreach y in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
    use "${gdOutput}/SUS_Mod`y'.dta", clear
    local t = 2000+`y'
    
    *TEST: Put sample*
    sample 20
    
    merge m:1 code02 code04 code05 code06 code15 code17 code18 using "${gdTemp}/consumption-module-crosswalk-2002-2022.dta", keepusing(code_all allcategories persistentitem persistentcat)
    drop if _merge==2
    drop _merge
    
    * drop unneeded item and categories
    drop if code_all==.
    drop if persistentcat==""

    save "${gdTemp}/1-susenas-consumption-consistent-item-`t'.dta", replace
}

*** Data setup for SUSENAS consumption all year
forval t=2002/2022 {
    if `t'==2002 {
        use "${gdTemp}/1-susenas-consumption-consistent-item-2002.dta", clear
    }
    else {
        append using "${gdTemp}/1-susenas-consumption-consistent-item-2002.dta"
        save "${gdTemp}/1-susenas-consumption-consistent-item-all-year.dta", replace
    }    
}

