
    // address region code change first

use "${gdCrsw}/crosswalk-kabupaten-unique-2023.dta", clear
keep year bps_code_all bps_code prov kab
drop prov kab
greshape wide bps_code ,i(bps_code_all) j(year)
rename bps_code1998 code2000
rename bps_code1999 code2001
rename bps_code_all code_all
drop bps_code1993-bps_code1997
replace bps_code2000=code2000
replace bps_code2001=code2001
greshape long bps_code, i(code_all code2000 code2001) j(year)
destring bps_code code_all code2000 code2001 year, replace
duplicates drop
drop if bps_code==.
drop if code2000==. & year==2001
drop if code_all==3101 & bps_code==3175 & year==2001
drop if code_all==3101 & bps_code==3175 & year==2000

tempfile regcrs
save `regcrs', replace
    
    // add 2000 and 2001 deflator using average of 2002-2007 deflator

use "${gdOutput}/02-spdef-rgc-2002-2023-fix.dta", clear
expand 2 if year==2002, gen(a)
replace year=2000 if a==1
drop a
expand 2 if year==2002, gen(a)
replace year=2001 if a==1
drop a
replace pdef=. if inlist(year,2000,2001)
fillin prov rege year
drop _fillin 

gen bps_code = prov*100 + rege
merge m:1 bps_code year using `regcrs'
drop if _merge==2
drop _merge

gen a = 1 if inrange(year,2002,2007)        
sort code_all year
by code_all: egen adef= mean(pdef) if a==1
by code_all: egen max = max(adef)
replace pdef = max if inlist(year,2000,2001)

tostring bps_code prov rege, replace 
replace prov = substr(bps_code,1,2) if inlist(year,2000,2001)
replace rege = substr(bps_code,3,2) if inlist(year,2000,2001)
destring bps_code prov rege, replace 

sort prov rege year
by prov rege: replace pdef=(pdef[_n-1]+pdef[_n+1])/2 if pdef==. & prov==71 & rege==71 & year==2006 // add 2006 index to Manado 

drop if missing(pdef)
drop a adef max

drop if year==2013
tempfile pdef0023
save `pdef0023', replace 

    // 2013 deflator using province
    
use "${gdOutput}/02-spdef-prv-2002-2023-fix.dta", clear
keep if year==2013
rename pdef pdef13
tempfile pdef13
save `pdef13', replace
    
    // exppl data
    
    use "${gdExpp}/0-exppl-merged-2000-2023.dta", clear
    merge m:1 year using "${gdData}/CPI/CPI International Povrate - add2023.dta", keepusing(cpi2011 cpi2017 icp11 icp11rural icp11urban icp17 icp17rural icp17urban)
        drop if _merge==2
        drop _merge
    
    // urban to national deflator adjustment for 2011 and 2017
    merge m:1 year using "${gdOutput}/02-udef-2002-2023.dta", nogen
    
    // adjust regency code difference, mostly for year 2014 
    replace kabcode = 3 if provcode==16 & kabcode==12 & year==2014
    replace kabcode = 1 if provcode==18 & kabcode==13 & year==2014
    replace kabcode = 7 if provcode==32 & kabcode==18 & year==2014
    replace kabcode = 6 if provcode==53 & kabcode==21 & year==2014
    replace kabcode = 2 if provcode==64 & kabcode==11 & year==2014
    replace kabcode = 4 if provcode==74 & kabcode==11 & year==2014
    replace kabcode = 3 if provcode==82 & kabcode==8  & year==2014
    
    // merge with spatial deflator
    rename provcode prov
    rename kabcode rege
    merge m:1 year prov using `pdef13', nogen     // 2013 use province
    merge m:1 year prov rege using `pdef0023'     // regency deflator
        drop if _merge==2
        drop _merge
    replace pdef=pdef13 if year==2013
    drop pdef13
    
    gen ppp17n = icp17urban if urban==1
        replace ppp17n = icp17rural if urban==0
    gen ppp11n = icp11urban if urban==1
        replace ppp11n = icp11rural if urban==0
    
    gen ppp17d = icp17
    gen ppp11d = icp11
    
    gen npcexp = (pcexp*12/365)/pdef
    gen npcexp_u = npcexp*udef
    gen rnpcexp_u = npcexp_u/(cpi2017/100)
    gen rnpcexp_nat = rnpcexp_u/udef2017
    gen rnpcexp_nat_ppp = rnpcexp_nat/ppp17d
    
    gen rdpcexp_ppp2017_n = (pcexp*12/365)/ppp17n/(cpi2017/100)
    gen rdpcexp_ppp2011_n = (pcexp*12/365)/ppp11n/(cpi2011/100)
    
//     gen rdpcexp_ppp2017_d = (pcexp*12/365)/ppp17d/(cpi2017/100)
//     gen rdpcexp_ppp2011_d = (pcexp*12/365)/ppp11d/(cpi2011/100)
 
* original pov rate
    gen poor_npl = pcexp<povline
    gen poor_ipl215 = (rdpcexp_ppp2017_n)<2.15       // LIC = 2017 PPP
    gen poor_ipl365 = (rdpcexp_ppp2017_n)<3.65       // LMIC = 2017 PPP
    gen poor_ipl685 = (rdpcexp_ppp2017_n)<6.85       // UMIC = 2017 PPP
	
	gen poor_ipl19 = (rdpcexp_ppp2011_n)<1.9			// LIC - 2011 PPP
	gen poor_ipl32 = (rdpcexp_ppp2011_n)<3.2			// LMIC - 2011 PPP
	gen poor_ipl55 = (rdpcexp_ppp2011_n)<5.5			// UMIC - 2011 PPP
    
* spatially adjusted pov rate and adjust using base year urban deflator    

    gen poor_ipl215_d = rnpcexp_nat_ppp<2.15
    gen poor_ipl365_d = rnpcexp_nat_ppp<3.65
    gen poor_ipl685_d = rnpcexp_nat_ppp<6.85

//     gen poor_ipl19_d = ((rdpcexp_ppp2011_d*udef)/pdef/udef2011)<1.9
//     gen poor_ipl32_d = ((rdpcexp_ppp2011_d*udef)/pdef/udef2011)<3.2
//     gen poor_ipl55_d = ((rdpcexp_ppp2011_d*udef)/pdef/udef2011)<5.5    
    

* label variables
    la var poor_npl 		"NPL"
    la var poor_ipl215 		"IPL 2.15- Nominal"
    la var poor_ipl365 		"IPL 3.65- Nominal"
    la var poor_ipl685 		"IPL 6.85- Nominal"
	la var poor_ipl19 		"IPL 1.9 - Nominal"
	la var poor_ipl32 		"IPL 3.2 - Nominal"
	la var poor_ipl55 		"IPL 5.5 - Nominal"
	la var poor_ipl215_d    "IPL 2.15- Deflated"
	la var poor_ipl365_d    "IPL 3.65- Deflated"
	la var poor_ipl685_d    "IPL 6.85- Deflated"
	la var poor_ipl19_d     "IPL 1.9 - Deflated"
	la var poor_ipl32_d     "IPL 3.2 - Deflated"
	la var poor_ipl55_d     "IPL 5.5 - Deflated" 
    
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

* Add some island-group category
gen region = .
tostring provcode, replace
replace region = 1 if substr(provcode,1,1) == "1" | substr(provcode,1,1) == "2"
replace region = 2 if substr(provcode,1,1) == "3" | substr(provcode,1,2) == "51"
replace region = 3 if substr(provcode,1,2) == "52" | substr(provcode,1,2) == "53"
replace region = 4 if substr(provcode,1,1) == "6"
replace region = 5 if substr(provcode,1,1) == "7"
replace region = 6 if substr(provcode,1,1) == "8" | substr(provcode,1,1) == "9"
destring provcode, replace
	
label define region 0 "National" 1 "Sumatera" 2 "Jawa-Bali" 3 "Nusa Tenggara" 4 "Kalimantan" 5 "Sulawesi" 6 "Maluku-Papua"
label values region region
gen region2 = .
replace region2 = 1 if region == 6
replace region2 = 2 if region == 3
replace region2 = 3 if !inlist(region,3,6)
label define region2 1 "Maluku-Papua" 2 "Nusa Tenggara" 3 "Rest of Indonesia"
label values region2 region2
    
save "${gdOutput}/10-povrate-2000-2023-fix.dta", replace    

// * tables
    #delimit;
        table () (year) [w=int(weind)], stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        ) 
        nformat(%6.4f);
    #delimit cr
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", sheet("all_index", replace) modify

    #delimit;
        table () (year) [w=int(weind)] if urban==1, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        )
        nformat(%6.4f);
    #delimit cr
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", sheet("all_index_urb", replace) modify

    #delimit;
        table () (year) [w=int(weind)] if urban==0, stat(mean poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        )
        nformat(%6.4f);
    #delimit cr    
    collect preview
    collect export "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", sheet("all_index_rur", replace) modify
   
* save data and graph
    // national level
    * national
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(year);
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("national", replace);        
		
    #delimit cr
    restore
   
    * urban rural
    preserve
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(year urban);
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("urbanrural", replace);
       
    #delimit cr 
    restore
  
    // island region level
    preserve
    #delimit;
        collapse (mean) poor_npl
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(year region urban);           
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("region", replace);        
    #delimit cr
    restore

    // island region no urban rural level
    preserve
    #delimit;
        collapse (mean) poor_npl
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(year region);           
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("reg_all", replace);        
    #delimit cr
    restore
    
    // province level
    preserve 
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(prov provname year);
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("province", replace);
    #delimit cr 
    restore
       
    // province urban (stratum) level
    preserve 
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(prov provname urban year);
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("stratum", replace);
    #delimit cr
    restore
       
    // regency level
    preserve 
    #delimit;
        collapse (mean) poor_npl 
        poor_ipl215 poor_ipl215_d poor_ipl365 poor_ipl365_d poor_ipl685 poor_ipl685_d 
        poor_ipl19 poor_ipl19_d poor_ipl32 poor_ipl32_d poor_ipl55 poor_ipl55_d
        [w=weind], by(prov provname rege year);
        export excel using "${gdOutput}/1-povrate-sum-2000-2023-fix.xlsx", firstrow(variables) sheet("regency", replace);
    #delimit cr    
    restore
