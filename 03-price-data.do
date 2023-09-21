
    * -------------------------------------------------------------------- *
    * Setup price data from price survey to HH
    * -------------------------------------------------------------------- *
    
clear all
set more off
/* SHK */
/*** identifier to sum value in hh based on ***/

forval t=2015/2021 {
    use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-concordance-`t'.dta", clear
    replace komoditas=strltrim(komoditas)
    replace komoditas=stritrim(komoditas)
    replace komoditas=strrtrim(komoditas)
    replace komoditas=strtrim(komoditas)
    replace unit=strltrim(unit)
    replace unit=stritrim(unit)
    replace unit=strrtrim(unit)
    replace unit=strtrim(unit)  
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas unit: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop 
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    duplicates drop komoditas unit, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata/shk-price-2010-2022.dta", clear
        replace komoditas=strltrim(komoditas)
        replace komoditas=stritrim(komoditas)
        replace komoditas=strrtrim(komoditas)
        replace komoditas=strtrim(komoditas)
        replace unit=strltrim(unit)
        replace unit=stritrim(unit)
        replace unit=strrtrim(unit)
        replace unit=strtrim(unit)           
        keep year komoditas unit prov city avg 
        keep if year==`t'
        destring avg, replace force
        replace avg = avg*1000 if avg<300
        
    * geometric mean province
        g lnavg = ln(avg)
        g unitval = 1
        replace unitval = . if missing(lnavg)
        collapse (sum) lnavg unitval, by(prov komoditas unit)
        g p_prov = exp(lnavg/unitval)
        drop unitval
    
    * geometric mean commodities 
        merge m:1 komoditas unit using `crwunique', keepusing(komoditas unit code_c name_c)
        drop if _merge!=3
        drop _merge
        
        g lnpprov = ln(p_prov)
        g unitval = 1 
        replace unitval = . if missing(lnpprov)
        collapse (sum) lnpprov unitval, by(prov code_c name_c)
        g p_ps = exp(lnpprov/unitval)
        drop unitval lnpprov
    
    rename prov provcode
    rename code_c kode
    rename name_c name 
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-`t'.dta", replace
}    

/* merge SHK for spatial deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-2015.dta", clear
gen year=2015
forval t=2016/2021 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
fillin year provcode code17
drop _fillin
gen urban=1  
sort code17 provcode year
bys code17 provcode: replace p_ps = p_ps[_n+1] if year==2015 & p_ps==.
bys code17 provcode: replace p_ps = (p_ps[_n-1]+p_ps[_n+1])/2 if year==2017 & p_ps==.
bys code17 provcode: replace p_ps = (p_ps[_n-1]+p_ps[_n+1])/2 if year==2018 & p_ps==.
order year provcode urban, first
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-price-prov-bpscode-ALL.dta", replace

/* SHKP */
/*** identifier to sum value in hh based on ***/

forval t=2015/2021 {
    use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", clear
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas unit: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop 
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    duplicates drop komoditas unit, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\stata/shkp-price-2010-2021.dta", clear
        keep year komoditas unit prov provcode avg 
        keep if year==`t'
        destring avg, replace force
    
    * geometric mean province
        g lnavg = ln(avg)
        g unitval = 1
        replace unitval = . if missing(lnavg)
        collapse (sum) lnavg unitval, by(provcode komoditas unit)
        g p_prov = exp(lnavg/unitval)
        drop unitval
    
    * geometric mean commodities 
        merge m:1 komoditas unit using `crwunique', keepusing(komoditas unit code_c name_c)
        drop if _merge!=3
        drop _merge
        
        g lnpprov = ln(p_prov)
        g unitval = 1 
        replace unitval = . if missing(lnpprov)
        collapse (sum) lnpprov unitval, by(provcode code_c name_c)
        g p_ps = exp(lnpprov/unitval)
        drop unitval lnpprov
    
    rename code_c kode
    rename name_c name 
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-price-prov-bpscode-`t'.dta", replace
}        
