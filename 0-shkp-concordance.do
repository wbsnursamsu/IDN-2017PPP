* Crosswalk

import excel using "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-sus-code-crosswalk_v2.xlsx", firstrow case(lower) clear
save "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-concordance-all.dta", replace

use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-concordance-all.dta", clear
tostring komoditas2013 unit2013, replace
replace komoditas2013 = komoditas2012
replace unit2013 = unit2012

forval t=2010/2022 {
    if (`t'>=2010 & `t'<=2014) {
        preserve
            keep komoditas`t' unit`t' code06 name06 code17 name17
            rename komoditas`t' komoditas
            rename unit`t' unit
            drop if missing(komoditas)
            rename code06 code_c
            rename name06 name_c
            save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", replace
        restore
        }
    else if (`t'>=2015 & `t'<=2016) {
        preserve
            keep komoditas`t' unit`t' code15 name15 code17 name17
            rename komoditas`t' komoditas
            rename unit`t' unit
            drop if missing(komoditas)
            rename code15 code_c
            rename name15 name_c
            save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", replace
        restore
        }    
    else if `t'==2017 {
        preserve 
            keep komoditas`t' unit`t' code17 name17
            rename komoditas`t' komoditas
            rename unit`t' unit
            drop if missing(komoditas)
            gen code_c = code17
            gen name_c = name17
            save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", replace
        restore
        }    
    else if (`t'>=2018 & `t'<=2021) {
        preserve
            keep komoditas`t' unit`t' code18 name18 code17 name17
            rename komoditas`t' komoditas
            rename unit`t' unit
            drop if missing(komoditas)
            rename code18 code_c
            rename name18 name_c
            save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", replace
        restore
        }            
    else if (`t'==2022) {
        preserve 
            keep komoditas`t' unit`t' code22 name22 code17 name17
            rename komoditas`t' komoditas
            rename unit`t' unit
            drop if missing(komoditas)
            rename code22 code_c
            rename name22 name_c
            save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", replace
        restore 
        }            
    }