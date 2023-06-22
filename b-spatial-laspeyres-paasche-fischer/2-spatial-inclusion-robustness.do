********************************************************************************
***                                                                          ***
***     Spatial Deflator - Laspeyres - Paasche - Fischer                     ***
***     2. Inclusion criteria for robustness                                 ***
***         1. Drop commodities if only consumed below xx% of total HH       ***
***             in one of the areas                                          ***
***         2. Drop if the share is below xx% of share of total cons         ***
***         3. Use larger aggregate value if included commodities is         ***
***            missing in the region                                         ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close
log using "${gdLog}/b-0-2-spatial-inclusion-robustness.txt", replace

********************************************************************************

*** SET THRESHOLD HERE
** HH consumption share threshold (default 0.16% ~ 0.0016)
local thousehold = 0.0016

** Transaction threshold (default 0.1% ~ 0.001)
local ttrans = 0.001

********************************************************************************

foreach t in 02 06 10 14 18 22 {
    use "${gdOutput}/SUS_Mod`t'.dta", clear

    *** 1. Check minimum share of household consuming a certain commodity in every areas (province urban - rural)

    * Generate price count in province UR
    preserve
        gen p1 = v/q
        collapse (count) count_p1 = p1, by(provcode urban kode)
        tempfile c_p1
        save `c_p1', replace
    restore
    
 	* Creating a minimum share of household need to consume the item for each area
	by urut, sort: generate obs = _n
	keep if obs==1
	keep provcode urban obs
	collapse (count) obs, by(provcode urban)

	sort provcode urban
	merge 1:m  provcode urban using `c_p1'
	drop _merge
    bys kode: gen share_geo = count_p1/obs
    bys kode: egen min_share_geo = min(share_geo)
    
    * Include only commodities consumed by minimum xx% of household in every areas
    gen inclusion_geo = min_share_geo>=`thousehold'
    
    keep kode min_share_geo inclusion_geo
    duplicates drop
	save "${gdTemp}/2-1-inclusion-hh-`t'.dta", replace    
    
    *** 2. Share of specific item to total food expenditure (minimum 1% at national level)
    
    use "${gdOutput}/SUS_Mod`t'.dta", clear
    
    * create share of item consumption per total consumption at national level
    collapse (sum) v [fw=int(wert)], by(kode)
    gen t_v = sum(v)
    gen sh_v = v/t_v

    * include only commodities with share minimum xx% of national consumption
    gen inclusion_trans = sh_v>=`ttrans'
    
    keep kode sh_v inclusion_trans
    duplicates drop
    save "${gdTemp}/2-1-inclusion-trans-`t'.dta", replace
    
    *** 3. Merge commodities inclusion criteria
    use "${gdTemp}/2-1-inclusion-hh-`t'.dta", replace
    merge 1:1 kode using "${gdTemp}/2-1-inclusion-trans-`t'.dta", nogen
    gen inclusion_all = inlist(1,inclusion_geo,inclusion_trans)
    
    keep kode inclusion_geo inclusion_trans inclusion_all
    save "${gdOutput}/2-1-spatial-inclusion-all-`t'.dta", replace
}

