********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2004
*	Subtask			: -
*	Input			: SUSENAS 2004 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2004 ***********

clear
set more off
cap log close

**** Data prep 2004

	* Consumption Module 41 (food), 229 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas04feb_41.dta",clear
	egen urut = concat(b1r1-b1r8)
	*isid urut kode
	
	tostring urut, replace format("%12.0f")
	replace urut = trim(urut)
	rename b41k1 kode
	keep urut b1r1-b1r8 kode b41k8 b41k9
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	gen c = .
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile sus04_41
	save `sus04_41'
	
	* Consumption Module 42 (non-food)
	use "$gdData/SUSENAS/Data/MODULE/susenas04feb_42.dta",clear
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
	
	tempfile sus04_42
	save `sus04_42'
	
**** Merge with exppl & consumption module crosswalk

	* Merge 41 & 42
	use `sus04_41', clear
	append using `sus04_42'

	drop wert weind

	* cw
	gen code04 = kode
	destring code04, replace
	
	merge m:1 code04 using "${gdTemp}/crosswalk-2004.dta", keepusing(code02 code05 code06 code15 code17 code18 item04 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item04
		
	* exppl
	preserve 
		use "$gdData/Exppl/exppl04.dta", clear
		foreach i of varlist b1r1-b1r8 {
			tostring `i', replace
		}
		replace b1r2 = "0" + b1r2 if length(b1r2) == 1
		replace b1r3 = "0" + b1r3 if length(b1r3) == 2
		replace b1r4 = "00" + b1r4 if length(b1r4) == 1
		replace b1r4 = "0" + b1r4 if length(b1r4) == 2
		replace b1r8 = "0" + b1r8 if length(b1r8) == 1
		egen urut = concat(b1r1-b1r8)
		drop b1r1-b1r8
		tostring urut, replace format("%12.0f")
		replace urut = trim(urut)
		tempfile temp
		save `temp'
	restore
	merge m:1 urut using `temp'
	drop if _merge == 1
	drop _merge
	gen year = 2004
	drop if composite == 1
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5=="1")
	destring provcode, replace
	destring kabcode, replace
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	
	save "$gdTemp/SUS_Mod04.dta", replace