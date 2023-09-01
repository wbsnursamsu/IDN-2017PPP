********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS Extracting Data for Consumption Module 2007
*	Subtask			: -
*	Input			: SUSENAS 2007 Consumption Module
*	Note			: -
********************************************************************************

********* WARNING: YEAR = 2007 ***********

clear
set more off
cap log close

**** Data prep 2007
	
	use "$gdData/SUSENAS/Data/MODULE/susenas07feb_43.dta",clear
	rename (prop kabu keca desa daer nks nurt jart) (b1r1 b1r2 b1r3 b1r4 b1r5 b1r7 b1r8 hhsize)
	label values b1r1
	label values b1r5
	egen urut = concat(b1r1-b1r8)
	duplicates tag urut, gen(dup)
	drop if dup > 0

	*isid urut kode
	drop kalori hhsize food nfood weind07 b1r1-b1r8
	drop *231 *232 *233 *234 *235 *236 *251 *254 *255 v256-v290 v297-v343
	
	timer clear
	timer on 1
	reshape long q v c, i(urut) j(kode) string
	timer off 1
	timer list 1
	
	save temp.dta, replace
	use temp.dta, clear
	
	destring kode, replace
	gen mod = . 
	replace mod = 41 if kode <= 229
	replace mod = 42 if kode > 229
	
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
		bysort urut kode2 (kode): replace q = v[1] if kode2 != .
		bysort urut kode2 (kode): replace v = v[2] if kode2 != .
		
	drop if inlist(kode,238,241,243,245,247,249,251,254,286,288,290)
	drop kode2
	
	label values kode
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	
	* cw
	gen code06 = kode
	destring code06, replace
	
	merge m:1 code06 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code15 code17 code18 item06 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item06
	
	drop if v == 0 & q == 0
	drop if q == 0
	sort urut kode
	
	preserve
		use "$gdData/Exppl/exppl07.dta", clear
		egen urut = concat(b1r1-b1r8)
		isid urut
		tempfile t
		save `t'
	restore
	
	merge m:1 urut using `t'
	drop if _merge == 1
	drop _merge
	
	gen year = 2007
	drop if composite == 1
	rename (b1r1 b1r2) (provcode kabcode)
	gen urban = (b1r5==1)
	label values provcode
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
	
	save "$gdTemp/SUS_Mod07.dta", replace