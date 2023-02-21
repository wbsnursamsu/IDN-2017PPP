********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Calibrating Spatial Laspeyres Index, 2.15 USD 2017 PPP
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************
	
**** Generate calibration coefficient (to be multiplied with Spatial Laspeyres Index)
* Matching variable: Published IPL from povcalnet at 1.9, 3.2 and 5.5 USD PPP *
*** Setup Gradient Descent Algorithm
foreach ipl in 2.15 3.65 6.85 {
	* Load the dataset (from do-file 6)
	use "$gdOutput/Exppl - Laspeyres Merged 2002-2022.dta", clear
	replace cpi2017 = cpi2017/100
	drop if inlist(year,2000,2001)
	mat A = J(20,3,.)
	mat colnames A = "year" "alphaR" "alphaU"
	* Change this parameter `jumps' to increase/reduce precision. This will affect runtime
	local jumps = 0.0005 
	local counter = 1
	* Capture delete some temporarily generated variables
	foreach i in y_pcexp rpcexp_ppp poor_IPL y_pcexp_laspU rpcexp_ppp_laspU poor_IPL_laspU food_defl y_pcexp_fooddefl rpcexp_ppp_fooddefl poor_IPL_fooddefl {
		cap drop `i'
	}
	* Baseline (to match)
	gen y_pcexp = pcexp * 12
	gen rpcexp_ppp = .
	replace rpcexp_ppp = (y_pcexp/cpi2017/icp17rural/365) if urban == 0
	replace rpcexp_ppp = (y_pcexp/cpi2017/icp17urban/365) if urban == 1
	gen poor_IPL = rpcexp_ppp < `ipl'	
	* Current spatially adjusted (based on deflating total: food + nonfood consumption), initial value
	gen y_pcexp_laspU = pcexp * 12 / lasp_avgnatU_v5
	gen rpcexp_ppp_laspU = (y_pcexp_laspU/cpi2017/icp17/365)
	gen poor_IPL_laspU = rpcexp_ppp_laspU < `ipl'
	* Spatially adjusted, only deflating food consumption, initial value
	gen food_defl = food / lasp_avgnatU_v5
	gen y_pcexp_fooddefl = ((food_defl + nfood)/hhsize) * 12
	gen rpcexp_ppp_fooddefl = (y_pcexp_fooddefl/cpi2017/icp17/365)
	gen poor_IPL_fooddefl = rpcexp_ppp_fooddefl < `ipl'
	** CALIBRATE FOR P0 RATE BASED ON FOOD ONLY DEFLATION
	* Run the year loop
    
**# Bookmark #1
    
	levelsof year
	foreach y in 2002 2006 2010 2014 2018 2022 {
		foreach u in 0 1 {
			local initval = 1
			local a = `initval'
			sum poor_IPL [w=weind] if year == `y' & urban == `u'
			local pbase = round(r(mean),`jumps')
			di `pbase'
			sum poor_IPL_fooddefl [w=weind] if year == `y' & urban == `u'
			local pfooddefl = round(r(mean),`jumps')
			di `pfooddefl'
			while `pfooddefl' != `pbase' {
				di "Year `y'. Now running at alpha = `a'" 
				* Reconstructing food
					cap drop food_defl y_pcexp_fooddefl rpcexp_ppp_fooddefl poor_IPL_fooddefl
					gen food_defl = food / (lasp_avgnatU_v5 * `a')
					gen y_pcexp_fooddefl = ((food_defl + nfood)/hhsize) * 12
					gen rpcexp_ppp_fooddefl = (y_pcexp_fooddefl/cpi2017/icp17/365)
					gen poor_IPL_fooddefl = rpcexp_ppp_fooddefl < `ipl'
				if `pfooddefl' > `pbase' {
					local a = `a' - `jumps'
				}
				else if `pfooddefl' < `pbase' {
					local a = `a' + `jumps'
				}
				qui sum poor_IPL_fooddefl [w=weind] if year == `y' & urban == `u'
				local pfooddefl = round(r(mean),`jumps')
				local divergence = `pfooddefl' - `pbase'
				di "Divergence needs to be closed = `divergence'"
				if abs(`divergence') <= `jumps' {
					continue, break
				}
			}
			di "`a'"
			mat A[`counter',1] = `y'
			if `u' == 0 {
				mat A[`counter',2] = `a'
			}
			else if `u' == 1 {
				mat A[`counter',3] = `a'
			}
		}
		local counter = `counter' + 1
	}
mat list A
* Save the results
clear
svmat A, names(col)
save "$gdOutput/Spatial Laspeyres Calibrator - `ipl' USD PPP - Food Deflation 2022.dta", replace
}
********************************** UNUSED **************************************
	/***** CALIBRATE FOR P0 RATE BASED ON TOTAL CONSUMPTION AGGREGATE
	* Run the year loop
	levelsof year
	forval y = 2010/2021 {
		foreach u in 0 1 {
			
		local initval = 1
		local a = `initval'
				
		sum poor_IPL [w=weind] if year == `y' & urban == `u'
		local pbase = round(r(mean),`jumps')
		di `pbase'
		sum poor_IPL_laspU [w=weind] if year == `y' & urban == `u'
		local plaspU = round(r(mean),`jumps')
		di `plaspU'
				
		while `plaspU' != `pbase' {
			di "Year `y'. Now running at alpha = `a'" 
			cap drop poor 
			gen poor = ((pcexp * 12 / (lasp_avgnatU_v5 * `a'))/cpi2011/icp11/365) < `ipl'
			if `plaspU' > `pbase' {
			local a = `a' - `jumps'
		}
		else if `plaspU' < `pbase' {
			local a = `a' + `jumps'
		}
		qui sum poor [w=weind] if year == `y' & urban == `u'
		local plaspU = round(r(mean),`jumps')
		local divergence = `plaspU' - `pbase'
		di "Divergence needs to be closed = `divergence'"
		if abs(`divergence') <= `jumps' {
				continue, break
				}
			}
						
			di "`a'"
			mat A[`counter',1] = `y'
			if `u' == 0 {
				mat A[`counter',2] = `a'
			}
			else if `u' == 1 {
				mat A[`counter',3] = `a'
			}
		}
		local counter = `counter' + 1
			}

		mat list A
		
		* Save the results
		
		preserve
			clear
			svmat A, names(col)
			save "$created_data\Spatial Laspeyres Calibrator - `ipl' USD PPP - PCEXP deflation.dta", replace
		restore */