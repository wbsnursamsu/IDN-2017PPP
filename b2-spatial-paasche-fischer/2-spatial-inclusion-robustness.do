********************************************************************************
***                                                                          ***
***     Spatial Deflator - Laspeyres - Paasche - Fischer                     ***
***     2. Inclusion criteria for robustness                                 ***
***         1. Drop if the share is below xx% of share of total cons         ***
***         2. Drop commodities if only consumed below xx% of total HH       ***
***         3. Use larger aggregate value if included commodities is         ***
***            missing in the region                                         ***
***                                                                          ***
********************************************************************************

clear 
set more off
cap log close

********************************************************************************

*** SET THRESHOLD HERE
** Consumption share threshold (default 0.1% ~ 0.001)
local tshare = 0.001

** Transaction threshold (default 0.1% ~ 0.001)
local ttrans = 0.001

********************************************************************************

foreach t in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
    use "${gdOutput}/SUS_Mod`t'.dta", clear

    *** 1. Check whether items consumed all years by nat urban rural (share is 0 - 1)
    ***     a. Inclusion error of share depends on the average share over years

    * Generate price count in province UR
    preserve
        gen p1 = v/q
        collapse (count) count_p1 = p1, by(provcode urban kode)
        tempfile c_p1
        save `c_p1', replace
    restore
    
 	* Creatine a minimum share of household need to consume the item for each geographic area
	by urut, sort: generate obs = _n
	keep if obs==1
	keep provcode urban obs
	collapse (count) obs, by(provcode urban)

	sort provcode urban
	merge 1:m  provcode urban using `c_p1'
	drop _merge
    bys kode: gen share_geo = count_p1/obs*100
    replace share_geo = 0 if share_geo==.
    reshape wide share_geo count_p1 obs, i(kode) j(provcode urban)
    gen inclusion_geo_u = share_geo 
    
	tempfile in1
	save `in1', replace    
    
    
}

