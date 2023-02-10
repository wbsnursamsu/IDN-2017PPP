********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2011
*	Subtask			: -
*	Input			: SUSENAS 2011 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2011 ***********

clear
set more off
cap log close

**** Data prep 2011
	
	*** Consumption Module 41 (food), 229 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas11mar_41.dta",clear
	egen urut = concat(b1r1-b1r8)
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	keep urut b1r1-b1r8 kode b41k8 b41k9 kalori b2r1
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	rename kalori c                              /* calories */
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar11_41
	save `mar11_41'
	
	*** Consumption Module 42 (non-food), 102 unique code. 
	* Converts data to 1 month period q and v
	use "$gdData/SUSENAS/Data/MODULE/susenas11mar_42.dta", clear
	egen urut = concat(b1r1-b1r8)
	
	destring b1r1, replace
	destring b1r5, replace
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	keep urut b1r1-b1r8 kode b42k2 b42k5 b42k6 b2r1
	
	sort urut kode
	keep if	inrange(kode,237,250) | ///
			inrange(kode,252,253) | ///
			inrange(kode,291,296)
	
	gen q = .									/* quantity */
	gen v = .									/* monetary value */
	
		* Energy & Fuel
		replace q = b42k2 if inrange(kode,237,296)
		replace v = b42k5 if inrange(kode,237,296)
		
	drop b42k2 b42k6 b42k5
                   
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar11_42
	save `mar11_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas11mar_43.dta", clear
	egen urut = concat(b1r1-b1r8)
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
		
	rename b2r1 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nonfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep b1r1-b1r8 urut hhsize weind 
	order b1r1-b1r8 urut hhsize weind 
	sort b1r1-b1r8 urut
	
	tempfile mar11_43
	save `mar11_43'
	
**** Append

	use `mar11_41'
	append using `mar11_42'
	merge m:1 urut b1r1-b1r8 using `mar11_43', nogen
	
	* Obtain WERT from exppl
	merge m:1 b1r1-b1r8 using "$gdData/Exppl/exppl11mar.dta", keepusing(wert) nogen
	
	gen code11 = kode
	destring code11, replace

	* Merge with food crosswalk data
	
	merge m:m code11 using "$gdData/Crosswalk/consumption_module_crosswalk.dta", keepusing(code11 code15 code17 code18 composite)
	drop if _merge == 2
	drop _merge
	
**** Save

	gen year = 2011
	drop if composite == 1
	destring b1r1, replace
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5==1)
	keep provcode urban kabcode urut mod kode q v c hhsize weind wert year
	order year provcode urban kabcode urut mod kode q v c hhsize weind wert 
	save "$gdTemp/SUS_Mod11.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod11.dta", clear
	isid urut kode