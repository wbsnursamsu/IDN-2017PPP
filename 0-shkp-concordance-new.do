* Crosswalk

import excel using "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-sus-code-crosswalk_v4.xlsx", firstrow case(lower) clear
save "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-concordance-v4.dta", replace

use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\crosswalk\shkp-concordance-v4.dta", clear
tostring komoditas2013 unit2013, replace
replace komoditas2013 = komoditas2012
replace unit2013 = unit2012
drop unit*
foreach v of varlist komoditas2010-komoditas_all {
	replace `v'= lower(`v')
    replace `v'=strltrim(`v')
    replace `v'=stritrim(`v')
    replace `v'=strrtrim(`v')
    replace `v'=strtrim(`v')	
}

* only pick consistent item missing value 4 or less
egen kmiss = rowmiss(komoditas2010-komoditas2022)
    drop if kmiss>4
    drop kmiss
	
forval t=2010/2022 {
    if (`t'>=2010 & `t'<=2014) {
        preserve
            keep komoditas`t' komoditas_all code06 name06 code17 name17
            rename komoditas`t' komoditas
            rename code06 code_c
            rename name06 name_c
            save "${gdTemp}\shkp-concordance-`t'.dta", replace
        restore
        }
    else if (`t'>=2015 & `t'<=2016) {
        preserve
            keep komoditas`t' komoditas_all code15 name15 code17 name17
            rename komoditas`t' komoditas
            rename code15 code_c
            rename name15 name_c
            save "${gdTemp}\shkp-concordance-`t'.dta", replace
        restore
        }    
    else if `t'==2017 {
        preserve 
            keep komoditas`t' komoditas_all code17 name17
            rename komoditas`t' komoditas
            gen code_c = code17
            gen name_c = name17
            save "${gdTemp}\shkp-concordance-`t'.dta", replace
        restore
        }    
    else if (`t'>=2018 & `t'<=2021) {
        preserve
            keep komoditas`t' komoditas_all code18 name18 code17 name17
            rename komoditas`t' komoditas
            rename code18 code_c
            rename name18 name_c
            save "${gdTemp}\shkp-concordance-`t'.dta", replace
        restore
        }            
    else if (`t'==2022) {
        preserve 
            keep komoditas`t' komoditas_all code22 name22 code17 name17
            rename komoditas`t' komoditas
            rename code22 code_c
            rename name22 name_c
            save "${gdTemp}\shkp-concordance-`t'.dta", replace
        restore 
        }            
    }

* merge with susenas crosswalk to get item subgroups
merge m:1 code02 code04 code05 code06 code15 code17 code18 code22 using "${gdCrsw}/consumption_module_crosswalk_cat.dta", keepusing(ditem_all)
drop if _merge==2 
drop _merge 
save "${gdCrsw}/shkp-concordance-v4-select.dta", replace	