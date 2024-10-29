********************************************************************************
*	Project			: Poverty Measurement Simulation 
*   Task            : Calculate komoditas 44 weights: qty (q) and cal (c)
********************************************************************************

clear all
set more off
cap log close
log using "${gdLog}/03-data-cleaning.smcl", replace

**# change to forval later for loop
local t=2023    

        ************************
        * Consumption module
        ************************
    
**# change `t' later
    use "${gdSusc}/sus-cm-mar-2017-full.dta", clear

    keep if inlist(ditem_all,"food","processed","tobacco","rent","energy","fuel")                      // Keep food item only
    drop if q==.                                                                // drop any unconsumed food (if any)
    
    merge m:1 code17 using "${gdLDat}/crosswalk-2017.dta", keepusing(code18 code22) nogen
    drop if missing(urut)
    
**# Match with Komoditas 44 data
    merge m:1 code22 using "${gdLDat}/komoditas44-tag.dta", keepusing(kom44)
        drop if _merge!=3 & inlist(ditem_all,"food","processed","tobacco")
        drop _merge
        
tempfile cons2018
save `cons2018', replace

**# calculate median quantity weight (q0) and calorie (c0) only for 2023
    g v_m = ((v/7)*365)/12
    g q_m = ((q/7)*365)/12
    g c_m = ((c/7)*365)/12
    
    g code2017=code17
    g code2018=code18
    g code2019=code18
    g code2020=code18
    g code2021=code18
    g code2022=code22
    g code2023=code22
    
    * collapse
    collapse (median) v_all=v_m q_all=q_m c_all=c_m [fw=int(weind)], by(code2017 code2018 code2019 code2020 code2021 code2022 code2023)
    greshape long code, i(q_all c_all) j(year)
    
    bys year: egen tv = total(v_all)
    bys year: egen tq = total(q_all)
    bys year: egen tc = total(c_all)
    
    g shv = v_all/tv
    g shq = q_all/tq
    g shc = c_all/tc
    
    g komoditas44=1
    
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP/Temp/weights-laspeyres-2018.dta", replace 
    