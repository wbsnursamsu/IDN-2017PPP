	*----------------------------------------------------------------------*
	* TEMPORAL DEFLATOR  -  LASPEYRES
	*----------------------------------------------------------------------*

    /* Calculate weights */
    
* Select categories
    use "${gdCons}/sus-cm-mar-2017-full.dta", replace
    merge m:1 code17 using "${gdTemp}/inclusion-item-temporal-rural.dta", nogen
    
    drop if include==.
    drop include
    keep if urban==0
    
    *!!! Drop VEHICLE (DURABLE should be dropped too) code 342 !!!*
    drop if code17==342
    
    g hhid = urut
    g prov = provcode
    g rege= kabcode
    g popw = wert
    
* 1. population weights for province
    preserve
        duplicates drop urut, force
        gen population = 1 
        collapse (sum) population [fw=int(weind)], by(prov urban)
        rename prov provcode
        save "${gdTemp}/temp-prov-weights-2017.dta", replace
    restore
    
    save "${gdTemp}/sus-cm-for-temporal.dta", replace

* 2. Calculate weights - rural (plutocratic)    
    use "${gdTemp}/sus-cm-for-temporal.dta", clear 
    collapse (sum) v [weight = popw], by(code17 urban)
    bys urban: egen t_v = total(v)
    gen sh_ur = v/t_v
    replace sh_ur = 0 if sh_ur==.
    save "${gdTemp}/temp-weight-2017.dta", replace

    /* Calculate laspeyres */
    
* 3. price data
    use "${gdOutput}/price-data-rural-2010-2022.dta", clear
    replace p_ps=0 if p_ps==.
    merge m:1 code17 using "${gdTemp}/inclusion-item-temporal-rural.dta", nogen
    drop if include==.
    drop include
        * merge weights
        merge m:1 prov urban using "${gdTemp}/temp-prov-weights-2017.dta", nogen    
    save "${gdTemp}/price-for-temporal.dta", replace
    
    * 3a. rural price
    use "${gdTemp}/price-for-temporal.dta", clear
    preserve
        keep if year==2017
        collapse (mean) p_ps [fw=population], by(code17 urban)
        rename p_ps p0_ur
        tempfile urprice
        save `urprice', replace
    restore
    
    merge m:1 code17 urban using `urprice', keepusing(p0_ur) nogen
    merge m:1 code17 urban using "${gdTemp}/temp-weight-2017.dta", keepusing(sh_ur) nogen    
    * replace outliers (??? NEED TO CHECK ???)
    replace p_ps = p0_ur if p_ps<(p0_ur/5) | p_ps>(p0_ur*5)
    
    collapse (mean) p_ps p0_ur sh_ur [fw=population], by(year code17 urban)
    rename p_ps pt
    
    gen ldef_ur = pt/p0_ur*sh_ur
    collapse (sum) ldef, by(year)
    
    /* SAVE */
    save "${gdOutput}/temporal-deflator-rural.dta", replace
    
    