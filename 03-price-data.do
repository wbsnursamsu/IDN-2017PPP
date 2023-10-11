
    * -------------------------------------------------------------------- *
    * Setup price data from price survey to HH
    * -------------------------------------------------------------------- *
    
clear all
set more off

    /* SHK */

/*** identifier to sum value in hh based on ***/

forval t=2010/2022 {
    use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-concordance-`t'.dta", clear
    g komoditas2 = lower(komoditas)
    drop komoditas
    rename komoditas2 komoditas 
    
    replace komoditas=strltrim(komoditas)
    replace komoditas=stritrim(komoditas)
    replace komoditas=strrtrim(komoditas)
    replace komoditas=strtrim(komoditas)
    
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop code_c, force
        gen urban=1
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    duplicates drop komoditas, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata/shk-price-2010-2022.dta", clear
        g komoditas2 = lower(komoditas)
        drop komoditas
        rename komoditas2 komoditas 
        
        replace komoditas=strltrim(komoditas)
        replace komoditas=stritrim(komoditas)
        replace komoditas=strrtrim(komoditas)
        replace komoditas=strtrim(komoditas)
        keep if year==`t'
        
        foreach v of varlist jan-avg {
            replace `v' = `v'*1000 if `v'<300
            }
        
    * geometric mean province
    foreach v of varlist jan-avg {
		egen g_`v' = gmean(`v'), by(prov komoditas)
        }
    collapse (mean) g_*, by(prov komoditas)

    * geometric mean commodities 
        merge m:1 komoditas using `crwunique', keepusing(komoditas code_c)
            drop if _merge!=3
            drop _merge

        foreach v of varlist g_jan-g_avg {
            egen p_`v' = gmean(`v'), by(prov code_c)
        }            
    collapse (sum) p_*, by(prov code_c)
    
    rename prov provcode
    rename code_c kode
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-`t'.dta", replace
}    

/* merge SHK for spatial deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-2015.dta", clear

gen year=2010
forval t=2011/2022 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
fillin year provcode kode
drop _fillin
gen urban=1  

sort kode provcode year
foreach v of varlist p_g_jan-p_g_avg {
    bys kode provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2015 & `v'==.
    bys kode provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2017 & `v'==.
    bys kode provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2018 & `v'==.    
    }

order year provcode urban, first
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-ALL.dta", replace


    /* SHKP */
    
/*** identifier to sum value in hh based on ***/

forval t=2010/2022 {
    use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", clear
    g komoditas2 = lower(komoditas)
    drop komoditas
    rename komoditas2 komoditas 
    
    replace komoditas=strltrim(komoditas)
    replace komoditas=stritrim(komoditas)
    replace komoditas=strrtrim(komoditas)
    replace komoditas=strtrim(komoditas)
    
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop code_c, force
        gen urban=0
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    duplicates drop komoditas, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\stata\shkp-2010-2022-clean.dta", clear
        g komoditas2 = lower(komoditas)
        drop komoditas
        rename komoditas2 komoditas 
        
        replace komoditas=strltrim(komoditas)
        replace komoditas=stritrim(komoditas)
        replace komoditas=strrtrim(komoditas)
        replace komoditas=strtrim(komoditas)
        keep if year==`t'        
        destring jan-avg, replace force
    
    drop prov 
    rename provcode prov
    
    * geometric mean province
    foreach v of varlist jan-avg {
            egen g_`v' = gmean(`v'), by(prov komoditas)
        }
    collapse (mean) g_*, by(prov komoditas)

    * geometric mean commodities 
        merge m:1 komoditas using `crwunique', keepusing(komoditas code_c)
            drop if _merge!=3
            drop _merge

        foreach v of varlist g_jan-g_avg {
            egen p_`v' = gmean(`v'), by(prov code_c)
        }            
    collapse (sum) p_*, by(prov code_c)
    
    rename prov provcode
    rename code_c kode
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-price-prov-bpscode-`t'.dta", replace
}        

/* merge SHKP for spatial deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-price-prov-bpscode-2010.dta", clear
gen year=2010
forval t=2011/2022 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
foreach v of varlist p_g_jan-p_g_avg {
    replace `v '= . if year==2013    
    }
fillin year provcode kode
drop _fillin
gen urban=0    

sort kode provcode year
foreach v of varlist p_g_jan-p_g_avg {
    bys kode provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2013 & `v'==.
    }
order year provcode urban, first
sort provcode kode year 
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-price-prov-bpscode-ALL.dta", replace

/* APPEND EVERYTHING */
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-ALL.dta", clear 
append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-ALL.dta"


foreach v of varlist p_g_jan-p_g_avg {
	replace `v'=. if `v'==0
	}
