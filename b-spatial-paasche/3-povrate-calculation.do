
* exppl data
    use "${gdExpp}/exppl-laspeyres.dta", clear
    keep if inlist(year,2019,2020,2021)
    drop cpi* icp* alpha* lasp_* food_defl_* y_pcexp* rpcexp_ppp* poor_I* PA_periods
    merge m:1 year using "${gdData}/CPI/CPI International Povrate - Reno 2017ppp.dta", keepusing(cpi2011 cpi2017 icp11rural icp11urban icp17rural icp17urban)
        drop if _merge==2
        drop _merge
    
    // merge with spatial deflator
    rename provcode prov
    rename kabcode rege
    merge m:1 year prov urban using "${gdOutput}/spatial-index-stratum.dta"
        drop if _merge==2
        drop _merge
    merge m:1 year prov rege urban using "${gdOutput}/spatial-index-regency.dta"
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

* original pov rate
    gen poor_npl = pcexp<povline
    gen poor_ipl215 = (rdpcexp_ppp2017)<2.15       // LIC
    gen poor_ipl365 = (rdpcexp_ppp2017)<3.65       // LMIC
    gen poor_ipl685 = (rdpcexp_ppp2017)<6.85       // UMIC
    
* spatially adjusted pov rate
    // stratum
    gen poor_ipl215_str1 = (rdpcexp_ppp2017/pdef_re_fo_str)<2.15   // LIC - Food only
    gen poor_ipl215_str2 = (rdpcexp_ppp2017/pdef_re_ps_str)<2.15   // LIC - Price survey    
    gen poor_ipl215_str3 = (rdpcexp_ppp2017/pdef_re_mx_str)<2.15   // LIC - Combined HH & Price survey

    gen poor_ipl365_str1 = (rdpcexp_ppp2017/pdef_re_fo_str)<3.65   // LMIC - Food only
    gen poor_ipl365_str2 = (rdpcexp_ppp2017/pdef_re_ps_str)<3.65   // LMIC - Price survey    
    gen poor_ipl365_str3 = (rdpcexp_ppp2017/pdef_re_mx_str)<3.65   // LMIC - Combined HH & Price survey

    gen poor_ipl685_str1 = (rdpcexp_ppp2017/pdef_re_fo_str)<6.85   // UMIC - Food only
    gen poor_ipl685_str2 = (rdpcexp_ppp2017/pdef_re_ps_str)<6.85   // UMIC - Price survey    
    gen poor_ipl685_str3 = (rdpcexp_ppp2017/pdef_re_mx_str)<6.85   // UMIC - Combined HH & Price survey

    // regency
    gen poor_ipl215_reg1 = (rdpcexp_ppp2017/pdef_re_fo_reg)<2.15   // LIC - Food only
    gen poor_ipl215_reg2 = (rdpcexp_ppp2017/pdef_re_ps_reg)<2.15   // LIC - Price survey    
    gen poor_ipl215_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<2.15   // LIC - Combined HH & Price survey

    gen poor_ipl365_reg1 = (rdpcexp_ppp2017/pdef_re_fo_reg)<3.65   // LMIC - Food only
    gen poor_ipl365_reg2 = (rdpcexp_ppp2017/pdef_re_ps_reg)<3.65   // LMIC - Price survey    
    gen poor_ipl365_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<3.65   // LMIC - Combined HH & Price survey

    gen poor_ipl685_reg1 = (rdpcexp_ppp2017/pdef_re_fo_reg)<6.85   // UMIC - Food only
    gen poor_ipl685_reg2 = (rdpcexp_ppp2017/pdef_re_ps_reg)<6.85   // UMIC - Price survey    
    gen poor_ipl685_reg3 = (rdpcexp_ppp2017/pdef_re_mx_reg)<6.85   // UMIC - Combined HH & Price survey    
    
save "${gdOutput}/1-index-povrate-2019-2021.dta", replace    
    
* tables
    #delimit;
        table () (year) [w=int(weind)], stat(mean poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
        poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
        poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
        poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
        poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
        poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
        poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3) 
        nformat(%6.4f);
    collect label levels prov 
        11	"Nanggroe Aceh Darussalam"
        12	"Sumatera Utara"
        13	"Sumatera Barat"
        14	"Riau"
        15	"Jambi"
        16	"Sumatera Selatan"
        17	"Bengkulu"
        18	"Lampung"
        19	"Kep. Bangka Belitung"
        21	"Kep. Riau"
        31	"DKI Jakarta"
        32	"Jawa Barat"
        33	"Jawa Tengah"
        34	"DI Yogyakarta"
        35	"Jawa Timur"
        36	"Banten"
        51	"Bali"
        52	"Nusa Tenggara Barat"
        53	"Nusa Tenggara Timur"
        61	"Kalimantan Barat"
        62	"Kalimantan Tengah"
        63	"Kalimantan Selatan"
        64	"Kalimantan Timur"
        65  "Kalimantan Utara"
        71	"Sulawesi Utara"
        72	"Sulawesi Tengah"
        73	"Sulawesi Selatan"
        74	"Sulawesi Tenggara"
        75	"Gorontalo"
        76	"Sulawesi Barat"
        81	"Maluku"
        82	"Maluku Utara"
        91	"Papua Barat"
        94	"Papua" ;
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-output-2019-2021.xlsx", sheet("all_index", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==1, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
        poor_ipl365 poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
        poor_ipl685 poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3) 
        nformat(%6.4f);
    collect label levels prov 
        11	"Nanggroe Aceh Darussalam"
        12	"Sumatera Utara"
        13	"Sumatera Barat"
        14	"Riau"
        15	"Jambi"
        16	"Sumatera Selatan"
        17	"Bengkulu"
        18	"Lampung"
        19	"Kep. Bangka Belitung"
        21	"Kep. Riau"
        31	"DKI Jakarta"
        32	"Jawa Barat"
        33	"Jawa Tengah"
        34	"DI Yogyakarta"
        35	"Jawa Timur"
        36	"Banten"
        51	"Bali"
        52	"Nusa Tenggara Barat"
        53	"Nusa Tenggara Timur"
        61	"Kalimantan Barat"
        62	"Kalimantan Tengah"
        63	"Kalimantan Selatan"
        64	"Kalimantan Timur"
        65  "Kalimantan Utara"
        71	"Sulawesi Utara"
        72	"Sulawesi Tengah"
        73	"Sulawesi Selatan"
        74	"Sulawesi Tenggara"
        75	"Gorontalo"
        76	"Sulawesi Barat"
        81	"Maluku"
        82	"Maluku Utara"
        91	"Papua Barat"
        94	"Papua" ;
    #delimit cr
    collect preview
    putexcel set "${gdOutput}/1-output-2019-2021.xlsx", sheet("all_index_urb", replace) modify
    putexcel B2 = collect

    #delimit;
        table () (year) [w=int(weind)] if urban==0, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
        poor_ipl365 poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
        poor_ipl685 poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3) 
        nformat(%6.4f);
    collect label levels prov 
        11	"Nanggroe Aceh Darussalam"
        12	"Sumatera Utara"
        13	"Sumatera Barat"
        14	"Riau"
        15	"Jambi"
        16	"Sumatera Selatan"
        17	"Bengkulu"
        18	"Lampung"
        19	"Kep. Bangka Belitung"
        21	"Kep. Riau"
        31	"DKI Jakarta"
        32	"Jawa Barat"
        33	"Jawa Tengah"
        34	"DI Yogyakarta"
        35	"Jawa Timur"
        36	"Banten"
        51	"Bali"
        52	"Nusa Tenggara Barat"
        53	"Nusa Tenggara Timur"
        61	"Kalimantan Barat"
        62	"Kalimantan Tengah"
        63	"Kalimantan Selatan"
        64	"Kalimantan Timur"
        65  "Kalimantan Utara"
        71	"Sulawesi Utara"
        72	"Sulawesi Tengah"
        73	"Sulawesi Selatan"
        74	"Sulawesi Tenggara"
        75	"Gorontalo"
        76	"Sulawesi Barat"
        81	"Maluku"
        82	"Maluku Utara"
        91	"Papua Barat"
        94	"Papua" ;
    #delimit cr    
    collect preview
    putexcel set "${gdOutput}/1-output-2019-2021.xlsx", sheet("all_index_rur", replace) modify
    putexcel B2 = collect
    
//     table (prov year) () [w=int(weind)], stat(mean poor_npl poor_ipl215 poor_ipl215_str3 poor_ipl215_reg3 poor_ipl365 poor_ipl365_str3 poor_ipl365_reg3 poor_ipl685 poor_ipl685_str3 poor_ipl685_reg3) nformat(%6.4f)
//     table (prov year) () [w=int(weind)], stat(mean poor_npl poor_ipl215 poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 poor_ipl215_reg3) nformat(%6.4f)
//     table (prov year) () [w=int(weind)], stat(mean poor_npl poor_ipl365 poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 poor_ipl365_reg3) nformat(%6.4f)
//     table (prov year) () [w=int(weind)], stat(mean poor_npl poor_ipl685 poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 poor_ipl685_reg3) nformat(%6.4f)
    
    
* save data and graph
    // national level
    * national
    preserve
    #delimit;
        collapse (mean) poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
        poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
        poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
        poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
        poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
        poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
        poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3 [w=weind], by(year);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("national", replace);        
        twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_ipl215_reg3 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_ipl365_reg3 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_ipl685_reg3 year, lp(-) lcol(forest_green)), 
        title("NPL vs Standard vs Adjusted IPL - National") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP") 
               label(3 "IPL 2.15 USD 2017 PPP - Adjusted") 
               label(4 "IPL 3.65 USD 2017 PPP") 
               label(5 "IPL 3.65 USD 2017 PPP - Adjusted") 
               label(6 "IPL 6.85 USD 2017 PPP") 
               label(7 "IPL 6.85 USD 2017 PPP - Adjusted")) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-comparison-nat.png", replace;
    #delimit cr
    restore
    
    * urban rural
    preserve
    #delimit;
        collapse (mean) poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
        poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
        poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
        poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
        poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
        poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
        poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3 [w=weind], by(year urban);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("urbanrural", replace);
        
        twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_ipl215_reg3 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_ipl365_reg3 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_ipl685_reg3 year, lp(-) lcol(forest_green)) 
        if urban==1, 
        title("NPL vs Standard vs Adjusted IPL - National Urban") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP") 
               label(3 "IPL 2.15 USD 2017 PPP - Adjusted") 
               label(4 "IPL 3.65 USD 2017 PPP") 
               label(5 "IPL 3.65 USD 2017 PPP - Adjusted") 
               label(6 "IPL 6.85 USD 2017 PPP") 
               label(7 "IPL 6.85 USD 2017 PPP - Adjusted")) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-comparison-nat-urb.png", replace;
        
        twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_ipl215_reg3 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_ipl365_reg3 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_ipl685_reg3 year, lp(-) lcol(forest_green)) 
        if urban==0, 
        title("NPL vs Standard vs Adjusted IPL - National Rural") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP") 
               label(3 "IPL 2.15 USD 2017 PPP - Adjusted") 
               label(4 "IPL 3.65 USD 2017 PPP") 
               label(5 "IPL 3.65 USD 2017 PPP - Adjusted") 
               label(6 "IPL 6.85 USD 2017 PPP") 
               label(7 "IPL 6.85 USD 2017 PPP - Adjusted"))  
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-comparison-nat-rur.png", replace;
    #delimit cr 
    restore
    
    // island region level
    preserve
    #delimit;
        collapse (mean) 
            poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
            poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
            poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
            poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
            poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
            poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
            poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3 
            [w=weind], by(year region urban);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("region", replace);        

    * urban rural
        twoway 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_ipl215_reg3 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_ipl365_reg3 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_ipl685_reg3 year, lp(-) lcol(forest_green)) 
        if urban==1,
        by(region, scale(0.75) title("Standard vs Adjusted IPL - Urban - by Region") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level"))
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "IPL 2.15 USD 2017 PPP") 
               label(2 "IPL 2.15 USD 2017 PPP - Adjusted") 
               label(3 "IPL 3.65 USD 2017 PPP") 
               label(4 "IPL 3.65 USD 2017 PPP - Adjusted") 
               label(5 "IPL 6.85 USD 2017 PPP") 
               label(6 "IPL 6.85 USD 2017 PPP - Adjusted")
               size(small)) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-region-urb.png", replace;
        
        twoway 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_ipl215_reg3 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_ipl365_reg3 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_ipl685_reg3 year, lp(-) lcol(forest_green)) 
        if urban==0,
        by(region, scale(0.75) title("Standard vs Adjusted IPL - Rural - by Region") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level"))
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "IPL 2.15 USD 2017 PPP") 
               label(2 "IPL 2.15 USD 2017 PPP - Adjusted") 
               label(3 "IPL 3.65 USD 2017 PPP") 
               label(4 "IPL 3.65 USD 2017 PPP - Adjusted") 
               label(5 "IPL 6.85 USD 2017 PPP") 
               label(6 "IPL 6.85 USD 2017 PPP - Adjusted")
               size(small)) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-region-rur.png", replace;
    
    * method comparison
        * urban
        twoway 
        (line poor_ipl365 year, lp(l) lcol(red)) 
        (line poor_ipl365_reg1 year, lp(l) lcol(blue))
        (line poor_ipl365_reg2 year, lp(l) lcol(orange)) 
        (line poor_ipl365_reg3 year, lp(l) lcol(green)) 
        if urban==1,
        by(region, scale(0.75) title("Adjusted IPL Method Comparison - Urban - by Region")) 
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "IPL 3.65 USD 2017 PPP") 
               label(2 "IPL 3.65 USD 2017 PPP - Food Only UV") 
               label(3 "IPL 3.65 USD 2017 PPP - Food & Non-Food Price") 
               label(4 "IPL 3.65 USD 2017 PPP - Food UV & Non-Food Price") 
               size(small)) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-method-region-urb.png", replace;    
        
        * rural
        twoway 
        (line poor_ipl365 year, lp(l) lcol(red)) 
        (line poor_ipl365_reg1 year, lp(l) lcol(blue))
        (line poor_ipl365_reg2 year, lp(l) lcol(orange)) 
        (line poor_ipl365_reg3 year, lp(l) lcol(green)) 
        if urban==0,
        by(region, scale(0.75) title("Adjusted IPL Method Comparison - Urban - by Region")) 
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "IPL 3.65 USD 2017 PPP") 
               label(2 "IPL 3.65 USD 2017 PPP - Food Only UV") 
               label(3 "IPL 3.65 USD 2017 PPP - Food & Non-Food Price") 
               label(4 "IPL 3.65 USD 2017 PPP - Food UV & Non-Food Price") 
               size(small)) 
               xlabel(2019(1)2021) ylabel(0(0.1)0.7);
        graph export "${gdOutput}/Graphs2/1-povrate-method-region-rur.png", replace;    
    #delimit cr
    restore
    
    // province level
    preserve 
    #delimit;
        collapse (mean)
            poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
            poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
            poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
            poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
            poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
            poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
            poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3 
            [w=weind], by(prov provname year);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("province", replace);
    #delimit cr 
    restore
        
    // province urban (stratum) level
    preserve 
    #delimit;
        collapse (mean) poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
            poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
            poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
            poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
            poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
            poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
            poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3
            [w=weind], by(prov provname urban year);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("stratum", replace);
    #delimit cr
    restore
        
    // regency level
    preserve 
    #delimit;
        collapse (mean) poor_npl poor_ipl215 poor_ipl365 poor_ipl685 
            poor_ipl215_str1 poor_ipl215_str2 poor_ipl215_str3 
            poor_ipl215_reg1 poor_ipl215_reg2 poor_ipl215_reg3 
            poor_ipl365_str1 poor_ipl365_str2 poor_ipl365_str3 
            poor_ipl365_reg1 poor_ipl365_reg2 poor_ipl365_reg3 
            poor_ipl685_str1 poor_ipl685_str2 poor_ipl685_str3 
            poor_ipl685_reg1 poor_ipl685_reg2 poor_ipl685_reg3 
            [w=weind], by(prov provname rege year);
        export excel using "${gdOutput}/1-output-2019-2021.xlsx", firstrow(variables) sheet("regency", replace);
    #delimit cr    
    restore
