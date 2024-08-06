

clear all
set trace off
// 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2015 2016 2017 2018 2019 2020 2021 2022 
foreach t in 2023 {      
    cap log close
    log using "${gdLog}/rent-reg-`t'.log", replace
      
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
}
            if `t'==2002 {
                outreg2 using "${gdOutput}/00-rent-regression.xlsx", ctitle(`t') excel replace                
            }
            else {
                outreg2 using "${gdOutput}/00-rent-regression.xlsx", ctitle(`t') excel append         
            }
}

foreach t in 2014 {        
    cap log close
    log using "${gdLog}/rent-reg-`t'.log", replace
 
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

            outreg2 using "${gdOutput}/00-rent-regression.xlsx", ctitle(`t') excel append  
}