	*----------------------------------------------------------------------*
	* TEMPORAL DEFLATOR  -  LASPEYRES
	*----------------------------------------------------------------------*

    /* Calculate weights */
    
* Select categories
    use "${gdCons}/sus-cm-mar-2017-full.dta", replace
    merge m:1 code17 using "${gdTemp}/inclusion-item-temporal.dta", nogen
    drop if include==.
    drop include
    
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

* 2a. Calculate weights - urban rural (plutocratic)    
    use "${gdTemp}/sus-cm-for-temporal.dta", clear 
    collapse (sum) v [weight = popw], by(code17 urban)
    bys urban: egen t_v = total(v)
    gen sh_ur = v/t_v
    replace sh_ur = 0 if sh_ur==.
    save "${gdTemp}/temp-weight-ur-2017.dta", replace

* 2b. Calculate weights - national (plutocratic)    
    use "${gdTemp}/sus-cm-for-temporal.dta", clear 
    collapse (sum) v [weight = popw], by(code17)
    egen t_v = total(v)
    gen sh_nat = v/t_v
    replace sh_nat = 0 if sh_nat==.
    save "${gdTemp}/temp-weight-nat-2017.dta", replace
    
    /* Calculate laspeyres */
    
* 3. price data
    use "${gdOutput}/price-data-2015-2021.dta", clear
    replace p_ps=0 if p_ps==.
    merge m:1 code17 using "${gdTemp}/inclusion-item-temporal.dta", nogen
    drop if include==.
    drop include
        * merge weights
        merge m:1 prov urban using "${gdTemp}/temp-prov-weights-2017.dta", nogen    
    save "${gdTemp}/price-for-temporal.dta", replace
    
    * 3a. urban rural price
    use "${gdTemp}/price-for-temporal.dta", clear
    preserve
        keep if year==2017
        collapse (mean) p_ps [fw=population], by(code17 urban)
        rename p_ps p0_ur
        tempfile urprice
        save `urprice', replace
    restore
    
    collapse (mean) p_ps [fw=population], by(year code17 urban)
    merge m:1 code17 urban using "${gdTemp}/temp-weight-ur-2017.dta", keepusing(sh_ur) nogen    
    merge m:1 code17 urban using `urprice', keepusing(p0_ur) nogen
    rename p_ps pt
    
    gen ldef_ur = pt/p0_ur*sh_ur
    collapse (sum) ldef, by(year urban)
    
    /* SAVE */
    save "${gdOutput}/temporal-deflator-ur-2.dta", replace
    
    * 3b. urban rural price
    use "${gdTemp}/price-for-temporal.dta", clear    
    preserve
        keep if year==2017
        collapse (mean) p_ps [fw=population], by(code17)
        rename p_ps p0_nat
        tempfile natprice
        save `natprice', replace
    restore    
    
    collapse (mean) p_ps [fw=population],by(year code17)    
    merge m:1 code17 using "${gdTemp}/temp-weight-nat-2017.dta", keepusing(sh_nat) nogen
    merge m:1 code17 using `natprice', keepusing(p0_nat) nogen
    rename p_ps pt
    
    gen ldef_nat = pt/p0_nat*sh_nat
    collapse (sum) ldef, by(year)

    /* SAVE */
    save "${gdOutput}/temporal-deflator-nat-2.dta", replace
    
    