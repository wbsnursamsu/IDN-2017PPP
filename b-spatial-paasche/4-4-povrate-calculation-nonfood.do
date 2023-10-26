
* exppl data
    use "${gdExpp}/exppl-laspeyres.dta", clear
    keep if inrange(year,2010,2022)
    drop cpi* icp* alpha* lasp_* food_defl_* y_pcexp* rpcexp_ppp* poor_I* PA_periods
    merge m:1 year using "${gdData}/CPI/CPI International Povrate - Reno 2017ppp.dta", keepusing(cpi2011 cpi2017 icp11rural icp11urban icp17rural icp17urban)
        drop if _merge==2
        drop _merge
    
    // merge with spatial deflator
    rename provcode prov
    rename kabcode rege
    merge m:1 year prov rege using "${gdOutput}/spdef-med-reg-ps-2010-2022.dta"
        drop if _merge==2
        drop _merge
    
    preserve
		keep if year==2013
		drop pdef
		merge m:1 year prov urban using "${gdOutput}/spdef-med-str-ps-2010-2022.dta"
		drop if _merge==2 
		drop _merge
		tempfile dat2013
		save `dat2013', replace
	restore 
	
	drop if year==2013
	append using `dat2013'
	
    gen ppp17 = icp17rural
        replace ppp17 = icp17urban if urban==1 
    
    gen ppp11 = icp11rural
        replace ppp11 = icp11urban if urban==1
    
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
    // regency
    gen poor_defl_ipl215 = (rdpcexp_ppp2017/pdef)<2.15
    gen poor_defl_ipl365 = (rdpcexp_ppp2017/pdef)<3.65
    gen poor_defl_ipl685 = (rdpcexp_ppp2017/pdef)<6.85
	
    gen poor_defl_ipl19 = (rdpcexp_ppp2011/pdef)<1.9
    gen poor_defl_ipl32 = (rdpcexp_ppp2011/pdef)<3.2
    gen poor_defl_ipl55 = (rdpcexp_ppp2011/pdef)<5.5

* label variables
    la var poor_npl 		"NPL"
    la var poor_ipl215 		"IPL 2.15 - Standard"
    la var poor_ipl365 		"IPL 3.65 - Standard"
    la var poor_ipl685 		"IPL 6.85 - Standard"
	la var poor_ipl19 		"IPL 1.9 - Standard"
	la var poor_ipl32 		"IPL 3.2 - Standard"
	la var poor_ipl55 		"IPL 5.5 - Standard"
	la var poor_defl_ipl215 "IPL 2.15 - Deflated"
	la var poor_defl_ipl365 "IPL 3.65 - Deflated"
	la var poor_defl_ipl685 "IPL 6.85 - Deflated"
	la var poor_defl_ipl19  "IPL 1.9 - Deflated"
	la var poor_defl_ipl32  "IPL 3.2 - Deflated"
	la var poor_defl_ipl55  "IPL 5.5 - Deflated"
	
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
    
save "${gdOutput}/1-povrate-index-2010-2022-ps.dta", replace    
    
* tables
    #delimit;
        table () (year) [w=int(weind)], stat(mean poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", sheet("all_index", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==1, stat(mean poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", sheet("all_index_urb", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==0, stat(mean poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55) 
        nformat(%6.4f);
    #delimit cr    
    collect preview
    putexcel set "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", sheet("all_index_rur", replace) modify
    putexcel B2 = collect
    
* save data and graph
    // national level
    * national
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55 [w=weind], by(year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("national", replace);        
		
    #delimit cr
    restore
    
    * urban rural
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55 [w=weind], by(year urban);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("urbanrural", replace);
        
    #delimit cr 
    restore
    
    // island region level
    preserve
    #delimit;
        collapse (mean) 
			poor_npl 
			poor_ipl215 poor_defl_ipl215 
			poor_ipl365 poor_defl_ipl365 
			poor_ipl685 poor_defl_ipl685
			poor_ipl19 poor_defl_ipl19
			poor_ipl32 poor_defl_ipl32
			poor_ipl55 poor_defl_ipl55 
			[w=weind], by(year region urban);
            
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("region", replace);        
    #delimit cr
    restore
    
    // province level
    preserve 
    #delimit;
        collapse (mean)
			poor_npl 
			poor_ipl215 poor_defl_ipl215 
			poor_ipl365 poor_defl_ipl365 
			poor_ipl685 poor_defl_ipl685
			poor_ipl19 poor_defl_ipl19
			poor_ipl32 poor_defl_ipl32
			poor_ipl55 poor_defl_ipl55 
            [w=weind], by(prov provname year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("province", replace);
    #delimit cr 
    restore
        
    // province urban (stratum) level
    preserve 
    #delimit;
        collapse (mean) 
			poor_npl 
			poor_ipl215 poor_defl_ipl215 
			poor_ipl365 poor_defl_ipl365 
			poor_ipl685 poor_defl_ipl685
			poor_ipl19 poor_defl_ipl19
			poor_ipl32 poor_defl_ipl32
			poor_ipl55 poor_defl_ipl55 
            [w=weind], by(prov provname urban year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("stratum", replace);
    #delimit cr
    restore
        
    // regency level
    preserve 
    #delimit;
        collapse (mean) 
			poor_npl 
			poor_ipl215 poor_defl_ipl215 
			poor_ipl365 poor_defl_ipl365 
			poor_ipl685 poor_defl_ipl685
			poor_ipl19 poor_defl_ipl19
			poor_ipl32 poor_defl_ipl32
			poor_ipl55 poor_defl_ipl55 
            [w=weind], by(prov provname rege year);
        export excel using "${gdOutput}/1-povrate-sum-2010-2022-ps.xlsx", firstrow(variables) sheet("regency", replace);
    #delimit cr    
    restore
