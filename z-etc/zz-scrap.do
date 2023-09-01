		/* Item price index for a household */
		gen    pi_hh = (uv_nat/uv_str) * qpurch                     
		keep if pi_hh !=. & qpurch !=.
       
        keep hhid urban prov muni popw code qpurch epurch uv_hh uv_mun uv_str uv_reg uv_urb uv_nat fr pi_hh
      
		collapse (sum) pi_hh qpurch (mean) popw [weight = popw], by(hhid prov muni urban) 

		/* deflator in hh level */
        gen pach_def = qpurch/pi_hh 		     
		drop if pach_def==0 | pach_def==. 
        la var pach_def "Paache spatial index HH level"
       
        /* save hh level index if needed */ 
        compress
        save "${gdTemp}/spatial-paache-`t'-wrent.dta", replace
       
        /* stratum (province urban) */
        preserve
            collapse (median) pach_def_str=pach_def [weight = popw] , by(prov urban) 
            replace pach_def_str=1 if pach_def_str ==.
            la var pach_def_str "Paache spatial index stratum level"

            table prov urban , stat(mean pach_def_str)            
            sort prov urban	

            compress
            save "${gdOutput}/paache-deflator-str-`t'-wrent.dta", replace
        restore

        
    //** predicted rent **//
        g pred_v = v
            replace pred_v = . if inlist(hstat,1,3)

            

        // identifier for median loop
        tostring code urban prov rege, replace
        gen id1 = prov+rege+urban+code      // regency
        gen id2 = prov+urban+code           // strata
        gen id3 = prov+code                 // province
        gen id4 = urban+code                // urban rural
        gen id5 = code                      // national - REFERENCE
        destring code urban prov rege, replace
        
        forval i=1/5 {
            encode id`i', gen(ids`i')
            qui su ids`i'
            local m`i' = r(max)
            drop id`i'
            }
        
        // calculate weighted median
        forval i=1/5 {
            gen uv_`i'=.
            forval j=1/`m`i'' {
                qui su uv_hh [w=popw] if id`i'=="`j'", detail
                replace uv_`i' = r(p50) if id`i'=="`j'"
                }
            }
