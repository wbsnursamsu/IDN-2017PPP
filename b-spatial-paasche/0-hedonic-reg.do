clear all
set trace off
	
forval t=2019/2021 {        
    log using "${gdLog}/rent-reg-`t'.dta", replace
    
    use "${gdCons}/sus-cm-mar-`t'-full.dta", clear
    keep if inlist(ditem_all,"rent")            // rent only for rent price index 
    drop if provcode==77
    
    * match with hh susenas data (from SUSENAS Pipeline)
        merge m:1 urut provcode kabcode using "${gdSush}/sus-hh-mar-`t'.dta", keepusing(electricity sanitation water gas house_own house_rent house_offcert house_area roof wall floor elec_type sani_type disp_type house_stat hcert_type roof_type wall_type floor_type) nogen
    
    g hhid = urut
    g prov = provcode
    g rege = kabcode
    g popw = wert
    
    * monthly rent
        g rent = v 
    
    * predicted rent
        expand 2, gen(id)
        g areacode = prov*10000 + rege*100 + urban
        
        replace rent = . if id==1
        replace house_area=30 if id==1
        replace elec_type=1 if id==1
        replace sani_type=1 if id==1
        replace disp_type=1 if id==1
        replace hcert_type=1 if id==1
        replace roof_type=1 if id==1
        replace wall_type=1 if id==1
        replace floor_type=1 if id==1
        
        reg rent house_area i.elec_type i.sani_type i.disp_type ///
            i.hcert_type i.roof_type i.wall_type i.floor_type i.areacode [w=popw], ro 
        
        if `t'==2019 {
            outreg2 using "${gdTemp}/hedonic-reg.xls", excel ctitle("area-`t'") replace 
            }
        else {
            outreg2 using "${gdTemp}/hedonic-reg.xls", excel ctitle("area-`t'") append
            } 
        
        reg rent house_area i.elec_type i.sani_type i.disp_type ///
            i.hcert_type i.roof_type i.wall_type i.floor_type i.provcode i.urban [w=popw], ro 
        
        outreg2 using "${gdTemp}/hedonic-reg.xls", excel ctitle("prov-`t'") append   
    log close
    }