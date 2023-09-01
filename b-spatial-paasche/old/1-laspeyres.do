	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR  -  LASPEYRES
	*----------------------------------------------------------------------*
clear all
set maxvar 12000

forval t = 2019/2019 {
	use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
    
    /* rent price */
    * monthly rent
        g rent = v if ditem_all=="rent"
    
    * housing ownership status
        g hstat = 1 if inlist(q,1,4) 
            replace hstat = 2 if inlist(q,2,3)
            replace hstat = 3 if inlist(q,5,6)        
        la def hstat 1 "Own" 2 "Rent" 3 "Others"
        la val hstat hstat
        
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
    
    /* collapse to adjust with price survey and merge with price survey data */
    * set price data
        merge m:1 code18 using "${gdTemp}/00-code-ihk-adjust-2018.dta", nogen
        drop kode
        drop if urut == ""

    g kode = code18
        replace kode = code_2 if !missing(code_2)
        
    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut provcode kabcode urban kode name ditem_all)
        merge m:1 provcode kode using "${gdTemp}/shk-price-prov-bpscode-2019.dta", keepusing(p_ps) nogen 
    
    * ------------------------------------------------------------------- *

    g hhid = urut
    g prov = provcode
    g muni = kabcode
    g popw = wert
//     g p_ps = p_ps               // price from price survey
    
	unique hhid 				

		g code = kode
            
	* some screening about duration and food items consumed !!!!!!!
		clonevar  qpurch = q    // quantity of purchase
		clonevar  epurch = v    // expenditure of purchase

		// purchased food table
		g purch =(v > 0 & v !=.) 
		keep if purch == 1
		// unit values for purchased food (hh level)		
		g uv_hh = epurch/qpurch 
    
    tempfile tempdat
    save `tempdat', replace

    
    * ------------------------------------------------------------------- *
    
    **# /* FOOD ONLY */
        use `tempdat', clear
        drop if inlist(ditem_all,"rent")                                                           // wrent - use to exclude rent price in the deflator
        keep if inlist(ditem_all,"food","processed","tobacco")                                    // fo - use to only include implicit price from hh survey
        
		fillin code urban prov muni
		drop _fillin
		
		*** unit values by levels  
        // municipality UVs 
		egen uv_mun = wtmean(uv_hh) , weight(popw) by (code urban prov muni)  
			replace uv_hh = uv_mun if uv_hh == .         
		// strata UVs
		egen uv_str = wtmean(uv_hh) , weight(popw) by (code urban prov)  
			replace uv_hh = uv_str if uv_hh == . 
		// province 	
		egen uv_reg = wtmean(uv_hh), weight(popw) by (code prov) 	
			replace uv_hh = uv_reg if uv_hh == . 
		// urban/rural 	
		egen uv_urb = wtmean(uv_hh), weight(popw) by (code urban)  
			replace uv_hh = uv_urb if uv_hh == . 
		// reference price or national /* national unit values*/
		egen uv_nat = wtmean(uv_hh), weight(popw) by (code)  
		
		// keeping only purchased food items at strata and national level 
		keep if uv_mun != . & uv_str != . & uv_nat != . 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov muni) 
		drop if fr<5		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_str = uv_nat  if (uv_str > 5*uv_nat | uv_str <uv_nat/5)  

        /* laspeyres - national urb rur weight (plutocratic) */
        preserve
            collapse (sum) v [weight = popw], by(code urban)
            bys urban: egen t_v = total(v)
            gen sh_nat = v/t_v
            replace sh_nat = 0 if sh_nat==.
            tempfile wght
            save `wght', replace
        restore

        collapse (mean) uv_nat uv_str uv_mun popw [weight = popw], by(urban code prov muni)
        merge m:1 code urban using `wght', keepusing(sh_nat) nogen

        /* laspeyres deflator stratum (province urban) and municipality level */ 
        gen lasp_def_str = (uv_str/uv_nat)*sh_nat
        gen lasp_def_mun = (uv_mun/uv_nat)*sh_nat        

		/* save if needed */ 
        compress
        save "${gdTemp}/spatial-laspeyres-`t'-fo.dta", replace
        
    /* stratum */
    preserve
        duplicates drop urban prov code, force
        collapse (sum) lasp_def_str [weight = popw], by(urban prov)
        replace lasp_def_str=1 if lasp_def_str ==.
        la var lasp_def_str "Laspeyres spatial index stratum level"

        table prov urban , stat(mean lasp_def_str)            
        sort prov urban
       
        compress
        save "${gdOutput}/laspeyres-deflator-str-`t'-fo.dta", replace
    restore
    
    /* municipal */ 
    collapse (sum) lasp_def_str lasp_def_mun [weight = popw], by(urban prov muni)
    replace lasp_def_mun=1 if lasp_def_mun ==.
    la var lasp_def_mun "Laspeyres spatial index municipal level"

    gen provmuni = prov*100+muni
    table provmuni urban , stat(mean lasp_def_mun)            
    sort provmuni urban 

    compress
	save "${gdOutput}/laspeyres-deflator-mun-`t'-fo.dta", replace   
    
    
    * ------------------------------------------------------------------- *
    
    **# /* PRICE SURVEY ONLY */
        use `tempdat', clear
        drop if inlist(ditem_all,"rent")                                                           // wrent - use to exclude rent price in the deflator
        replace uv_hh = p_ps if !inlist(ditem_all,"energy","fuel")                                // ps - change for all except fuel energy
        
		fillin code urban prov muni
		drop _fillin
		
		*** unit values by levels  
        // municipality UVs 
		egen uv_mun = wtmean(uv_hh) , weight(popw) by (code urban prov muni)  
			replace uv_hh = uv_mun if uv_hh == .         
		// strata UVs
		egen uv_str = wtmean(uv_hh) , weight(popw) by (code urban prov)  
			replace uv_hh = uv_str if uv_hh == . 
		// province 	
		egen uv_reg = wtmean(uv_hh), weight(popw) by (code prov) 	
			replace uv_hh = uv_reg if uv_hh == . 
		// urban/rural 	
		egen uv_urb = wtmean(uv_hh), weight(popw) by (code urban)  
			replace uv_hh = uv_urb if uv_hh == . 
		// reference price or national /* national unit values*/
		egen uv_nat = wtmean(uv_hh), weight(popw) by (code)  
		
		// keeping only purchased food items at strata and national level 
		keep if uv_mun != . & uv_str != . & uv_nat != . 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov muni) 
		drop if fr<5		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_str = uv_nat  if (uv_str > 5*uv_nat | uv_str <uv_nat/5)  

        /* laspeyres - national urb rur weight (plutocratic) */
        preserve
            collapse (sum) v [weight = popw], by(code urban)
            bys urban: egen t_v = total(v)
            gen sh_nat = v/t_v
            replace sh_nat = 0 if sh_nat==.
            tempfile wght
            save `wght', replace
        restore

        collapse (mean) uv_nat uv_str uv_mun popw [weight = popw], by(urban code prov muni)
        merge m:1 code urban using `wght', keepusing(sh_nat) nogen

        /* laspeyres deflator stratum (province urban) and municipality level */ 
        gen lasp_def_str = (uv_str/uv_nat)*sh_nat
        gen lasp_def_mun = (uv_mun/uv_nat)*sh_nat        

		/* save if needed */ 
        compress
        save "${gdTemp}/spatial-laspeyres-`t'-ps.dta", replace
        
    /* stratum */
    preserve
        duplicates drop urban prov code, force
        collapse (sum) lasp_def_str [weight = popw], by(urban prov)
        replace lasp_def_str=1 if lasp_def_str ==.
        la var lasp_def_str "Laspeyres spatial index stratum level"

        table prov urban , stat(mean lasp_def_str)            
        sort prov urban
       
        compress
        save "${gdOutput}/laspeyres-deflator-str-`t'-ps.dta", replace
    restore
    
    /* municipal */ 
    collapse (sum) lasp_def_str lasp_def_mun [weight = popw], by(urban prov muni)
    replace lasp_def_mun=1 if lasp_def_mun ==.
    la var lasp_def_mun "Laspeyres spatial index municipal level"

    gen provmuni = prov*100+muni
    table provmuni urban , stat(mean lasp_def_mun)            
    sort provmuni urban 

    compress
	save "${gdOutput}/laspeyres-deflator-mun-`t'-ps.dta", replace     
    
            
    * ------------------------------------------------------------------- *
    
    **# /* MIX HH IMPLICIT PRICE AND PRICE SURVEY */
        use `tempdat', clear
        drop if inlist(ditem_all,"rent")                                                           // wrent - use to exclude rent price in the deflator
        replace uv_hh = p_ps if !inlist(ditem_all,"energy","fuel")                                // ps - change for all except fuel energy
        
		fillin code urban prov muni
		drop _fillin
		
		*** unit values by levels  
        // municipality UVs 
		egen uv_mun = wtmean(uv_hh) , weight(popw) by (code urban prov muni)  
			replace uv_hh = uv_mun if uv_hh == .         
		// strata UVs
		egen uv_str = wtmean(uv_hh) , weight(popw) by (code urban prov)  
			replace uv_hh = uv_str if uv_hh == . 
		// province 	
		egen uv_reg = wtmean(uv_hh), weight(popw) by (code prov) 	
			replace uv_hh = uv_reg if uv_hh == . 
		// urban/rural 	
		egen uv_urb = wtmean(uv_hh), weight(popw) by (code urban)  
			replace uv_hh = uv_urb if uv_hh == . 
		// reference price or national /* national unit values*/
		egen uv_nat = wtmean(uv_hh), weight(popw) by (code)  
		
		// keeping only purchased food items at strata and national level 
		keep if uv_mun != . & uv_str != . & uv_nat != . 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov muni) 
		drop if fr<5		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_str = uv_nat  if (uv_str > 5*uv_nat | uv_str <uv_nat/5)  

        /* laspeyres - national urb rur weight (plutocratic) */
        preserve
            collapse (sum) v [weight = popw], by(code urban)
            bys urban: egen t_v = total(v)
            gen sh_nat = v/t_v
            replace sh_nat = 0 if sh_nat==.
            tempfile wght
            save `wght', replace
        restore

        collapse (mean) uv_nat uv_str uv_mun popw [weight = popw], by(urban code prov muni)
        merge m:1 code urban using `wght', keepusing(sh_nat) nogen

        /* laspeyres deflator stratum (province urban) and municipality level */ 
        gen lasp_def_str = (uv_str/uv_nat)*sh_nat
        gen lasp_def_mun = (uv_mun/uv_nat)*sh_nat        

		/* save if needed */ 
        compress
        save "${gdTemp}/spatial-laspeyres-`t'-mix.dta", replace
        
    /* stratum */
    preserve
        duplicates drop urban prov code, force
        collapse (sum) lasp_def_str [weight = popw], by(urban prov)
        replace lasp_def_str=1 if lasp_def_str ==.
        la var lasp_def_str "Laspeyres spatial index stratum level"

        table prov urban , stat(mean lasp_def_str)            
        sort prov urban
       
        compress
        save "${gdOutput}/laspeyres-deflator-str-`t'-mix.dta", replace
    restore
    
    /* municipal */ 
    collapse (sum) lasp_def_str lasp_def_mun [weight = popw], by(urban prov muni)
    replace lasp_def_mun=1 if lasp_def_mun ==.
    la var lasp_def_mun "Laspeyres spatial index municipal level"

    gen provmuni = prov*100+muni
    table provmuni urban , stat(mean lasp_def_mun)            
    sort provmuni urban 

    compress
	save "${gdOutput}/laspeyres-deflator-mun-`t'-mix.dta", replace     
    
    
    * ------------------------------------------------------------------- *
    
    **# /* MIX HH IMPLICIT PRICE AND PRICE SURVEY WITH RENT PRICE */
        use `tempdat', clear
        replace uv_hh = p_ps if !inlist(ditem_all,"food","processed","tobacco","energy","fuel")    // mix - change only nonfood
        
		fillin code urban prov muni
		drop _fillin
		
		*** unit values by levels  
        // municipality UVs 
		egen uv_mun = wtmean(uv_hh) , weight(popw) by (code urban prov muni)  
			replace uv_hh = uv_mun if uv_hh == .         
		// strata UVs
		egen uv_str = wtmean(uv_hh) , weight(popw) by (code urban prov)  
			replace uv_hh = uv_str if uv_hh == . 
		// province 	
		egen uv_reg = wtmean(uv_hh), weight(popw) by (code prov) 	
			replace uv_hh = uv_reg if uv_hh == . 
		// urban/rural 	
		egen uv_urb = wtmean(uv_hh), weight(popw) by (code urban)  
			replace uv_hh = uv_urb if uv_hh == . 
		// reference price or national /* national unit values*/
		egen uv_nat = wtmean(uv_hh), weight(popw) by (code)  
		
		// keeping only purchased food items at strata and national level 
		keep if uv_mun != . & uv_str != . & uv_nat != . 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov muni) 
		drop if fr<5		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_str = uv_nat  if (uv_str > 5*uv_nat | uv_str <uv_nat/5)  

        /* laspeyres - national urb rur weight (plutocratic) */
        preserve
            collapse (sum) v [weight = popw], by(code urban)
            bys urban: egen t_v = total(v)
            gen sh_nat = v/t_v
            replace sh_nat = 0 if sh_nat==.
            tempfile wght
            save `wght', replace
        restore

        collapse (mean) uv_nat uv_str uv_mun popw [weight = popw], by(urban code prov muni)
        merge m:1 code urban using `wght', keepusing(sh_nat) nogen

        /* laspeyres deflator stratum (province urban) and municipality level */ 
        gen lasp_def_str = (uv_str/uv_nat)*sh_nat
        gen lasp_def_mun = (uv_mun/uv_nat)*sh_nat        

		/* save if needed */ 
        compress
        save "${gdTemp}/spatial-laspeyres-`t'-wrent.dta", replace
        
    /* stratum */
    preserve
        duplicates drop urban prov code, force
        collapse (sum) lasp_def_str [weight = popw], by(urban prov)
        replace lasp_def_str=1 if lasp_def_str ==.
        la var lasp_def_str "Laspeyres spatial index stratum level"

        table prov urban , stat(mean lasp_def_str)            
        sort prov urban
       
        compress
        save "${gdOutput}/laspeyres-deflator-str-`t'-wrent.dta", replace
    restore
    
    /* municipal */ 
    collapse (sum) lasp_def_str lasp_def_mun [weight = popw], by(urban prov muni)
    replace lasp_def_mun=1 if lasp_def_mun ==.
    la var lasp_def_mun "Laspeyres spatial index municipal level"

    gen provmuni = prov*100+muni
    table provmuni urban , stat(mean lasp_def_mun)            
    sort provmuni urban 

    compress
	save "${gdOutput}/laspeyres-deflator-mun-`t'-wrent.dta", replace     
        
}