	*----------------------------------------------------------------------*
	* SETUP FOR SPATIAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*

clear all
set trace off
cap log close

    *=== MARCH DATA ===*
foreach t in 2010 2011 2012 2015 2016 2017 2018 2019 2020 2021 2022 {
	use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
   
    /* collapse to adjust with price survey and merge with price survey data */
    * set price data
    preserve
    keep if urban==1
	destring kode, replace
	
    * SHK
		rename kode code_c
        merge m:1 code_c using "${gdTemp}/shk-adjust-`t'.dta", nogen
        drop if urut == ""

    replace code_c = code_2 if !missing(code_2)
    rename code_c kode
	    
    tempfile dat1
    save `dat1', replace
    
    restore
	
    keep if urban==0
	destring kode, replace
	
    * SHKP
		rename kode code_c	
        merge m:1 code_c using "${gdTemp}/shkp-adjust-`t'.dta", nogen
        drop if urut == ""

    replace code_c = code_2 if !missing(code_2)
    rename code_c kode
	    
    append using `dat1'
	drop if missing(urut)

    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut year provcode kabcode urban kode ditem_all)
        merge m:1 provcode urban kode year using "${gdOutput}/price-data-spatial-2010-2022.dta", keepusing(p_g_*) nogen 
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
    
   /* rent price */
    merge 1:1 urut kode using "${gdTemp}/rent-predict-`t'-3.dta", nogen keepusing(rent prent hstat)
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
	use "${gdCons}/sus-cm-pool-`t'-full.dta", clear
  
    /* collapse to adjust with price survey and merge with price survey data */
    * set price data
    preserve
    keep if urban==1
	destring kode, replace
	
    * SHK
		rename kode code_c		
        merge m:1 code_c using "${gdTemp}/shk-adjust-`t'.dta", nogen
        drop if urut == ""

    replace code_c = code_2 if !missing(code_2)
    rename code_c kode
   
    tempfile dat1
    save `dat1', replace
   
    restore
	
    keep if urban==0
	destring kode, replace	
	
    * SHKP
		rename kode code_c
        merge m:1 code_c using "${gdTemp}/shkp-adjust-`t'.dta", nogen
        drop if urut == ""

    replace code_c = code_2 if !missing(code_2)
	rename code_c kode
   
    append using `dat1'
	drop if missing(urut)

    * collapse to adjust with price survey and merge with price survey data
        collapse (sum) q v c (mean) weind wert, by(urut year provcode kabcode urban kode ditem_all)
        merge m:1 provcode urban kode year using "${gdOutput}/price-data-spatial-2010-2022.dta", keepusing(p_g_*) nogen 
        keep if year==`t'
        duplicates drop urut kode, force 
        tostring kode, replace
		
   /* rent price */
    merge 1:1 urut kode using "${gdTemp}/rent-predict-`t'-3.dta", nogen keepusing(rent prent hstat)
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

beep