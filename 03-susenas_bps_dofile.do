********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: SUSENAS 2014 BPS do-files
*	Subtask			: -
*	Input			: SUSENAS 2014
*	Note			: -
********************************************************************************

**** Data prep

**** OBSOLETE DO-FILE

	/*
	* Consumption Module 41 (food)
	use "$raw_data\susenas14mar_41.dta",clear
	replace urut = trim(urut)
	keep urut-b1r8 kode b41k8 b41k9 kalori b2r1
	rename b41k9 v                               /* monetary value */
	rename b41k8 q                               /* quantity */
	rename kalori c                              /* calories */
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	
	reshape wide v q c, i(b1r1-b1r8 urut) j(kode) string
	order b1r1-b1r8 urut hhsize v* q* c*
	
	save "$created_data\susenas14mar_41_reshaped.dta", replace
	
	* Consumption Module 42 (non-food)
	use "$raw_data\susenas14mar_42.dta",clear
	replace urut = trim(urut)
	
	keep urut-b1r8 kode b42k6 b2r1
	rename b42k6 v                        /* monetary value */
	rename b2r1 hhsize
	
	tostring kode, replace
	replace kode = "0" + kode if length(kode) == 2
	replace kode = "00" + kode if length(kode) == 1
	
	reshape wide v, i(b1r1-b1r8 urut) j(kode) string
	order b1r1-b1r8 urut hhsize v*
	
	save "$created_data\susenas14mar_42_reshaped.dta", replace
	
	* Consumption Module 43 (total)
	use "$raw_data\susenas14mar_43.dta", clear
	replace urut = trim(urut)
		
	rename b2r1 hhsize
	gen fooda = food/hhsize                       /* food per capita */
	gen nfooda = nfood/hhsize                     /* non food per capita */
	gen expa = expend/hhsize                      /* expenditure per capita */ 
	keep b1r1-b1r8 urut hhsize weind fooda nfooda expa
	order b1r1-b1r8 urut hhsize weind fooda nfooda expa
	sort b1r1-b1r8 urut
	
	save "$created_data\susenas14mar_43_reshaped.dta", replace
	
	* Combine data
	use "$created_data\susenas14mar_41_reshaped.dta", clear
	merge 1:1 b1r1-b1r8 urut using "$created_data\susenas14mar_42_reshaped.dta"
	drop _m
	merge 1:1 b1r1-b1r8 urut using "$created_data\susenas14mar_43_reshaped.dta"
	drop _m
	