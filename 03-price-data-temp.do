
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
    
    drop if code17==.
    
    g code_2 = code17
    bys komoditas: replace code_2 = code17[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code17 code_2
        duplicates drop 
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-temp-adjust-`t'.dta", replace
    restore
        
    replace code17 = code_2
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
			destring `v', replace force
			replace `v' = `v'*1000 if `v'<300
            }
    
    * geometric mean province
    foreach v of varlist jan-avg {
		egen g_`v' = gmean(`v'), by(prov komoditas)
        }
    collapse (mean) g_*, by(prov komoditas)

    
    * geometric mean commodities 
        merge m:1 komoditas using `crwunique', keepusing(komoditas code17 name17)
        drop if _merge!=3
        drop _merge
        
        foreach v of varlist g_jan-g_avg {
            egen p_`v' = gmean(`v'), by(prov code17)
        }            
    collapse (sum) p_*, by(prov code17)
    
    rename prov provcode 
    
    su p_g_*
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-`t'.dta", replace
}    

/* merge SHK for temporal deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-2010.dta", clear

gen year=2010
forval t=2011/2022 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
	
fillin year provcode code17
drop _fillin
gen urban=1  

sort code17 provcode year
foreach v of varlist p_g_jan-p_g_avg {
    bys code17 provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2015 & `v'==.
    bys code17 provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2017 & `v'==.
    bys code17 provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2018 & `v'==.    
    }

order year provcode urban, first
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-ALL.dta", replace


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

    drop if code17==.
    
    g code_2 = code17
    bys komoditas: replace code_2 = code17[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code17 code_2
        duplicates drop code17, force
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-adjust-`t'.dta", replace
    restore
        
    replace code17 = code_2
    duplicates drop komoditas, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\stata/shkp-2010-2022-clean.dta", clear
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
        merge m:1 komoditas using `crwunique', keepusing(komoditas code17 name17)
        drop if _merge!=3
        drop _merge
        
        foreach v of varlist g_jan-g_avg {
            egen p_`v' = gmean(`v'), by(prov code17)
        }            
    collapse (sum) p_*, by(prov code17)

    rename prov provcode
	
    su p_g_*
	
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-`t'.dta", replace
}

/* merge SHKP for temporal deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-2010.dta", clear
gen year=2010
forval t=2011/2022 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
	
foreach v of varlist p_g_jan-p_g_avg {
    replace `v '= . if year==2013    
    }

fillin year provcode code17
drop _fillin
gen urban=0
    
sort code17 provcode year

foreach v of varlist p_g_jan-p_g_avg {
    bys code17 provcode: replace `v' = (`v'[_n-1]+`v'[_n+1])/2 if year==2013 & `v'==.
    }

order year provcode urban, first
sort provcode code17 year 
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-ALL.dta", replace

    /* MERGE EVERYTHING */
    
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-ALL.dta", clear
append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-ALL.dta"
drop if provcode==.

foreach v of varlist p_g_jan-p_g_avg {
	replace `v'=. if `v'==0
	}
fillin year provcode urban code17
sort code17 provcode urban year
drop _fillin

* cleaning 
* check unbalanced commodities 
preserve
    collapse (count) p_g_avg, by(urban code17 year)
    replace p_g_avg=. if p_g_avg==0
    table (code17) (urban year), stat(mean p_g_avg) nototals
    keep code17 p_g_avg year urban 
	gen yurb = year*10 + urban
	drop year urban	
    reshape wide p_g_avg, i(code17) j(yurb)
    egen exclude = rowmiss(p_g_avg*)
    gen include =1 if exclude==0
    keep code17 include
    save "${gdTemp}/inclusion-item-temporal.dta", replace
restore 

save "${gdOutput}/price-data-temp-2010-2022.dta",replace