
* exppl data
    use "${gdExpp}/exppl-laspeyres.dta", clear
    keep if inrange(year,2010,2022)
    drop cpi* icp* alpha* lasp_* food_defl_* y_pcexp* rpcexp_ppp* poor_I* PA_periods
    merge m:1 year using "${gdData}/CPI/CPI International Povrate - Reno 2017ppp.dta", keepusing(cpi2011 cpi2017 icp11 icp11rural icp11urban icp17 icp17rural icp17urban)
        drop if _merge==2
        drop _merge
    
    // merge with spatial deflator
    rename provcode prov
    rename kabcode rege
    merge m:1 year prov rege using "${gdOutput}/02-spdef-rgc-2010-2022.dta"     // regency deflator
        drop if _merge==2
        drop _merge
    rename pdef0 pdef0R
    rename pdef1 pdef1R
    rename pdef2 pdef2R    
    rename pdef3 pdef3R        
    rename pdef4 pdef4R
    rename pdef5 pdef5R
    
    merge m:1 year prov urban using "${gdOutput}/02-spdef-str-2010-2022.dta"    // stratum level
		drop if _merge==2 
		drop _merge
    rename pdef0 pdef0S
    rename pdef1 pdef1S
    rename pdef2 pdef2S    
    rename pdef3 pdef3S        
    rename pdef5 pdef5S
    rename pdef4 pdef4S

    merge m:1 year prov using "${gdOutput}/02-spdef-prv-2010-2022.dta"          // province level
		drop if _merge==2 
		drop _merge
    rename pdef0 pdef0P
    rename pdef1 pdef1P
    rename pdef2 pdef2P    
    rename pdef3 pdef3P        
    rename pdef5 pdef5P
    rename pdef4 pdef4P
    
    forval t=0/5 {
        gen pdef`t'A = pdef`t'R
        replace pdef`t'A = pdef`t'S if missing(pdef`t'A)
        replace pdef`t'A = pdef`t'P if missing(pdef`t'A)        
        }
    
    gen ppp17 = icp17
    gen ppp11 = icp11
    
    gen rdpcexp_ppp2011 = (pcexp*12/365)/ppp11/(cpi2011/100)
    gen rdpcexp_ppp2017 = (pcexp*12/365)/ppp17/(cpi2017/100)
 
* original pov rate
    gen poor_npl = pcexp<povline
    gen poor_ipl215 = (rdpcexp_ppp2017)<2.15       // LIC = 2017 PPP
    gen poor_ipl365 = (rdpcexp_ppp2017)<3.65       // LMIC = 2017 PPP
    gen poor_ipl685 = (rdpcexp_ppp2017)<6.85       // UMIC = 2017 PPP
	
	gen poor_ipl19 = (rdpcexp_ppp2011)<1.9			// LIC - 2011 PPP
	gen poor_ipl32 = (rdpcexp_ppp2011)<3.2			// LMIC - 2011 PPP
	gen poor_ipl55 = (rdpcexp_ppp2011)<5.5			// UMIC - 2011 PPP
    
* spatially adjusted pov rate    

forval t=0/5 {
    gen poor_ipl215_d`t' = (rdpcexp_ppp2017/pdef`t'A)<2.15
    gen poor_ipl365_d`t' = (rdpcexp_ppp2017/pdef`t'A)<3.65
    gen poor_ipl685_d`t' = (rdpcexp_ppp2017/pdef`t'A)<6.85
	
    gen poor_ipl19_d`t' = (rdpcexp_ppp2011/pdef`t'A)<1.9
    gen poor_ipl32_d`t' = (rdpcexp_ppp2011/pdef`t'A)<3.2
    gen poor_ipl55_d`t' = (rdpcexp_ppp2011/pdef`t'A)<5.5    
    }
    

* label variables
    la var poor_npl 		"NPL"
    la var poor_ipl215 		"IPL 2.15- Nominal"
    la var poor_ipl365 		"IPL 3.65- Nominal"
    la var poor_ipl685 		"IPL 6.85- Nominal"
	la var poor_ipl19 		"IPL 1.9 - Nominal"
	la var poor_ipl32 		"IPL 3.2 - Nominal"
	la var poor_ipl55 		"IPL 5.5 - Nominal"
	la var poor_ipl215_d0   "IPL 2.15- Defl - Food EFuel Rent"
	la var poor_ipl365_d0   "IPL 3.65- Defl - Food EFuel Rent"
	la var poor_ipl685_d0   "IPL 6.85- Defl - Food EFuel Rent"
	la var poor_ipl19_d0    "IPL 1.9 - Defl - Food EFuel Rent"
	la var poor_ipl32_d0    "IPL 3.2 - Defl - Food EFuel Rent"
	la var poor_ipl55_d0    "IPL 5.5 - Defl - Food EFuel Rent"
	la var poor_ipl215_d1   "IPL 2.15- Defl - Food EFuel NFood Rent"
	la var poor_ipl365_d1   "IPL 3.65- Defl - Food EFuel NFood Rent"    
	la var poor_ipl685_d1   "IPL 6.85- Defl - Food EFuel NFood Rent"    
	la var poor_ipl19_d1    "IPL 1.9 - Defl - Food EFuel NFood Rent"    
	la var poor_ipl32_d1    "IPL 3.2 - Defl - Food EFuel NFood Rent"    
	la var poor_ipl55_d1    "IPL 5.5 - Defl - Food EFuel NFood Rent"    
	la var poor_ipl215_d2   "IPL 2.15- Defl - Food EFuel NFood"
	la var poor_ipl365_d2   "IPL 3.65- Defl - Food EFuel NFood"     
	la var poor_ipl685_d2   "IPL 6.85- Defl - Food EFuel NFood"     
	la var poor_ipl19_d2    "IPL 1.9 - Defl - Food EFuel NFood"     
	la var poor_ipl32_d2    "IPL 3.2 - Defl - Food EFuel NFood"     
	la var poor_ipl55_d2    "IPL 5.5 - Defl - Food EFuel NFood"     
	la var poor_ipl215_d3   "IPL 2.15- Defl - Food EFuel"    
	la var poor_ipl365_d3   "IPL 3.65- Defl - Food EFuel"    
	la var poor_ipl685_d3   "IPL 6.85- Defl - Food EFuel"    
	la var poor_ipl19_d3    "IPL 1.9 - Defl - Food EFuel"    
	la var poor_ipl32_d3    "IPL 3.2 - Defl - Food EFuel"	
	la var poor_ipl55_d3    "IPL 5.5 - Defl - Food EFuel"
	la var poor_ipl215_d4   "IPL 2.15- Defl - NFood"    
	la var poor_ipl365_d4   "IPL 3.65- Defl - NFood"    
	la var poor_ipl685_d4   "IPL 6.85- Defl - NFood"    
	la var poor_ipl19_d4    "IPL 1.9 - Defl - NFood"    
	la var poor_ipl32_d4    "IPL 3.2 - Defl - NFood"	
	la var poor_ipl55_d4    "IPL 5.5 - Defl - NFood"
	la var poor_ipl215_d5   "IPL 2.15- Defl - Rent"    
	la var poor_ipl365_d5   "IPL 3.65- Defl - Rent"    
	la var poor_ipl685_d5   "IPL 6.85- Defl - Rent"    
	la var poor_ipl19_d5    "IPL 1.9 - Defl - Rent"    
	la var poor_ipl32_d5    "IPL 3.2 - Defl - Rent"    
	la var poor_ipl55_d5    "IPL 5.5 - Defl - Rent"    
    
    
* region code
gen provname = "Nanggroe Aceh Darussalam" if prov==11
    replace provname = "Nanggroe Aceh Darussalam"       if prov==11	
    replace provname = "Sumatera Utara"                 if prov==12	
    replace provname = "Sumatera Barat"                 if prov==13	
    replace provname = "Riau"                           if prov==14	
    replace provname = "Jambi"                          if prov==15	
    replace provname = "Sumatera Selatan"               if prov==16	
    replace provname = "Bengkulu"                       if prov==17	
    replace provname = "Lampung"                        if prov==18	
    replace provname = "Kep. Bangka Belitung"           if prov==19	
    replace provname = "Kep. Riau"                      if prov==21	
    replace provname = "DKI Jakarta"                    if prov==31	
    replace provname = "Jawa Barat"                     if prov==32	
    replace provname = "Jawa Tengah"                    if prov==33	
    replace provname = "DI Yogyakarta"                  if prov==34	
    replace provname = "Jawa Timur"                     if prov==35	
    replace provname = "Banten"                         if prov==36	
    replace provname = "Bali"                           if prov==51	
    replace provname = "Nusa Tenggara Barat"            if prov==52	
    replace provname = "Nusa Tenggara Timur"            if prov==53	
    replace provname = "Kalimantan Barat"               if prov==61	
    replace provname = "Kalimantan Tengah"              if prov==62	
    replace provname = "Kalimantan Selatan"             if prov==63	
    replace provname = "Kalimantan Timur"               if prov==64	
    replace provname = "Kalimantan Utara"               if prov==65 
    replace provname = "Sulawesi Utara"                 if prov==71	
    replace provname = "Sulawesi Tengah"                if prov==72	
    replace provname = "Sulawesi Selatan"               if prov==73	
    replace provname = "Sulawesi Tenggara"              if prov==74	
    replace provname = "Gorontalo"                      if prov==75	
    replace provname = "Sulawesi Barat"                 if prov==76	
    replace provname = "Maluku"                         if prov==81	
    replace provname = "Maluku Utara"                   if prov==82	
    replace provname = "Papua Barat"                    if prov==91	
    replace provname = "Papua"                          if prov==94	

tostring prov, replace    
gen provcode = prov+" "+provname 
destring prov, replace 
    
save "${gdOutput}/10-povrate-2010-2022.dta", replace    

// * tables
    #delimit;
        table () (year) [w=int(weind)], stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
		poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
		poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
		poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
		poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
		poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        ) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2010-2022.xlsx", sheet("all_index", replace) modify

    #delimit;
        table () (year) [w=int(weind)] if urban==1, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
		poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
		poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
		poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
		poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
		poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        )
        nformat(%6.4f);
    #delimit cr
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2010-2022.xlsx", sheet("all_index_urb", replace) modify

    #delimit;
        table () (year) [w=int(weind)] if urban==0, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
		poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
		poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
		poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
		poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
		poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        )
        nformat(%6.4f);
    #delimit cr    
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2010-2022.xlsx", sheet("all_index_rur", replace) modify
   
* save data and graph
    // national level
    * national
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
		poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
		poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
		poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
		poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
		poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        [w=weind], by(year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("national", replace);        
		
    #delimit cr
    restore
   
    * urban rural
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
		poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
		poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
		poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
		poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
		poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        [w=weind], by(year urban);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("urbanrural", replace);
       
    #delimit cr 
    restore
   
    // island region level
    preserve
    #delimit;
        collapse (mean) 
            poor_npl
            poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
            poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
            poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
            poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
            poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
            poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        [w=weind], by(year region urban);           
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("region", replace);        
    #delimit cr
    restore
   
    // province level
    preserve 
    #delimit;
        collapse (mean)
			poor_npl 
            poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
            poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
            poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
            poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
            poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
            poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
        [w=weind], by(prov provname year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("province", replace);
    #delimit cr 
    restore
       
    // province urban (stratum) level
    preserve 
    #delimit;
        collapse (mean) 
			poor_npl 
            poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
            poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
            poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
            poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
            poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
            poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
            [w=weind], by(prov provname urban year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("stratum", replace);
    #delimit cr
    restore
       
    // regency level
    preserve 
    #delimit;
        collapse (mean) 
			poor_npl 
            poor_ipl215 poor_ipl215_d0 poor_ipl215_d1 poor_ipl215_d2 poor_ipl215_d3 poor_ipl215_d4 poor_ipl215_d5
            poor_ipl365 poor_ipl365_d0 poor_ipl365_d1 poor_ipl365_d2 poor_ipl365_d3 poor_ipl365_d4 poor_ipl365_d5
            poor_ipl685 poor_ipl685_d0 poor_ipl685_d1 poor_ipl685_d2 poor_ipl685_d3 poor_ipl685_d4 poor_ipl685_d5
            poor_ipl19 poor_ipl19_d0 poor_ipl19_d1 poor_ipl19_d2 poor_ipl19_d3 poor_ipl19_d4 poor_ipl19_d5 
            poor_ipl32 poor_ipl32_d0 poor_ipl32_d1 poor_ipl32_d2 poor_ipl32_d3 poor_ipl32_d4 poor_ipl32_d5
            poor_ipl55 poor_ipl55_d0 poor_ipl55_d1 poor_ipl55_d2 poor_ipl55_d3 poor_ipl55_d4 poor_ipl55_d5
            [w=weind], by(prov provname rege year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022.xlsx", firstrow(variables) sheet("regency", replace);
    #delimit cr    
    restore
