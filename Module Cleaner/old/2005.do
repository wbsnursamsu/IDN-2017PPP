********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2005
*	Subtask			: -
*	Input			: SUSENAS 2005 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2005 ***********

clear
set more off
cap log close

**** Data prep 2005
	
	* Consumption Module 41 (food), 229 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas05feb_41.dta",clear
	egen urut = concat(b1r1-b1r8)
	*isid urut kode
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	rename b41k1 kode
	keep urut b1r1-b1r8 kode b41k8 b41k9
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	gen c = .
	
	label values kode
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile sus05_41
	save `sus05_41'
	
	* Consumption Module 42 (non-food)
	use "$gdData/SUSENAS/Data/MODULE/susenas05feb_42.dta",clear
	egen urut = concat(b1r1-b1r8)
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut) 
	rename b42k1 kode
	destring kode, replace
	
	keep if inrange(kode,237,238) | ///
			inrange(kode,240,251) | ///
			inrange(kode,253,254) | ///
			inrange(kode,285,290)
			
	gen q = .
	gen v = .
	gen kode2 = .

	replace kode2 = 237 if inlist(kode,237,238)
	replace kode2 = 240 if inlist(kode,240,241)
	replace kode2 = 242 if inlist(kode,242,243)
	replace kode2 = 244 if inlist(kode,244,245)
	replace kode2 = 246 if inlist(kode,246,247)
	replace kode2 = 248 if inlist(kode,248,249)
	replace kode2 = 250 if inlist(kode,250,251)
	replace kode2 = 253 if inlist(kode,253,254)
	replace kode2 = 285 if inlist(kode,285,286)
	replace kode2 = 287 if inlist(kode,287,288)
	replace kode2 = 289 if inlist(kode,289,290)
	
		* Fuel and Energy
		bysort urut kode2 (kode): replace q = b42k3[1]
		bysort urut kode2 (kode): replace v = b42k3[2]
		
	drop if inlist(kode,238,241,243,245,247,249,251,254,286,288,290)
	
	label values kode
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile sus05_42
	save `sus05_42'
	
**** Merge with exppl & consumption module crosswalk

	* Merge 41 & 42
	use `sus05_41', clear
	append using `sus05_42'
	
	drop weind wert

	* cw
	gen code05 = kode
	destring code05, replace
	
	merge m:1 code05 using "${gdTemp}/crosswalk-2005.dta", keepusing(code02 code04 code06 code15 code17 code18 item05 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item05
	
	* exppl
	merge m:1 b1r1-b1r8 using "$gdData/Exppl/exppl05.dta", nogen
	gen year = 2005
	drop if composite == 1
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5==1)
	label values provcode
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	
	save "$gdTemp/SUS_Mod05.dta", replace