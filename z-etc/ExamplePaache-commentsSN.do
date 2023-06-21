	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR 
	*----------------------------------------------------------------------*
	use "${in}/${dta_file}_m09_food.dta", clear
	la lang ${LNG}

	unique hhid 

		merge m:1 hhid  ///
			using "${out}/${out_file}_weights.dta" ///
				, assert(3) nogen 
				

		g code = food_code
		g int unit = 1  
		 
	* some screening about duration and food items consumed !!!!!!!
		bys hhid (code): egen n_food_consumed = sum(food_consumed)
	
		clonevar  qcons = food_cons_amt  // quantity of consumed 
		clonevar  qpurch = food_purch_amt     // quantity of purchase
		clonevar  epurch =   food_purch_cost  // expenditure of purchase

		// purchased food table
		g purch =(food_purch_cost > 0 & food_purch_cost !=.) 
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

**# Bookmark #2: Why we collapsed by code also? Don't we want to get sum of qpurch and price indices, aggregating commodity bundles consumed (code) from each HH?
		collapse (sum) pi_hh qpurch [weight = popw], by(hhid code unit region urban) 
**# Bookmark #4: qpurch would cancel out and we would only get uv_str/uv_nat 
		gen rdef = qpurch/pi_hh 		     
		drop if rdef==0 | rdef==. 
	
	
		merge m:1 hhid  ///
			using "${out}/${out_file}_weights.dta" ///
				, assert(2 3) keep(3) nogen 
				
	
**# Bookmark #3: If we take the median from this collapse result, we would only get the median of uv_str/uv_nat since qpurch will cancel out 
		collapse (median) rdef [weight = popw] , by(region urban) 
		replace rdef =1 if rdef ==.

		version 14
		table region urban , c(mean rdef)

	sort region urban 
	tempfile df
	save `df', replace
	
	la lang ${LNG}
	saveold "${out}/${out_file}_deflator.dta", replace
