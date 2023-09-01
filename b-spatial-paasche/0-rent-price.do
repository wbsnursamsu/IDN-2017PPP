

clear all
set trace on
	
forval t=2019/2021 {
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
        preserve
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
            
            predict prent
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
            collapse (median) rent_5=rent prent_5=prent [w=popw]                      // REF
            tempfile rent5
            save `rent5', replace 
        restore
        
        merge m:1 code urban prov rege using `rent1', nogen
        merge m:1 code urban prov using `rent2', nogen
        merge m:1 code prov using `rent3', nogen
        merge m:1 code urban using `rent4', nogen
        merge m:1 code using `rent5', nogen
        
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
        collapse (median) rent_pi prent_pi [w=popw], by(prov urban)
        
    * save
        save "${gdOutput}/rent-price-`t'.dta", replace
       
}     

use "${gdOutput}/rent-price-2019.dta", clear
gen year=2019
forval t=2020/2021 {
    append using "${gdOUtput}/rent-price`t'.dta"
    replace year=`t' if missing(year)
    }
save "${gdOutput}/rent-price-all.dta", replace
