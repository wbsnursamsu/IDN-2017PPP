	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*
clear all
set trace off

forval t=2010/2022 {

    **# /* MIX HH IMPLICIT PRICE AND PRICE SURVEY WITH RENT PRICE */
    
        use "${gdTemp}/temp-susenas-`t'.dta", clear
        
        replace uv_hh = p_ps if !inlist(ditem_all,"food","processed","tobacco","energy","fuel")
		replace uv_hh = prent if inlist(ditem_all,"rent")
        
        fillin code urban prov rege
		drop _fillin
		
		*** unit values by levels (weighted mean)
		egen uv_1 = wtmean(uv_hh) , weight(popw) by (code urban prov rege)      // regency
		egen uv_2 = wtmean(uv_hh) , weight(popw) by (code urban prov)           // strata  
		egen uv_3 = wtmean(uv_hh), weight(popw) by (code prov) 	                // province
		egen uv_4 = wtmean(uv_hh), weight(popw) by (code urban)                 // urban rural
		egen uv_5 = wtmean(uv_hh), weight(popw) by (code)                       // national - REFERENCE
                    
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
		save "${gdOutput}/spdef-mean-hh-`t'-wr.dta", replace

    }