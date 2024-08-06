

clear all
set trace off

foreach t in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2015 2016 2017 2018 2019 2020 2021 2022 2023 {        
    use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
    keep if inlist(ditem_all,"rent")            // rent only for rent price index 
    drop if provcode==77
    
    * match with hh susenas data (from SUSENAS Pipeline)
        merge m:1 urut provcode kabcode using "${gdSush}/sus-hh-mar-`t'.dta", keepusing(electricity sanitation water gas house_own house_rent house_offcert house_area roof wall floor elec_type sani_type disp_type house_stat roof_type wall_type floor_type1) nogen
    
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
    
    * monthly rent
        g rent = v 
		g lrent = ln(rent)
		
    * predicted rent
        preserve
            expand 2, gen(id)
            g areacode = prov*100 + rege
            
            replace rent = . if id==1
            replace house_area=30 if id==1
            replace elec_type=1 if id==1
            replace sani_type=1 if id==1
            replace disp_type=1 if id==1
            replace roof_type=1 if id==1
            replace wall_type=1 if id==1
            replace floor_type1=1 if id==1
            
            reg lrent house_area i.elec_type i.sani_type i.disp_type ///
                i.roof_type i.wall_type i.floor_type1 i.areacode i.urban [w=popw], ro 

			predict plrent
			gen prent = exp(plrent)     
			su prent
			
            drop if id==0
            keep urut prov rege kode prent
            
            tempfile predrent
            save `predrent', replace
        restore 
        
        merge 1:1 urut prov rege kode using `predrent', nogen
        
    * housing ownership status
        g hstat = 1 if inlist(q,1,4) 
            replace hstat = 2 if inlist(q,2,3)
            replace hstat = 3 if inlist(q,5,6)        
        la def hstat 1 "Own" 2 "Rent" 3 "Others"
        la val hstat hstat
        
    * save for deflator !!
		drop if missing(urut)
		duplicates drop urut kode, force
        save "${gdTemp}/rent-predict-`t'-3.dta", replace

    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
   
    * replace rent to higher aggregation (rent is monthly)
        preserve 
            collapse (median) rent_1=rent prent_1=prent [w=popw], by(urban prov rege) // regency
            tempfile rent1
            save `rent1', replace
        restore, preserve 
            collapse (median) rent_2=rent prent_2=prent [w=popw], by(urban prov)      // strata
            tempfile rent2
            save `rent2', replace
        restore, preserve
            collapse (median) rent_3=rent prent_3=prent [w=popw], by(prov)            // province
            tempfile rent3
            save `rent3', replace
        restore, preserve
            collapse (median) rent_4=rent prent_4=prent [w=popw], by(urban)           // urban
            tempfile rent4
            save `rent4', replace
        restore, preserve 
            collapse (median) rent_5=rent prent_5=prent [w=popw], by(year)            // REF
            tempfile rent5
            save `rent5', replace 
        restore
       
        merge m:1 urban prov rege using `rent1', nogen
        merge m:1 urban prov using `rent2', nogen
        merge m:1 prov using `rent3', nogen
        merge m:1 urban using `rent4', nogen
        merge m:1 year using `rent5', nogen
       
        forval j=1/5 {
            replace rent = rent_`j' if rent==.
            replace prent = prent_`j' if prent==.
        }
       
        gen rent_nat = rent_5 // national or ref rent price 
        gen prent_nat = prent_5 // national or ref rent price
       
    * generate price index
        g rent_pi  = rent/rent_nat * q
        g prent_pi = prent/prent_nat * q
       
    * collapse to prov urban
        collapse (median) rent_pi prent_pi [w=popw], by(year prov urban)
       
    * save
        save "${gdOutput}/rent-price-`t'-3.dta", replace
   
    }     

foreach t in 2013 2014 {        
    log using "${gdLog}/rent-`t'.dta", replace
 
    use "${gdCons}/sus-cm-pool-`t'-full.dta", clear
    keep if inlist(ditem_all,"rent")            // rent only for rent price index 
    drop if provcode==77
 
    * match with hh susenas data (from SUSENAS Pipeline)
        merge m:1 urut provcode kabcode using "${gdSush}/sus-hh-pool-`t'.dta", keepusing(electricity sanitation water gas house_own house_rent house_offcert house_area roof wall floor elec_type sani_type disp_type house_stat roof_type wall_type floor_type1) nogen
 
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
 
    * monthly rent
        g rent = v 
		g lrent = ln(rent)		
 
    * predicted rent
        preserve
            expand 2, gen(id)
            g areacode = prov*100 + rege
         
            replace rent = . if id==1
            replace house_area=30 if id==1
            replace elec_type=1 if id==1
            replace sani_type=1 if id==1
            replace disp_type=1 if id==1
            replace roof_type=1 if id==1
            replace wall_type=1 if id==1
            replace floor_type1=1 if id==1
         
            reg lrent house_area i.elec_type i.sani_type i.disp_type ///
                i.roof_type i.wall_type i.floor_type1 i.areacode i.urban [w=popw], ro 
                         
			predict plrent
			gen prent = exp(plrent)     
			su prent

            drop if id==0
            keep urut prov rege kode prent
         
            tempfile predrent
            save `predrent', replace
        restore 
     
        merge 1:1 urut prov rege kode using `predrent', nogen
     
    * housing ownership status
        g hstat = 1 if inlist(q,1,4) 
            replace hstat = 2 if inlist(q,2,3)
            replace hstat = 3 if inlist(q,5,6)        
        la def hstat 1 "Own" 2 "Rent" 3 "Others"
        la val hstat hstat
     
    * save for deflator !! 
		drop if missing(urut)
		duplicates drop urut kode, force	
        save "${gdTemp}/rent-predict-`t'-3.dta", replace
     
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
 
    * replace rent to higher aggregation (rent is monthly)
        preserve 
            collapse (median) rent_1=rent prent_1=prent [w=popw], by(urban prov rege) // regency
            tempfile rent1
            save `rent1', replace
        restore, preserve 
            collapse (median) rent_2=rent prent_2=prent [w=popw], by(urban prov)      // strata
            tempfile rent2
            save `rent2', replace
        restore, preserve
            collapse (median) rent_3=rent prent_3=prent [w=popw], by(prov)            // province
            tempfile rent3
            save `rent3', replace
        restore, preserve
            collapse (median) rent_4=rent prent_4=prent [w=popw], by(urban)           // urban
            tempfile rent4
            save `rent4', replace
        restore, preserve 
            collapse (median) rent_5=rent prent_5=prent [w=popw], by(year)            // REF
            tempfile rent5
            save `rent5', replace 
        restore
     
        merge m:1 urban prov rege using `rent1', nogen
        merge m:1 urban prov using `rent2', nogen
        merge m:1 prov using `rent3', nogen
        merge m:1 urban using `rent4', nogen
        merge m:1 year using `rent5', nogen
     
        forval j=1/5 {
            replace rent = rent_`j' if rent==.
            replace prent = prent_`j' if prent==.
        }
     
        gen rent_nat = rent_5 // national or ref rent price 
        gen prent_nat = prent_5 // national or ref rent price
     
    * generate price index
        g rent_pi  = rent/rent_nat * q
        g prent_pi = prent/prent_nat * q
     
    * collapse to prov urban
        collapse (median) rent_pi prent_pi [w=popw], by(year prov urban)
     
    * save
        save "${gdOutput}/rent-price-`t'-3.dta", replace
 
    log close
    }     
	
use "${gdOutput}/rent-price-2002-3.dta", clear
forval t=2003/2023 {
    append using "${gdOutput}/rent-price-`t'-3.dta"
    }

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
sort year prov provname provcode urban rent_pi prent_pi
order year prov provname provcode urban rent_pi prent_pi

save "${gdOutput}/rent-price-all-3.dta", replace
export excel using "${gdOutput}/rent-price-all-3.xls", firstrow(variables) replace

beep