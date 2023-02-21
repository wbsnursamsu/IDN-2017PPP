********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2015
*	Subtask			: -
*	Input			: SUSENAS 2015 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2015 ***********

clear
set more off
cap log close

**** Data prep 2015

	*** Consumption Module 41 (food), 126 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas15mar_41.dta",clear
	*isid urut kode
	codebook kode
	
	tostring urut, replace
	replace urut = trim(urut)
	keep urut-r108 kode b41k5 b41k6 kalori r301
	rename b41k6 v                               /* monetary value */
	rename b41k5 q                               /* quantity */
	rename kalori c                              /* calories */
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar15_41
	save `mar15_41'
	
	*** Consumption Module 42 (non-food), 102 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas15mar_42.dta",clear
	isid urut kode
	
	tostring urut, replace
	replace urut = trim(urut)
	keep urut-r108 kode b42k3 b42k4 b42k5 sebulan r301
	
	sort urut kode
	keep if inrange(kode,133,144) | ///
			inrange(kode,146,150) | ///
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
		
	keep if inlist(kode,133,135,137,139,141,143,147,149,154,156,158,160)
	
	drop b42k3 b42k4 b42k5 sebulan
    
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar15_42
	save `mar15_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas15mar_43.dta", clear
	
	tostring urut, replace
	replace urut = trim(urut)
		
	rename r301 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep r101-r108 urut hhsize weind wert 
	order r101-r108 urut hhsize weind wert 
	sort r101-r108 urut
	
	tempfile mar15_43
	save `mar15_43'
	
**** Append

	use `mar15_41'
	append using `mar15_42'
	merge m:1 urut r101-r108 using `mar15_43', nogen
	
	* cw
	gen code15 = kode
	destring code15, replace
	
	merge m:1 code15 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code06 code17 code18 item15 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item15
	
**** Save

	gen year = 2015
	drop if composite == 1
	destring r101, replace
	rename (r101 r102) (provcode kabcode)
	gen urban = (r105==1)
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	save "$gdTemp/SUS_Mod15.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod15.dta", clear
	isid urut kode