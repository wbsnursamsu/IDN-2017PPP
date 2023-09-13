	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*
clear all
set trace off

forval t=2019/2021 {
    log using "${gdLog}/spatial-paasche-`t'.dta", replace
	use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
    
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
        duplicates drop urut kode, force 
        tostring kode, replace
        
    /* rent price */
    merge 1:1 urut kode using "${gdTemp}/rent-predict-`t'-2.dta", nogen keepusing(rent prent hstat)
    destring kode, replace
    
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
            
    * ------------------------------------------------------------------- *
    
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
//    g p_ps = p_ps               // price from price survey
    
	unique hhid 				

		g code = kode
		 
	* some screening about duration and food items consumed !!!!!!!	
		clonevar  qpurch = q     // quantity of purchase
		clonevar  epurch = v     // expenditure of purchase

		// purchased food table
		g purch =(v > 0 & v !=.) 
		keep if purch == 1
		//unit values for purchased food (hh level)		
		g uv_hh = epurch/qpurch 

    save "${gdTemp}/temp-susenas-`t'.dta", replace

    * ------------------------------------------------------------------- *
//   
//     **# /* FOOD ONLY */
//    
//         use "${gdTemp}/temp-susenas-`t'.dta", clear
//         drop if inlist(ditem_all,"rent")                                        // wr - use to exclude rent price in the deflator
//         keep if inlist(ditem_all,"food","processed","tobacco")                  // fo - use to only include implicit price from hh survey
//		
//         fillin code urban prov rege
// 		drop _fillin
//		
// 		*** unit values by levels
//         // calculate weighted median
//         preserve
//             collapse (median) uv_1=uv_hh [w=popw], by(code urban prov rege)     // regency
//             tempfile uv1
//             save `uv1', replace
//         restore, preserve
//             collapse (median) uv_2=uv_hh [w=popw], by(code urban prov)          // strata
//             tempfile uv2
//             save `uv2', replace
//         restore, preserve
//             collapse (median) uv_3=uv_hh [w=popw], by(code prov)                // province
//             tempfile uv3
//             save `uv3', replace
//         restore, preserve
//             collapse (median) uv_4=uv_hh [w=popw], by(code urban)               // urban rural
//             tempfile uv4
//             save `uv4', replace
//         restore, preserve
//             collapse (median) uv_5=uv_hh [w=popw], by(code)                     // national - REFERENCE
//             tempfile uv5
//             save `uv5', replace
//         restore
//        
//         merge m:1 code urban prov rege using `uv1', nogen
//         merge m:1 code urban prov using `uv2', nogen
//         merge m:1 code prov using `uv3', nogen
//         merge m:1 code urban using `uv4', nogen
//         merge m:1 code using `uv5', nogen
//                
//         /* THIS IS USING WEIGHTED MEAN
// 		egen uv_1 = wtmean(uv_hh) , weight(popw) by (code urban prov rege)      // regency
// 		egen uv_2 = wtmean(uv_hh) , weight(popw) by (code urban prov)           // strata  
// 		egen uv_3 = wtmean(uv_hh), weight(popw) by (code prov) 	                // province
// 		egen uv_4 = wtmean(uv_hh), weight(popw) by (code urban)                 // urban rural
// 		egen uv_5 = wtmean(uv_hh), weight(popw) by (code)                       // national - REFERENCE
// 		*/
//        
//         // replace if missing UVs to higher stratification
//         forval j=2/5 {
//             replace uv_1 = uv_`j' if uv_1==.
//             }
//         forval j=1/5 {
//             replace uv_hh = uv_`j' if uv_hh==.
//             }
//        
// 		// keeping only purchased food items at municipality, strata and national level 
// 		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
//		
// 		/* drop if  less than 5 items purchased, by municipality)*/
// 		egen fr = count(_n), by(code urban prov rege) 
// 		drop if fr<5 | fr==.		
// 		/* replacing  the outlier unit values - 5 times > or < than national unit value */
// 		replace uv_1 = uv_5  if (uv_1 > 5*uv_5 | uv_1 <uv_5/5)  
//        
//         /* weights by household */
//         bys hhid: egen t_v = total(v)
//         gen sh_v = v/t_v
//        
//         /* paache deflator household level */
//         gen sh_uv1  = (uv_5/uv_1)*sh_v            // based on regency UV
//         gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
//        
// 		collapse (sum) sh_uv1 sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
//        
//         gen pdef_re = 1/sh_uv1
//         gen pdef_hh = 1/sh_uvhh
//        
//         la var pdef_re "Paasche spatial index HH level with regency UV"
//         la var pdef_hh "Paasche spatial index HH level with HH UV"
//        
//         /* stratum (province urban) */
//         preserve
//             collapse (median) pdef_re pdef_hh [weight = popw] , by(prov urban) 
//             replace pdef_re=1 if pdef_re==.
//             replace pdef_hh=1 if pdef_hh==.
//             la var pdef_re "Paasche spatial stratum level with regency UV"
//             la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//             compress
//             save "${gdOutput}/paache-deflator-str-`t'-fo.dta", replace
//         restore
//
//         /* municipal */    
//         collapse (median) pdef_re pdef_hh [weight = popw] , by(prov rege urban) 
//         replace pdef_re=1 if pdef_re==.
//         replace pdef_hh=1 if pdef_hh==.
//         la var pdef_re "Paasche spatial stratum level with regency UV"
//         la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//         compress
//         save "${gdOutput}/paache-deflator-reg-`t'-fo.dta", replace
//        
//       
//     * ------------------------------------------------------------------- *
//
//     **# /* PRICE SURVEY ONLY */
//    
//         use "${gdTemp}/temp-susenas-`t'.dta", clear
//         drop if inlist(ditem_all,"rent")                                        // wr - use to exclude rent price in the deflator
//         replace uv_hh = p_ps if !inlist(ditem_all,"energy","fuel")              // ps - change for all except fuel energy
//		
//         fillin code urban prov rege
// 		drop _fillin
//		
// 		*** unit values by levels
//         // calculate weighted median
//         preserve
//             collapse (median) uv_1=uv_hh [w=popw], by(code urban prov rege)     // regency
//             tempfile uv1
//             save `uv1', replace
//         restore, preserve
//             collapse (median) uv_2=uv_hh [w=popw], by(code urban prov)          // strata
//             tempfile uv2
//             save `uv2', replace
//         restore, preserve
//             collapse (median) uv_3=uv_hh [w=popw], by(code prov)                // province
//             tempfile uv3
//             save `uv3', replace
//         restore, preserve
//             collapse (median) uv_4=uv_hh [w=popw], by(code urban)               // urban rural
//             tempfile uv4
//             save `uv4', replace
//         restore, preserve
//             collapse (median) uv_5=uv_hh [w=popw], by(code)                     // national - REFERENCE
//             tempfile uv5
//             save `uv5', replace
//         restore
//        
//         merge m:1 code urban prov rege using `uv1', nogen
//         merge m:1 code urban prov using `uv2', nogen
//         merge m:1 code prov using `uv3', nogen
//         merge m:1 code urban using `uv4', nogen
//         merge m:1 code using `uv5', nogen
//                
//         /* THIS IS USING WEIGHTED MEAN
// 		egen uv_1 = wtmean(uv_hh) , weight(popw) by (code urban prov rege)      // regency
// 		egen uv_2 = wtmean(uv_hh) , weight(popw) by (code urban prov)           // strata  
// 		egen uv_3 = wtmean(uv_hh), weight(popw) by (code prov) 	                // province
// 		egen uv_4 = wtmean(uv_hh), weight(popw) by (code urban)                 // urban rural
// 		egen uv_5 = wtmean(uv_hh), weight(popw) by (code)                       // national - REFERENCE
// 		*/
//        
//         // replace if missing UVs to higher stratification
//         forval j=2/5 {
//             replace uv_1 = uv_`j' if uv_1==.
//             }
//         forval j=1/5 {
//             replace uv_hh = uv_`j' if uv_hh==.
//             }
//        
// 		// keeping only purchased food items at municipality, strata and national level 
// 		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
//		
// 		/* drop if  less than 5 items purchased, by municipality)*/
// 		egen fr = count(_n), by(code urban prov rege) 
// 		drop if fr<5 | fr==.		
// 		/* replacing  the outlier unit values - 5 times > or < than national unit value */
// 		replace uv_1 = uv_5  if (uv_1 > 5*uv_5 | uv_1 <uv_5/5)  
//        
//         /* weights by household */
//         bys hhid: egen t_v = total(v)
//         gen sh_v = v/t_v
//        
//         /* paache deflator household level */
//         gen sh_uv1  = (uv_5/uv_1)*sh_v            // based on regency UV
//         gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
//        
// 		collapse (sum) sh_uv1 sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
//        
//         gen pdef_re = 1/sh_uv1
//         gen pdef_hh = 1/sh_uvhh
//        
//         la var pdef_re "Paasche spatial index HH level with regency UV"
//         la var pdef_hh "Paasche spatial index HH level with HH UV"
//        
//         /* stratum (province urban) */
//         preserve
//             collapse (median) pdef_re pdef_hh [weight = popw] , by(prov urban) 
//             replace pdef_re=1 if pdef_re==.
//             replace pdef_hh=1 if pdef_hh==.
//             la var pdef_re "Paasche spatial stratum level with regency UV"
//             la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//             compress
//             save "${gdOutput}/paache-deflator-str-`t'-ps.dta", replace
//         restore
//
//         /* municipal */    
//         collapse (median) pdef_re pdef_hh [weight = popw] , by(prov rege urban) 
//         replace pdef_re=1 if pdef_re==.
//         replace pdef_hh=1 if pdef_hh==.
//         la var pdef_re "Paasche spatial stratum level with regency UV"
//         la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//         compress
//         save "${gdOutput}/paache-deflator-reg-`t'-ps.dta", replace
//        
//       
//     * ------------------------------------------------------------------- *
//
//     **# /* MIX HH IMPLICIT PRICE AND PRICE SURVEY */
//    
//         use "${gdTemp}/temp-susenas-`t'.dta", clear
//         drop if inlist(ditem_all,"rent")                                                           // wr - use to exclude rent price in the deflator
//         replace uv_hh = p_ps if !inlist(ditem_all,"food","processed","tobacco","energy","fuel")    // mx - change only nonfood
//		
//         fillin code urban prov rege
// 		drop _fillin
//		
// 		*** unit values by levels
//         // calculate weighted median
//         preserve
//             collapse (median) uv_1=uv_hh [w=popw], by(code urban prov rege)     // regency
//             tempfile uv1
//             save `uv1', replace
//         restore, preserve
//             collapse (median) uv_2=uv_hh [w=popw], by(code urban prov)          // strata
//             tempfile uv2
//             save `uv2', replace
//         restore, preserve
//             collapse (median) uv_3=uv_hh [w=popw], by(code prov)                // province
//             tempfile uv3
//             save `uv3', replace
//         restore, preserve
//             collapse (median) uv_4=uv_hh [w=popw], by(code urban)               // urban rural
//             tempfile uv4
//             save `uv4', replace
//         restore, preserve
//             collapse (median) uv_5=uv_hh [w=popw], by(code)                     // national - REFERENCE
//             tempfile uv5
//             save `uv5', replace
//         restore
//        
//         merge m:1 code urban prov rege using `uv1', nogen
//         merge m:1 code urban prov using `uv2', nogen
//         merge m:1 code prov using `uv3', nogen
//         merge m:1 code urban using `uv4', nogen
//         merge m:1 code using `uv5', nogen
//                
//         /* THIS IS USING WEIGHTED MEAN
// 		egen uv_1 = wtmean(uv_hh) , weight(popw) by (code urban prov rege)      // regency
// 		egen uv_2 = wtmean(uv_hh) , weight(popw) by (code urban prov)           // strata  
// 		egen uv_3 = wtmean(uv_hh), weight(popw) by (code prov) 	                // province
// 		egen uv_4 = wtmean(uv_hh), weight(popw) by (code urban)                 // urban rural
// 		egen uv_5 = wtmean(uv_hh), weight(popw) by (code)                       // national - REFERENCE
// 		*/
//        
//         // replace if missing UVs to higher stratification
//         forval j=2/5 {
//             replace uv_1 = uv_`j' if uv_1==.
//             }
//         forval j=1/5 {
//             replace uv_hh = uv_`j' if uv_hh==.
//             }
//        
// 		// keeping only purchased food items at municipality, strata and national level 
// 		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
//		
// 		/* drop if  less than 5 items purchased, by municipality)*/
// 		egen fr = count(_n), by(code urban prov rege) 
// 		drop if fr<5 | fr==.		
// 		/* replacing  the outlier unit values - 5 times > or < than national unit value */
// 		replace uv_1 = uv_5  if (uv_1 > 5*uv_5 | uv_1 <uv_5/5)  
//        
//         /* weights by household */
//         bys hhid: egen t_v = total(v)
//         gen sh_v = v/t_v
//        
//         /* paache deflator household level */
//         gen sh_uv1  = (uv_5/uv_1)*sh_v            // based on regency UV
//         gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
//        
// 		collapse (sum) sh_uv1 sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
//        
//         gen pdef_re = 1/sh_uv1
//         gen pdef_hh = 1/sh_uvhh
//        
//         la var pdef_re "Paasche spatial index HH level with regency UV"
//         la var pdef_hh "Paasche spatial index HH level with HH UV"
//        
//         /* stratum (province urban) */
//         preserve
//             collapse (median) pdef_re pdef_hh [weight = popw] , by(prov urban) 
//             replace pdef_re=1 if pdef_re==.
//             replace pdef_hh=1 if pdef_hh==.
//             la var pdef_re "Paasche spatial stratum level with regency UV"
//             la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//             compress
//             save "${gdOutput}/paache-deflator-str-`t'-mx.dta", replace
//         restore
//
//         /* municipal */    
//         collapse (median) pdef_re pdef_hh [weight = popw] , by(prov rege urban) 
//         replace pdef_re=1 if pdef_re==.
//         replace pdef_hh=1 if pdef_hh==.
//         la var pdef_re "Paasche spatial stratum level with regency UV"
//         la var pdef_hh "Paasche spatial stratum level with HH UV"
//
//         compress
//         save "${gdOutput}/paache-deflator-reg-`t'-mx.dta", replace
//        
      
    * ------------------------------------------------------------------- *
    
    **# /* MIX HH IMPLICIT PRICE AND PRICE SURVEY WITH RENT PRICE */
    
        use "${gdTemp}/temp-susenas-`t'.dta", clear
        replace uv_hh = p_ps if !inlist(ditem_all,"food","processed","tobacco","energy","fuel")    // mix - change only nonfood
		replace v = prent if prent!=. & ditem_all=="rent"
        
        fillin code urban prov rege
		drop _fillin
		
		*** unit values by levels
        // calculate weighted median
        preserve
            collapse (median) uv_1=uv_hh [w=popw], by(code urban prov rege)     // regency
            tempfile uv1
            save `uv1', replace
        restore, preserve
            collapse (median) uv_2=uv_hh [w=popw], by(code urban prov)          // strata
            tempfile uv2
            save `uv2', replace
        restore, preserve
            collapse (median) uv_3=uv_hh [w=popw], by(code prov)                // province
            tempfile uv3
            save `uv3', replace
        restore, preserve
            collapse (median) uv_4=uv_hh [w=popw], by(code urban)               // urban rural
            tempfile uv4
            save `uv4', replace
        restore, preserve
            collapse (median) uv_5=uv_hh [w=popw], by(code)                     // national - REFERENCE
            tempfile uv5
            save `uv5', replace
        restore
        
        merge m:1 code urban prov rege using `uv1', nogen
        merge m:1 code urban prov using `uv2', nogen
        merge m:1 code prov using `uv3', nogen
        merge m:1 code urban using `uv4', nogen
        merge m:1 code using `uv5', nogen
                
        /* THIS IS USING WEIGHTED MEAN
		egen uv_1 = wtmean(uv_hh), weight(popw) by (code urban prov rege)      // regency
		egen uv_2 = wtmean(uv_hh), weight(popw) by (code urban prov)           // strata  
		egen uv_3 = wtmean(uv_hh), weight(popw) by (code prov) 	                // province
		egen uv_4 = wtmean(uv_hh), weight(popw) by (code urban)                 // urban rural
		egen uv_5 = wtmean(uv_hh), weight(popw) by (code)                       // national - REFERENCE
		*/
        
        // replace if missing UVs to higher stratification
        forval j=2/5 {
            replace uv_1 = uv_`j' if uv_1==.
            }
        forval j=1/5 {
            replace uv_hh = uv_`j' if uv_hh==.
            }
        
		// keeping only purchased food items at municipality, strata and national level 
		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov rege) 
		drop if fr<5 | fr==.		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_1 = uv_5  if (uv_1 > 5*uv_5 | uv_1 <uv_5/5)  
        
        /* weights by household */
        bys hhid: egen t_v = total(v)
        gen sh_v = v/t_v
        
        /* paache deflator household level */
        gen sh_uv1  = (uv_5/uv_1)*sh_v            // based on regency UV
        gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
        
		collapse (sum) sh_uv1 sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
        
        gen pdef_re = 1/sh_uv1
        gen pdef_hh = 1/sh_uvhh
        
        la var pdef_re "Paasche spatial index HH level with regency UV"
        la var pdef_hh "Paasche spatial index HH level with HH UV"
        
        /* stratum (province urban) */
        preserve
            collapse (median) pdef_re pdef_hh [weight = popw] , by(prov urban) 
            replace pdef_re=1 if pdef_re==.
            replace pdef_hh=1 if pdef_hh==.
            la var pdef_re "Paasche spatial stratum level with regency UV"
            la var pdef_hh "Paasche spatial stratum level with HH UV"

            compress
            save "${gdOutput}/paache-deflator-str-`t'-wr.dta", replace
        restore

        /* municipal */    
        collapse (median) pdef_re pdef_hh [weight = popw] , by(prov rege urban) 
        replace pdef_re=1 if pdef_re==.
        replace pdef_hh=1 if pdef_hh==.
        la var pdef_re "Paasche spatial stratum level with regency UV"
        la var pdef_hh "Paasche spatial stratum level with HH UV"

        compress
        save "${gdOutput}/paache-deflator-reg-`t'-wr.dta", replace
        
    log close
    }