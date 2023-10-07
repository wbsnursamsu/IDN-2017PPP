	*----------------------------------------------------------------------*
	* SETUP FOR SPATIAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*

clear all
set trace off
log close

    *=== MARCH DATA ===*
    
foreach t in 2010 2011 2012 2015 2016 2017 2018 2019 2020 2021 2022 {
    log using "${gdLog}/spatial-setup-mar-`t'.dta", replace
	use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
   
    /* collapse to adjust with price survey and merge with price survey data */
    * set price data
    preserve
    keep if urban==1
    * SHK
        merge m:1 kode urban using "${gdTemp}/shk-adjust-`t'.dta", nogen
        drop if urut == ""

    replace kode = code_2 if !missing(code_2)
   
    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut provcode kabcode urban kode ditem_all)
        merge m:1 provcode kode year using "${gdTemp}/shk-price-prov-bpscode-ALL.dta", keepusing(p_g_*) nogen
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
    
    tempfile dat1
    save `dat1', replace
    
    restore
    keep if urban==0
    * SHKP
        merge m:1 kode urban using "${gdTemp}/shkp-adjust-`t'.dta", nogen
        drop if urut == ""

    replace kode = code_2 if !missing(code_2)
    
    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut provcode kabcode urban kode ditem_all)
        merge m:1 provcode kode year using "${gdTemp}/shkp-price-prov-bpscode-ALL.dta", keepusing(p_g_*) nogen 
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
    
    append using `dat1', replace
    
   /* rent price */
    merge 1:1 urut kode using "${gdTemp}/rent-predict-mar-`t'-2.dta", nogen keepusing(rent prent hstat)
    destring kode, replace
    
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
           
    * ------------------------------------------------------------------- *
   
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
    g p_ps = p_g_mar               // price from price survey
   
	unique hhid 				

		g code = kode
		 
	* some screening about duration and food items consumed !!!!!!!	
		clonevar  qpurch = q     // quantity of purchase
		clonevar  epurch = v     // expenditure of purchase

		// purchased food table
		g purch =(v > 0 & v !=.) 
		keep if purch == 1
		//unit values for purchased food (hh level)		
		g uv_hh = epurch/qpurch 

    save "${gdTemp}/temp-susenas-`t'.dta", replace
}


    *=== FOR 2013 AND 2014 USING POOLED DATA ===*
    
foreach t in 2013 2014 {
    log using "${gdLog}/spatial-setup-pool-`t'.dta", replace
	use "${gdCons}/sus-cm-pool-`t'-full.dta", clear
   
    /* collapse to adjust with price survey and merge with price survey data */
    * set price data
    preserve
    keep if urban==1
    * SHK
        merge m:1 kode urban using "${gdTemp}/shk-adjust-`t'.dta", nogen
        drop if urut == ""

    replace kode = code_2 if !missing(code_2)
   
    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut provcode kabcode urban kode ditem_all)
        merge m:1 provcode kode year using "${gdTemp}/shk-price-prov-bpscode-ALL.dta", keepusing(p_g_*) nogen
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
    
    tempfile dat1
    save `dat1', replace
    
    restore
    keep if urban==0
    * SHKP
        merge m:1 kode urban using "${gdTemp}/shkp-adjust-`t'.dta", nogen
        drop if urut == ""

    replace kode = code_2 if !missing(code_2)
    
    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut provcode kabcode urban kode ditem_all)
        merge m:1 provcode kode year using "${gdTemp}/shkp-price-prov-bpscode-ALL.dta", keepusing(p_g_*) nogen 
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
    
    append using `dat1', replace
    
   /* rent price */
    merge 1:1 urut kode using "${gdTemp}/rent-predict-pool-`t'-2.dta", nogen keepusing(rent prent hstat)
    destring kode, replace
    
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
           
    * ------------------------------------------------------------------- *
   
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
    g p_ps = p_g_avg                 // price from price survey
   
	unique hhid 				

		g code = kode
		 
	* some screening about duration and food items consumed !!!!!!!	
		clonevar  qpurch = q     // quantity of purchase
		clonevar  epurch = v     // expenditure of purchase

		// purchased food table
		g purch =(v > 0 & v !=.) 
		keep if purch == 1
        
		//unit values for purchased food (hh level)		
		g uv_hh = epurch/qpurch 

    save "${gdTemp}/temp-susenas-`t'.dta", replace
}