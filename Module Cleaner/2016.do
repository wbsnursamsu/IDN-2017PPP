********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2016
*	Subtask			: -
*	Input			: SUSENAS 2016 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2016 ***********

clear
set more off
cap log close

**** Data prep 2016

	*** Consumption Module 41 (food), 126 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas16mar_41.dta",clear
	*isid urut kode
	codebook kode
	
	tostring urut, replace
	replace urut = trim(urut)
	order urut 
	keep urut-r108 kode b41k5 b41k6 kalori r301
	rename b41k6 v                               /* monetary value */
	rename b41k5 q                               /* quantity */
	rename kalori c                              /* calories */
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar16_41
	save `mar16_41'
	
	
	*** Consumption Module 42 (non-food), 102 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas16mar_42.dta",clear
	isid urut kode
	
	tostring urut, replace
	replace urut = trim(urut)
	order urut
	keep urut-r108 kode b42k3 b42k4 b42k5 sebulan r301
	
	sort urut kode
	keep if inrange(kode,133,144) | ///
			inrange(kode,147,150) | ///
			inrange(kode,154,161)
			
	gen q = .									/* quantity */
	gen v = .									/* monetary value */
	gen kode2 = .
	replace kode2 = 133 if inlist(kode,133,134)
	replace kode2 = 135 if inlist(kode,135,136)
	replace kode2 = 137 if inlist(kode,137,138)
	replace kode2 = 139 if inlist(kode,139,140)
	replace kode2 = 141 if inlist(kode,141,142)
	replace kode2 = 143 if inlist(kode,143,144)
	replace kode2 = 147 if inlist(kode,147,148)
	replace kode2 = 149 if inlist(kode,149,150)
	replace kode2 = 154 if inlist(kode,154,155)
	replace kode2 = 156 if inlist(kode,156,157)
	replace kode2 = 158 if inlist(kode,158,159)
	replace kode2 = 160 if inlist(kode,160,161)
	
		* Energy & Fuel
		bysort urut kode2 (kode): replace b42k3 = b42k3[_n-1] if b42k3 == 0 
		bysort urut kode2 (kode): replace b42k4 = b42k4[_n+1] if b42k4 == 0 
		bysort urut kode2 (kode): replace b42k5 = b42k5[_n+1] if b42k5 == 0
		bysort urut kode2 (kode): replace sebulan = sebulan[_n+1] if sebulan == 0 
		replace q = b42k3
		replace v = sebulan
		
	drop if inlist(kode,133,135,137,139,141,143,147,149,154,156,158,160)
	
	drop b42k3 b42k4 b42k5 sebulan
	
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar16_42
	save `mar16_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas16mar_43.dta", clear
	
	tostring urut, replace
	replace urut = trim(urut)
		
	rename r301 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep r101-r108 urut hhsize weind wert 
	order r101-r108 urut hhsize weind wert 
	sort r101-r108 urut
	
	tempfile mar16_43
	save `mar16_43'
	
**** Append

	use `mar16_41'
	append using `mar16_42'
	merge m:1 urut r101-r108 using `mar16_43', nogen
	
	gen code15 = kode
	destring code15, replace

	* Merge with food crosswalk data
	
	merge m:m code15 using "$gdData/Crosswalk/consumption_module_crosswalk.dta", keepusing(code11 code15 code17 code18 composite)
	drop if _merge == 2
	drop _merge
	
**** Save

	gen year = 2016
	drop if composite == 1
	destring r101, replace
	rename (r101 r102) (provcode kabcode)
	gen urban = (r105==1)
	keep provcode urban kabcode urut mod kode q v c hhsize weind wert year
	order year provcode urban kabcode urut mod kode q v c hhsize weind wert 
	save "$gdTemp/SUS_Mod16.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod16.dta", clear
	isid urut kode