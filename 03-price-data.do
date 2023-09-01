
    * -------------------------------------------------------------------- *
    * Setup price data from price survey to HH
    * -------------------------------------------------------------------- *
    
clear all
set more off

/*** identifier to sum value in hh based on ***/
    
    use "${gdCrsw}/ihk19-code18.dta", clear
    drop if code18==.
    
    g code_2 = code18
    bys ihkcat19: replace code_2 = code18[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code18 code_2
        duplicates drop 
        save "${gdTemp}/00-code-ihk-adjust-2018.dta", replace
    restore
        
    replace code18 = code_2
    duplicates drop ihkcat19 code18, force
    drop code_2 
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "${gdPric}/00-shk-price-2019.dta", clear
        keep prov city ihkcode19 category ihkcat19 itemname avg 
        destring avg, replace force
    
    * geometric mean province
        g lnavg = ln(avg)
        g unit = 1
        replace unit = . if missing(lnavg)
        collapse (sum) lnavg unit, by(prov ihkcode19 category ihkcat19 itemname)
        g p_prov = exp(lnavg/unit)
        drop unit
    
    * geometric mean commodities 
        merge m:1 ihkcat19 using `crwunique', keepusing(commodity code18 name18)
        drop if _merge!=3
        drop _merge
        
        g lnpprov = ln(p_prov)
        g unit = 1 
        replace unit = . if missing(lnpprov)
        collapse (sum) lnpprov unit, by(prov code18 name18)
        g p_ps = exp(lnpprov/unit)
        drop unit lnpprov
    
    rename prov provcode
    rename code18 kode
    rename name18 name 
    
    compress
    save "${gdTemp}/shk-price-prov-bpscode-2019.dta", replace
    
    