	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR 
	*----------------------------------------------------------------------*
set trace on
foreach t in 22 {
	use "${gdOutput}/SUS_Mod`t'.dta", clear
    keep if inlist(item,"food")
    
    * weights
    preserve 
        keep urut wert
        duplicates drop urut, force
        tempfile weights
        save `weights', replace
    restore
    
    g hhid = urut
    g region = provcode
    g popw = wert
    
	unique hhid 				

		g code = kode
		g int unit = 1  
		 
	* some screening about duration and food items consumed !!!!!!!
// 		bys hhid (code): egen n_food_consumed = sum(food_consumed)
	
// 		clonevar  qcons = food_cons_amt  // quantity of consumed 
		clonevar  qpurch = q     // quantity of purchase
		clonevar  epurch =   v  // expenditure of purchase

		// purchased food table
		g purch =(v > 0 & v !=.) 
		keep if purch == 1
		//unit values for purchased food (hh level)		
		g uv_hh = epurch/qpurch 

		*winsor2 uv_hh, cuts(5 95) replace //winsorizing 

		fillin code unit urban region
		drop _fillin 
		
		*** unit values by levels  
		// strata UVs /* strata unit values*/	
		egen uv_str = wtmean(uv_hh) , weight(popw) by (code unit urban region)  
			replace uv_hh = uv_str if uv_hh == . 
		// regional 	
		egen uv_reg = wtmean(uv_hh), weight(popw) by (code unit region) 	
			replace uv_hh = uv_reg if uv_hh == . 
		// urban/rural 	
		egen uv_urb = wtmean(uv_hh), weight(popw) by (code unit urban)  
			replace uv_hh = uv_urb if uv_hh == . 
		// reference price or national /* national unit values*/
		egen uv_nat = wtmean(uv_hh), weight(popw) by (code unit)  
		
		// keeping only purchased food items at strata and national level 
		keep if uv_str != . & uv_nat != . 
		
		/* drop if  less than 5 items purchased, by strata)*/
		egen fr = count(_n), by(code unit region urban ) 
		drop if fr<5		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_str = uv_nat  if (uv_str > 5*uv_nat | uv_str <uv_nat/5)  

		/* Item price index for a household */
		gen    pi_hh = (uv_nat/uv_str) * qpurch                     
		keep if pi_hh !=. & qpurch !=.
        
        * Save if needed
        keep hhid region urban popw code unit qpurch epurch uv_hh uv_str uv_reg uv_urb uv_nat fr pi_hh
        save "${gdTemp}/99-wdfdat-paache-`t'.dta", replace
//        
// 		collapse (sum) pi_hh qpurch [weight = popw], by(hhid code unit region urban) 
// 		gen rdef = qpurch/pi_hh 		     
// 		drop if rdef==0 | rdef==. 
//        
//         rename hhid urut
//         merge m:1 urut  ///
//             using `weights' ///
//                 , keepusing(wert) assert(2 3) keep(3) nogen 
//         rename urut hhid
//        
//         g popw = wert
//    
//         collapse (median) rdef [weight = popw] , by(region urban) 
//         replace rdef =1 if rdef ==.
//
//         version 14
//         table region urban , c(mean rdef)            
//
// 	sort region urban 
// 	tempfile df
// 	save `df', replace
//	
//     compress
// 	save "${gdOutput}/paache-deflator-`t'.dta", replace
}