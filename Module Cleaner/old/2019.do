********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2019
*	Subtask			: -
*	Input			: SUSENAS 2019 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2019 ***********

clear
set more off
cap log close

**** Data prep 2019

	*** Consumption Module 41 (food), 188 unique code
	use "$gdData/SUSENAS/Data/MODULE/susenas19mar_41.dta",clear
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
	
	tempfile mar19_41
	save `mar19_41'
	
	*** Consumption Module 42 (non-food)
	use "$gdData/SUSENAS/Data/MODULE/susenas19mar_42.dta",clear
	*isid urut kode
	rename renum urut
	
	tostring urut, replace
	replace urut = trim(urut)
	order urut 
	keep urut-r105 kode b42k3 b42k4 b42k5 sebulan r301
	
	sort urut kode
	keep if inrange(kode,196,204) | ///
			inrange(kode,206,213) | ///
			inrange(kode,215,222)
			
	gen q = .									/* quantity */
	gen v = .									/* monetary value */
	gen kode2 = .
	replace kode2 = 196 if inlist(kode,196,197)
	replace kode2 = 198 if inlist(kode,198,199)
	replace kode2 = 201 if inlist(kode,201,202)
	replace kode2 = 203 if inlist(kode,203,204)
	replace kode2 = 206 if inlist(kode,206,207)
	replace kode2 = 208 if inlist(kode,208,209)
	replace kode2 = 210 if inlist(kode,210,211)
	replace kode2 = 212 if inlist(kode,212,213)
	replace kode2 = 215 if inlist(kode,215,216)
	replace kode2 = 217 if inlist(kode,217,218)
	replace kode2 = 219 if inlist(kode,219,220)
	replace kode2 = 221 if inlist(kode,221,222)
	
		* Energy & Fuel
		bysort urut kode2 (kode): replace b42k3 = b42k3[_n-1] if b42k3 == 0 
		bysort urut kode2 (kode): replace b42k4 = b42k4[_n+1] if b42k4 == 0 
		bysort urut kode2 (kode): replace b42k5 = b42k5[_n+1] if b42k5 == 0
		bysort urut kode2 (kode): replace sebulan = sebulan[_n+1] if sebulan == 0 
		replace q = b42k3
		replace q = b42k3/12 if inlist(kode,212,203)
		replace v = sebulan
		
	drop if inlist(kode,197,199,201,203,204,207,209,211,213,216,218,220,222)
	
	drop b42k3 b42k4 b42k5 sebulan
	
	rename r301 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	gen mod = 42
	
	tempfile mar19_42
	save `mar19_42'
	
	
	* Consumption Module 43 (total)
	use "$gdData/SUSENAS/Data/MODULE/susenas19mar_43.dta", clear
	rename renum urut 
	*isid urut
	
	tostring urut, replace
	replace urut = trim(urut)
		
	rename r301 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nonfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep r101-r105 urut hhsize weind wert 
	order r101-r105 urut hhsize weind wert 
	sort r101-r105 urut
	
	tempfile mar19_43
	save `mar19_43'
	
**** Append

	use `mar19_41'
	append using `mar19_42'
	merge m:1 urut r101-r105 using `mar19_43', nogen
	
	* cw
	gen code18 = kode
	destring code18, replace
	
	merge m:1 code18 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code06 code15 code17 item18 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item18
	
**** Save

	gen year = 2019
	drop if composite == 1
	destring r101, replace
	rename (r101 r102) (provcode kabcode)
	gen urban = (r105==1)
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	save "$gdTemp/SUS_Mod19.dta", replace
	
	* if needed
	use "$gdTemp/SUS_Mod19.dta", clear
	*isid urut kode