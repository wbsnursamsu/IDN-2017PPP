********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2017
*	Subtask			: -
*	Input			: SUSENAS 2017 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2017 ***********

clear
set more off
cap log close

**** Data prep 2017

	*** Consumption Module 41 (food), 236 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas17mar_41.dta",clear
	rename renum urut
	*isid urut kode
	codebook kode
	
	tostring urut, replace
	replace urut = trim(urut)
	order urut 
	keep urut-r105 kode b41k9 b41k10 kalori r301
	rename b41k10 v                              /* monetary value */
	rename b41k9 q                               /* quantity */
	rename kalori c                              /* calories */
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 41
	
	tempfile mar17_41
	save `mar17_41'
	
	*** Consumption Module 42 (non-food)
	use "$gdData/SUSENAS/Data/MODULE/susenas17mar_42.dta",clear
	rename renum urut
	*isid urut kode
	
	tostring urut, replace
	replace urut = trim(urut)
	order urut 
	keep urut-r105 kode b42k3 b42k4 b42k5 sebulan r301
	
	sort urut kode
	keep if inrange(kode,244,252) | ///
			inrange(kode,254,270) 
			
	gen q = .									/* quantity */
	gen v = .									/* monetary value */
	
	gen kode2 = .
	replace kode2 = 244 if inlist(kode,244,245)
	replace kode2 = 246 if inlist(kode,246,247)
	replace kode2 = 249 if inlist(kode,249,250)
	replace kode2 = 251 if inlist(kode,251,252)
	replace kode2 = 254 if inlist(kode,254,255)
	replace kode2 = 256 if inlist(kode,256,257)
	replace kode2 = 258 if inlist(kode,258,259)
	replace kode2 = 260 if inlist(kode,260,261)
	replace kode2 = 263 if inlist(kode,263,265)
	replace kode2 = 265 if inlist(kode,265,266)
	replace kode2 = 267 if inlist(kode,267,268)
	replace kode2 = 269 if inlist(kode,269,270)
	
		* Energy & Fuel
		bysort urut kode2 (kode): replace b42k3 = b42k3[_n-1] if b42k3 == 0 
		bysort urut kode2 (kode): replace b42k4 = b42k4[_n+1] if b42k4 == 0 
		bysort urut kode2 (kode): replace b42k5 = b42k5[_n+1] if b42k5 == 0
		bysort urut kode2 (kode): replace sebulan = sebulan[_n+1] if sebulan == 0 
		replace q = b42k3
		replace v = sebulan
		
	drop if inlist(kode,245,247,249,251,255,257,259,261,264,266,268,270)
	
	drop b42k3 b42k4 b42k5 sebulan
	
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar17_42
	save `mar17_42'
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas17mar_43.dta", clear
	rename renum urut
	*isid urut
	
	tostring urut, replace
	replace urut = trim(urut)
		
	rename r301 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep r101-r105 urut hhsize weind wert 
	order r101-r105 urut hhsize weind wert 
	sort r101-r105 urut
	
	tempfile mar17_43
	save `mar17_43'
	
**** Append

	use `mar17_41'
	append using `mar17_42'
	merge m:1 urut r101-r105 using `mar17_43', nogen
	
	* cw
	gen code17 = kode
	destring code17, replace
	
	merge m:1 code17 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code06 code15 code18 item17 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item17
	
**** Save

	gen year = 2017
	drop if composite == 1
	destring r101, replace
	rename (r101 r102) (provcode kabcode)
	gen urban = (r105==1)
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	save "$gdTemp/SUS_Mod17.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod17.dta", clear
	isid urut kode