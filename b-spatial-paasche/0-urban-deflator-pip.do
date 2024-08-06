	*----------------------------------------------------------------------*
	* URBAN DEFLATOR  FOR 2011 AND 2017 -  PAASCHE
	*----------------------------------------------------------------------*
clear all
set trace off

foreach t of numlist 2011 2017 {

    **# /* TO BE USED FOR MEASUREMENT - FOOD, FUEL, ENERGY, RENT - URBAN PRICE REFERENCE */
    
        use "${gdTemp}/temp-susenas-`t'.dta", clear        
        keep if inlist(ditem_all,"food","processed","tobacco","energy","fuel","rent")
		replace uv_hh = prent if inlist(ditem_all,"rent")
        		
        fillin code urban prov rege
		drop _fillin
		
		*** unit values by levels
        // calculate weighted median
        preserve
            collapse (median) uv_1=uv_hh [w=popw], by(code urban prov rege)     // regency
            tempfile uv1
            save `uv1', replace
        restore, preserve
            collapse (median) uv_2=uv_hh [w=popw], by(code urban prov)          // strata
            tempfile uv2
            save `uv2', replace
        restore, preserve
            collapse (median) uv_3=uv_hh [w=popw], by(code prov)                // province
            tempfile uv3
            save `uv3', replace
        restore, preserve
            collapse (median) uv_4=uv_hh [w=popw], by(code urban)               // urban rural
            tempfile uv4
            save `uv4', replace
        restore, preserve
            collapse (median) uv_5=uv_hh [w=popw], by(code)                     // NATIONAL - REFERENCE PRICE
            tempfile uv5
            save `uv5', replace
        restore
      
        merge m:1 code urban prov rege using `uv1', nogen
        merge m:1 code urban prov using `uv2', nogen
        merge m:1 code prov using `uv3', nogen
        merge m:1 code urban using `uv4', nogen
        merge m:1 code using `uv5', nogen
                    
        // replace if missing UVs to higher stratification
        forval j=1/5 {
            replace uv_hh = uv_`j' if uv_hh==.
            }
        
		// keeping only purchased food items at municipality, strata and national level 
		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov rege) 
		drop if fr<5 | fr==.	
      
        /* weights by household */
        bys hhid: egen t_v = total(v)
        gen sh_v = v/t_v
      
        /* paasche deflator household level */
        gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
      
		collapse (sum) sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
      
        gen pdef = 1/sh_uvhh
      
        la var pdef "Paasche spatial index HH level with HH UV"
        gen year=`t'
        
        /* Urban Rural deflator */
        collapse (median) pdef [weight = popw] , by(urban year)

		***!!! SAVE !!!***
		compress 
		save "${gdTemp}/0-urban-deflator-`t'-pip.dta", replace
    }
    
use "${gdTemp}/0-urban-deflator-2011-pip.dta", clear
append using "${gdTemp}/0-urban-deflator-2017-pip.dta"
greshape wide pdef, i(urban) j(year)
drop if urban==0
rename urban id
rename pdef2011 udef2011
rename pdef2017 udef2017
save "${gdOutput}/0-urban-deflator-pip.dta", replace 