	*----------------------------------------------------------------------*
	* REGIONAL DEFLATOR  -  PAASCHE
	*----------------------------------------------------------------------*
clear all
set trace off

forval t=2017/2023 {

    **# /* TO BE USED FOR MEASUREMENT - FOOD, FUEL, ENERGY, RENT - NATIONAL PRICE REFERENCE */
    
        use "${gdTemp}/temp-susenas-`t'.dta", clear        
        keep if inlist(ditem_all,"food","processed","tobacco","energy","fuel","rent")
        gen v_w = v if inlist(ditem_all,"food","processed","tobacco")
		replace uv_hh = prent if inlist(ditem_all,"rent")
        
        replace v = ((v_w/7)*365)/12 if inlist(ditem_all,"food","processed","tobacco")
        		
		*** unit values by levels
        // calculate weighted median
            collapse (median) uv_2=uv_hh v [w=popw], by(code ditem_all urban prov year)          // strata
        
    **# Tag komoditas 44
        merge m:1 code year using "${gdTemp}/weights-laspeyres-2017.dta", keepusing(v_all komoditas44)
        drop if komoditas44!=1 & inlist(ditem_all,"food","processed","tobacco")
        
        replace v = v_all if (komoditas44==1)

        /* weights by NATIONAL WEIGHTS */
        bys urban prov year: egen tv = total(v)
        gen sh_v = v/tv
      
        /* laspeyres deflator household level */
        gen sh_uv2 = uv_2*sh_v           // based on HH UV 

        save "${gdTemp}/price-k44-`t'", replace
    }
    
use "${gdTemp}/price-k44-2017.dta", clear
forval t=2018/2023 {
    append using "${gdTemp}/price-k44-`t'"
}    
save "${gdTemp}/price-k44-1723.dta", replace

use "${gdTemp}/price-k44-1723.dta", clear                         
sort prov urban code year
bys prov urban code: gen c_uv_2 = (uv_2[_n]-uv_2[_n-1])/uv_2[_n-1]
g pindex = sh_v*c_uv_2

collapse (sum) pindex, by(prov urban year) 
                    