	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*
clear all
set trace off

forval t=2002/2009 {

    **# /* TO BE USED - FOOD, FUEL, ENERGY, RENT */
    
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
            collapse (median) uv_5=uv_hh [w=popw], by(code)                     // national - REFERENCE
            tempfile uv5
            save `uv5', replace
        restore
      
        merge m:1 code urban prov rege using `uv1', nogen
        merge m:1 code urban prov using `uv2', nogen
        merge m:1 code prov using `uv3', nogen
        merge m:1 code urban using `uv4', nogen
        merge m:1 code using `uv5', nogen
                    
        // replace if missing UVs to higher stratification
        forval j=2/5 {
            replace uv_1 = uv_`j' if uv_1==.
            }
        forval j=1/5 {
            replace uv_hh = uv_`j' if uv_hh==.
            }
      
		// keeping only purchased food items at municipality, strata and national level 
		keep if uv_hh!=. & uv_1!=. & uv_5!=. 
		
		/* drop if  less than 5 items purchased, by municipality)*/
		egen fr = count(_n), by(code urban prov rege) 
		drop if fr<5 | fr==.		
		/* replacing  the outlier unit values - 5 times > or < than national unit value */
		replace uv_1 = uv_5  if (uv_1 > 5*uv_5 | uv_1 <uv_5/5)  
      
        /* weights by household */
        bys hhid: egen t_v = total(v)
        gen sh_v = v/t_v
      
        /* paache deflator household level */
        gen sh_uvhh = (uv_5/uv_hh)*sh_v           // based on HH UV 
      
		collapse (sum) sh_uvhh (mean) popw [weight = popw], by(hhid prov rege urban) 
      
        gen pdef = 1/sh_uvhh
      
        la var pdef "Paasche spatial index HH level with HH UV"
        gen year=`t'
        
		***!!! SAVE !!!***
		compress 
		save "${gdOutput}/spdef-med-hh-`t'-0.dta", replace

    }