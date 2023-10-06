local t=2010

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
        duplicates drop 
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
            replace avg = avg*1000 if avg<300
            }
        
        
    * geometric mean province
    foreach v of varlist jan-avg {
            egen g_`v' = gmean(`v'), by(prov komoditas)
        }
    collapse (mean) g_*, by(prov komoditas)

    * geometric mean commodities 
        merge m:1 komoditas using `crwunique', keepusing(komoditas code_c)
        
    levelsof komoditas if _merge==2
    levelsof komoditas if _merge==1