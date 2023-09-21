
* exppl data
    use "${gdExpp}/exppl-laspeyres.dta", clear
    keep if inlist(year,2015,2016,2017,2018,2019,2020,2021)
    drop cpi* icp* alpha* lasp_* food_defl_* y_pcexp* rpcexp_ppp* poor_I* PA_periods
    merge m:1 year using "${gdData}/CPI/CPI International Povrate - Reno 2017ppp.dta", keepusing(cpi2011 cpi2017 icp11rural icp11urban icp17rural icp17urban)
        drop if _merge==2
        drop _merge
    
    // merge with spatial deflator
    rename provcode prov
    rename kabcode rege
//     merge m:1 year prov urban using "${gdOutput}/spatial-index-stratum-2.dta"
//         drop if _merge==2
//         drop _merge
    merge m:1 year prov rege urban using "${gdOutput}/spatial-index-regency-2.dta"
        drop if _merge==2
        drop _merge
        
    gen ppp17 = icp17rural
        replace ppp17 = icp17urban if urban==1 
    
    gen ppp11 = icp11rural
        replace ppp11 = icp11urban if urban==1
    
    gen rdpcexp_ppp2011 = (pcexp*12/365)/ppp11/(cpi2011/100)
    gen rdpcexp_ppp2017 = (pcexp*12/365)/ppp17/(cpi2017/100)

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
 
* original pov rate
    gen poor_npl = pcexp<povline
    gen poor_ipl215 = (rdpcexp_ppp2017)<2.15       // LIC
    gen poor_ipl365 = (rdpcexp_ppp2017)<3.65       // LMIC
    gen poor_ipl685 = (rdpcexp_ppp2017)<6.85       // UMIC
    
* spatially adjusted pov rate
    
    // regency
    gen poor_ipl215_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<2.15   // LIC - Combined HH & Price survey    
    gen poor_ipl365_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<3.65   // LMIC - Combined HH & Price survey
    gen poor_ipl685_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<6.85   // UMIC - Combined HH & Price survey    

* label variables
    la var poor_npl "NPL"
    la var poor_ipl215 "IPL 2.15 - Nominal"
    la var poor_ipl365 "IPL 3.65 - Nominal"
    la var poor_ipl685 "IPL 6.85 - Nominal"
    la var poor_ipl215_reg3 "IPL 2.15 - Spatially deflated by regency - combined" 
    la var poor_ipl365_reg3 "IPL 3.65 - Spatially deflated by regency - combined" 
    la var poor_ipl685_reg3 "IPL 6.85 - Spatially deflated by regency - combined" 
    
save "${gdOutput}/1-index-povrate-temp-2015-2021.dta", replace    
    
* tables
    #delimit;
        table () (year) [w=int(weind)], stat(mean poor_npl 
        poor_ipl215 poor_ipl365 poor_ipl685 poor_ipl215_reg3 poor_ipl365_reg3 poor_ipl685_reg3) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-output-2015-2021.xlsx", sheet("all_index", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==1, stat(mean poor_npl 
        poor_ipl215 poor_ipl365 poor_ipl685 poor_ipl215_reg3 poor_ipl365_reg3 poor_ipl685_reg3) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-output-2015-2021.xlsx", sheet("all_index_urb", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==0, stat(mean poor_npl 
        poor_ipl215 poor_ipl365 poor_ipl685 poor_ipl215_reg3 poor_ipl365_reg3 poor_ipl685_reg3) 
        nformat(%6.4f);
    #delimit cr    
    collect preview
    putexcel set "${gdOutput}/1-output-2015-2021.xlsx", sheet("all_index_rur", replace) modify
    putexcel B2 = collect
    