********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2014
*	Subtask			: -
*	Input			: SUSENAS 2014 Consumption Module
*	Note			: Module 42 does not contain quantity information!
********************************************************************************

********* WARNING: YEAR = 2014 ***********

clear
set more off
cap log close

**** Data prep 2014

	*** Consumption Module 41 (food), 229 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas14mar_41.dta",clear
	isid urut kode
	
	replace urut = trim(urut)
	keep urut-b1r8 kode b41k8 b41k9 kalori b2r1
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	rename kalori c                              /* calories */
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar14_41
	save `mar14_41'
	
	*** Consumption Module 42 (non-food), 102 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas14mar_42.dta",clear
	isid urut kode
	
	replace urut = trim(urut)
	
	keep urut-b1r8 kode b42k2 b42k3 b42k4 b42k5 b42k6 b2r1
	
	destring kode, replace
	sort urut kode
	keep if inrange(kode,237,250) | ///
			inrange(kode,252,253) | ///
			inrange(kode,291,296)
	
	gen q = .									/* quantity */
	gen v = .									/* monetary value */
	
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
	
		* Energy & Fuel
		bysort urut kode2 (kode): replace b42k2 = b42k2[_n-1] if b42k2 == 0 
		bysort urut kode2 (kode): replace b42k3 = b42k3[_n+1] if b42k3 == 0 
		bysort urut kode2 (kode): replace b42k4 = b42k4[_n+1] if b42k4 == 0 
		bysort urut kode2 (kode): replace b42k5 = b42k5[_n+1] if b42k5 == 0
		bysort urut kode2 (kode): replace b42k6 = b42k6[_n+1] if b42k6 == 0 
		replace q = b42k2 if inrange(kode,237,296)
		replace v = b42k5 if inrange(kode,237,296)
	
	drop if inlist(kode,237,239,241,243,245,249,252,291,293,295)
		
	drop b42k2 b42k3 b42k4 b42k6 b42k5
                   
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar14_42
	save `mar14_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas14mar_43.dta", clear
	isid urut
	
	replace urut = trim(urut)
		
	rename b2r1 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep b1r1-b1r8 urut hhsize weind wert 
	order b1r1-b1r8 urut hhsize weind wert 
	sort b1r1-b1r8 urut
	
	tempfile mar14_43
	save `mar14_43'
	
	
**** Append

	use `mar14_41'
	append using `mar14_42'
	merge m:1 urut-b1r8 using `mar14_43', nogen
	
	gen code11 = kode
	destring code11, replace

	* Merge with food crosswalk data
	
	merge m:m code11 using "$gdData/Crosswalk/consumption_module_crosswalk.dta", keepusing(code11 code15 code17 code18 composite)
	drop if _merge == 2
	drop _merge
	
**** Save

	gen year = 2014
	drop if composite == 1
	* Special district code extraction from SUS 2014
	destring urut, generate(urut2)
	gen z = urut2/(10^11)
	replace z = floor(z)
	rename z b1r2
	*
	cap tostring b1r2, replace
	replace b1r2 = substr(b1r2,-2,.)
	cap destring b1r2, replace
	destring b1r1, replace
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5==1)
	keep provcode urban kabcode urut mod kode q v c hhsize weind wert year
	order year provcode urban kabcode urut mod kode q v c hhsize weind wert 
	save "$gdTemp/SUS_Mod14.dta", replace

	* if needed
	use "$gdTemp/SUS_Mod14.dta", clear
	isid urut kode