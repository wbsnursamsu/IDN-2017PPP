********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2010
*	Subtask			: -
*	Input			: SUSENAS 2010 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2010 ***********

clear
set more off
cap log close

**** Data prep 2010
	
	* Consumption Module 41 (food), 229 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas10mar_41.dta",clear
	egen urut = concat(b1r1-b1r8)
	*isid urut kode
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	keep urut b1r1-b1r8 kode b41k8 b41k9 kalori b2r1
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	rename kalori c                              /* calories */
	rename b2r1 hhsize
	
	label values kode
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar10_41
	save `mar10_41'
	
	* Consumption Module 42 (non-food), 102 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas10mar_42.dta", clear
	egen urut = concat(b1r1-b1r8)
	
	destring b1r1, replace
	destring b1r5, replace
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	keep urut b1r1-b1r8 kode b42k3 b42k4 b2r1

	/* Fuel and Energy */
	keep if inrange(kode,237,250) | ///
		    inrange(kode,291,296)
	label values kode 
	gen kode2 = .
	replace kode2 = 237 if inlist(kode,237,238)
	replace kode2 = 239 if inlist(kode,239,240)
	replace kode2 = 241 if inlist(kode,241,242)
	replace kode2 = 243 if inlist(kode,243,244)
	replace kode2 = 245 if inlist(kode,245,246)
	replace kode2 = 247 if inlist(kode,247,248)
	replace kode2 = 249 if inlist(kode,249,250)
	replace kode2 = 291 if inlist(kode,291,292)
	replace kode2 = 293 if inlist(kode,293,294)
	replace kode2 = 295 if inlist(kode,295,296)
	
	sort urut kode2 kode
	
	gen v = .
	gen q = .
	gen c = .
	bysort urut kode2 (kode): replace v = b42k3[2]
	bysort urut kode2 (kode): replace q = b42k3[1]

	bysort urut kode2 (kode): keep if _n == 1
	drop kode2 b42k3 b42k4
	
	rename b2r1 hhsize
	
	label values kode
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar10_42
	save `mar10_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas10mar_43.dta", clear
	egen urut = concat(b1r1-b1r8)
	*isid urut
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
		
	rename b2r1 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep b1r1-b1r8 urut hhsize weind 
	order b1r1-b1r8 urut hhsize weind 
	sort b1r1-b1r8 urut
	
	tempfile mar10_43
	save `mar10_43'
	
**** Append

	use `mar10_41'
	append using `mar10_42'
	merge m:1 urut b1r1-b1r8 using `mar10_43', nogen
	
	* Obtain WERT from exppl
	merge m:1 b1r1-b1r8 using "$gdData/Exppl/exppl10.dta", keepusing(wert) nogen
	
	* cw
	gen code06 = kode
	destring code06, replace
	
	merge m:1 code06 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code15 code17 code18 item06 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item06
	
**** Save

	gen year = 2010
	drop if composite == 1
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5==1)
	label values provcode
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	save "$gdTemp/SUS_Mod10.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod10.dta", clear
	isid urut kode