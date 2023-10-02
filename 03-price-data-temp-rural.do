
    * -------------------------------------------------------------------- *
    * Setup price data from price survey to HH
    * -------------------------------------------------------------------- *
    
clear all
set more off
set trace off


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
        duplicates drop 
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
        
        keep year komoditas prov provcode mar 
        keep if year==`t'
        destring mar, replace
    
    * geometric mean province
        g lnmar = ln(mar)
        g unitval = 1
        replace unitval = . if missing(lnmar)
        collapse (sum) lnmar unitval, by(provcode komoditas)
        g p_prov = exp(lnmar/unitval)
        drop unitval
    
    * geometric mean commodities 
        merge m:1 komoditas using `crwunique', keepusing(komoditas code17 name17)
        drop if _merge!=3
        drop _merge
        
        g lnpprov = ln(p_prov)
        g unitval = 1 
        replace unitval = . if missing(lnpprov)
        collapse (sum) lnpprov unitval, by(provcode code17 name17)
        g p_ps = exp(lnpprov/unitval)
        drop unitval lnpprov

    su p_ps
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
replace p_ps = . if year==2013    
fillin year provcode code17
drop _fillin
gen urban=0    
sort code17 provcode year
bys code17 provcode: replace p_ps = (p_ps[_n-1]+p_ps[_n+1])/2 if year==2013 & p_ps==.
order year provcode urban, first
sort provcode code17 year 
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-rural.dta", replace


    /* MERGE EVERYTHING */
    
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-rural.dta", clear
drop if provcode==.

* cleaning 
* check unbalanced commodities 
preserve
    collapse (count) p_ps, by(code17 year)
    replace p_ps=. if p_ps==0
    table (code17) (year), stat(mean p_ps) nototals
    keep code17 p_ps year
    reshape wide p_ps, i(code17) j(year)
    egen exclude = rowmiss(p_ps*)
    keep if exclude==0
    gen include =1
    keep code17 include
    save "${gdTemp}/inclusion-item-temporal-rural.dta", replace
restore 

save "${gdOutput}/price-data-rural-2010-2022.dta",replace
