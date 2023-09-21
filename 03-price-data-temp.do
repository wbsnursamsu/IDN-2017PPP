
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
    
    drop if code17==.
    
    g code_2 = code17
    bys komoditas unit: replace code_2 = code17[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code17 code_2
        duplicates drop 
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shk-temp-adjust-`t'.dta", replace
    restore
        
    replace code17 = code_2
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
        merge m:1 komoditas unit using `crwunique', keepusing(komoditas unit code17 name17)
        drop if _merge!=3
        drop _merge
        
        g lnpprov = ln(p_prov)
        g unitval = 1 
        replace unitval = . if missing(lnpprov)
        collapse (sum) lnpprov unitval, by(prov code17 name17)
        g p_ps = exp(lnpprov/unitval)
        drop unitval lnpprov
    
    rename prov provcode 
    
    su p_ps
    
    compress
    save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-`t'.dta", replace
}    

/* merge SHK for temporal deflator */
clear
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-2015.dta", clear
gen year=2015
forval t=2016/2021 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-`t'.dta"
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
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-ALL.dta", replace


    /* SHKP */
    
/*** identifier to sum value in hh based on ***/
forval t=2015/2021 {
    use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-concordance-`t'.dta", clear
    replace komoditas=strltrim(komoditas)
    replace komoditas=stritrim(komoditas)
    replace komoditas=strrtrim(komoditas)
    replace komoditas=strtrim(komoditas)
    replace unit=strltrim(unit)
    replace unit=stritrim(unit)
    replace unit=strrtrim(unit)
    replace unit=strtrim(unit)    
    
    drop if code17==.
    
    g code_2 = code17
    bys komoditas unit: replace code_2 = code17[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code17 code_2
        duplicates drop 
        save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other\shkp-adjust-`t'.dta", replace
    restore
        
    replace code17 = code_2
    duplicates drop komoditas unit, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\stata/shkp-price-2010-2021.dta", clear
        * should do this when converting excel
        replace komoditas=strltrim(komoditas)
        replace komoditas=stritrim(komoditas)
        replace komoditas=strrtrim(komoditas)
        replace komoditas=strtrim(komoditas)
        replace unit=strltrim(unit)
        replace unit=stritrim(unit)
        replace unit=strrtrim(unit)
        replace unit=strtrim(unit)   
        keep year komoditas unit prov provcode avg 
        keep if year==`t'
        destring avg, replace force
        replace avg = avg*1000 if avg<100    
    
    * geometric mean province
        g lnavg = ln(avg)
        g unitval = 1
        replace unitval = . if missing(lnavg)
        collapse (sum) lnavg unitval, by(provcode komoditas unit)
        g p_prov = exp(lnavg/unitval)
        drop unitval
    
    * geometric mean commodities 
        merge m:1 komoditas unit using `crwunique', keepusing(komoditas unit code17 name17)
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
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-2015.dta", clear
gen year=2015
forval t=2016/2021 {
    append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-`t'.dta"
    replace year=`t' if year==.
    }
fillin year provcode code17
drop _fillin
gen urban=0    
order year provcode urban, first
sort year provcode urban
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-ALL.dta", replace


    /* MERGE EVERYTHING */
    
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shk-temp-price-prov-bpscode-ALL.dta", clear
append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Other/shkp-temp-price-prov-bpscode-ALL.dta"
drop if provcode==.

* cleaning 
* check unbalanced commodities 
preserve
    collapse (count) p_ps, by(urban code17 year)
    replace p_ps=. if p_ps==0
    table (code17) (urban year), stat(mean p_ps) nototals
    tostring year urban, replace
    gen yearurb = year+urban
    destring yearurb, replace
    keep code17 p_ps yearurb
    reshape wide p_ps, i(code17) j(yearurb)
    egen exclude = rowmiss(p_ps*)
    keep if exclude==0
    gen include =1
    keep code17 include
    save "${gdTemp}/inclusion-item-temporal.dta", replace
restore 

save "${gdOutput}/price-data-2015-2021.dta",replace