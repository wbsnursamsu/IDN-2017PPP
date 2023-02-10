********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Run the pipeline, only for SEPTEMBER 2012
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Clean 2012 September data 

cap confirm file "$gdTemp/SUS_Mod12-SEPTEMBER.dta"
if _rc != 0 {
	di "File for the year does not exist"
	do "$gdDo/Module Cleaner/2012-SEPTEMBER.do"
}
else {
	di "No action needed"		
}
	
**** Labeling all data and converting strings to numeric
use "$gdTemp/SUS_Mod12-SEPTEMBER.dta", clear
cap drop if kode == ""
cap drop if kode == .
isid urut kode
label variable year 		"SUSENAS year"
label variable provcode 	"BPS Province code from the SUSENAS year"
label variable urban	 	"Is Urban"
label variable kabcode  	"BPS Kabupaten code from the SUSENAS year"
label variable urut		 	"HH Identifier"
label variable mod		 	"SUSENAS module"
label variable kode			"Food item code, excluding composites"
label variable q			"Total quantity consumed (Last 1 week)"
label variable v			"Total values consumed (Last 1 week)"
label variable c			"Total calories (Last 1 week)"
label variable hhsize		"Household size"
label variable weind		"Individual weights (unique to HH)"
label variable wert 		"Household weights (unique to HH)"
cap erase "$gdTemp/SUS_Mod12-SEPTEMBER.dta.dta"
save "$gdOutput/SUS_Mod12-SEPTEMBER.dta.dta", replace 

**** Get the program (From Imam's do fie)
do "$gdDo/05-1-Laspeyres_Spatial_SUS_v5.do"
* Dump everything in the tempfile folder (the ado needs this)
cd "$gdTemp"
capture log close
log using "$gdLog/spatial_index_national_2012_sep_basep0_urban_v5.log", replace	
use "$gdTemp/SUS_Mod12-SEPTEMBER.dta", clear
keep if mod == 41
destring kode, replace
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(1) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) minshare(1) transactions(0.16) basep0var(urban) basep0val(1)
gen year = 2012
save "$gdTemp/Laspeyres Spatial 2012 September Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", replace
capture log close

**** Merge with EXPPL
use "$gdData/Exppl/exppl12sep.dta", clear
cap drop urut
egen urut = concat(b1r1-b1r8), format(%14.0f) 
preserve
	use "$gdData/SUSENAS/Data/MODULE/susenas12sep_43.dta", clear
	egen urut = concat(b1r1-b1r8), format(%14.0f) 
	tempfile temp
	save `temp'
	restore
merge 1:1 urut using `temp', keepusing(food nfood b2r1)
tostring urut, replace
rename b1r1 provcode
rename b1r2 kabcode
gen urban = b1r5 == 1
gen year = 2012
keep year provcode kabcode urban urut food nfood hhsize pcexp wert weind povline 
* Add some island-group category
gen region = .
tostring provcode, replace
replace region = 1 if substr(provcode,1,1) == "1" | substr(provcode,1,1) == "2"
replace region = 2 if substr(provcode,1,1) == "3" | substr(provcode,1,2) == "51"
replace region = 3 if substr(provcode,1,2) == "52" | substr(provcode,1,2) == "53"
replace region = 4 if substr(provcode,1,1) == "6"
replace region = 5 if substr(provcode,1,1) == "7"
replace region = 6 if substr(provcode,1,1) == "8" | substr(provcode,1,1) == "9"
destring provcode, replace
	
label define region 0 "National" 1 "Sumatera" 2 "Jawa-Bali" 3 "Nusa Tenggara" 4 "Kalimantan" 5 "Sulawesi" 6 "Maluku-Papua"
label values region region
gen region2 = .
replace region2 = 1 if region == 6
replace region2 = 2 if region == 3
replace region2 = 3 if !inlist(region,3,6)
label define region2 1 "Maluku-Papua" 2 "Nusa Tenggara" 3 "Rest of Indonesia"
label values region2 region2
merge m:1 year using "$gdData/CPI/CPI International Povrate - Reno.dta"
keep if _merge == 3
drop _merge

**** Merge with new spatial deflator 
preserve 
	use "$gdTemp/Laspeyres Spatial 2012 September Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
	tostring provcode_urban, replace
	gen provcode = substr(provcode_urban,1,2)
	gen urban = (substr(provcode_urban,3,2) == "01")
	destring provcode, replace
	drop provcode_urban
	rename index lasp_avgnatU_v5
	tempfile provur01
	save `provur01'
restore
merge m:1 provcode urban year using `provur01'
drop if _merge == 1
drop _merge
save "$gdOutput/Exppl - Laspeyres Merged 2012-SEPTEMBER.dta", replace
	
**** Calibration 
foreach ipl in 1.9 3.2 5.5 {
	use "$gdOutput/Exppl - Laspeyres Merged 2012-SEPTEMBER.dta", clear
	replace cpi2011 = cpi2011/100
	mat A = J(1,3,.)
	mat colnames A = "year" "alphaR" "alphaU"
	* Change this parameter `jumps' to increase/reduce precision. This will affect runtime
	local jumps = 0.0005 
	local counter = 1
	* Capture delete some temporarily generated variables
	foreach i in y_pcexp rpcexp_ppp poor_IPL y_pcexp_laspU rpcexp_ppp_laspU poor_IPL_laspU food_defl y_pcexp_fooddefl rpcexp_ppp_fooddefl poor_IPL_fooddefl {
		cap drop `i'
	}
	* Baseline (to match)
	gen y_pcexp = pcexp * 12
	gen rpcexp_ppp = .
	replace rpcexp_ppp = (y_pcexp/cpi2011/icp11rural/365) if urban == 0
	replace rpcexp_ppp = (y_pcexp/cpi2011/icp11urban/365) if urban == 1
	gen poor_IPL = rpcexp_ppp < `ipl'
	* Spatially adjusted, only deflating food consumption, initial value
	gen food_defl = food / lasp_avgnatU_v5
	gen y_pcexp_fooddefl = ((food_defl + nfood)/hhsize) * 12
	gen rpcexp_ppp_fooddefl = (y_pcexp_fooddefl/cpi2011/icp11/365)
	gen poor_IPL_fooddefl = rpcexp_ppp_fooddefl < `ipl'
	** CALIBRATE FOR P0 RATE BASED ON FOOD ONLY DEFLATION
	* Run the year loop
	foreach y in 2012 {
		foreach u in 0 1 {
			local initval = 1
			local a = `initval'
			sum poor_IPL [w=weind] if year == `y' & urban == `u'
			local pbase = round(r(mean),`jumps')
			di `pbase'
			sum poor_IPL_fooddefl [w=weind] if year == `y' & urban == `u'
			local pfooddefl = round(r(mean),`jumps')
			di `pfooddefl'
			while `pfooddefl' != `pbase' {
				di "Year `y'. Now running at alpha = `a'" 
				* Reconstructing food
					cap drop food_defl y_pcexp_fooddefl rpcexp_ppp_fooddefl poor_IPL_fooddefl
					gen food_defl = food / (lasp_avgnatU_v5 * `a')
					gen y_pcexp_fooddefl = ((food_defl + nfood)/hhsize) * 12
					gen rpcexp_ppp_fooddefl = (y_pcexp_fooddefl/cpi2011/icp11/365)
					gen poor_IPL_fooddefl = rpcexp_ppp_fooddefl < `ipl'
				if `pfooddefl' > `pbase' {
					local a = `a' - `jumps'
				}
				else if `pfooddefl' < `pbase' {
					local a = `a' + `jumps'
				}
				qui sum poor_IPL_fooddefl [w=weind] if year == `y' & urban == `u'
				local pfooddefl = round(r(mean),`jumps')
				local divergence = `pfooddefl' - `pbase'
				di "Divergence needs to be closed = `divergence'"
				if abs(`divergence') <= `jumps' {
					continue, break
				}
			}
			di "`a'"
			mat A[`counter',1] = `y'
			if `u' == 0 {
				mat A[`counter',2] = `a'
			}
			else if `u' == 1 {
				mat A[`counter',3] = `a'
			}
		}
		local counter = `counter' + 1
	}
mat list A
* Save the results
clear
svmat A, names(col)
save "$gdOutput/Spatial Laspeyres Calibrator - `ipl' USD PPP - Food Deflation - SEP 2012.dta", replace
}

**** Result Validation
use "$gdOutput/Exppl - Laspeyres Merged 2012-SEPTEMBER.dta", clear
replace cpi2011 = cpi2011/100
label define urban 0 "Rural" 1 "Urban"
label variable urban urban
drop if urut == ""
*** Data prep
* Merge
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 1.9 USD PPP - Food Deflation - SEP 2012.dta", nogen
rename (alphaR alphaU) (alphaR19F alphaU19F)
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 3.2 USD PPP - Food Deflation - SEP 2012.dta", nogen
rename (alphaR alphaU) (alphaR32F alphaU32F)
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 5.5 USD PPP - Food Deflation - SEP 2012.dta", nogen
rename (alphaR alphaU) (alphaR55F alphaU55F)
drop if inlist(year,2000,2001)
		
** National Poverty Rate
gen poor_NPL = pcexp < povline

** Baseline (to match)
gen y_pcexp = pcexp * 12
gen rpcexp_ppp = .
replace rpcexp_ppp = (y_pcexp/cpi2011/icp11rural/365) if urban == 0
replace rpcexp_ppp = (y_pcexp/cpi2011/icp11urban/365) if urban == 1
gen poor_IPL19 = rpcexp_ppp < 1.9
gen poor_IPL32 = rpcexp_ppp < 3.2
gen poor_IPL55 = rpcexp_ppp < 5.5
			
** Spatially adjusted (food cons aggregate only), mean price as baseline, calibrated to povcalnet rate
		
gen food_defl_19 = .
gen y_pcexp_fooddefl_19 = .
gen rpcexp_ppp_fooddefl_19 = .
			
* 1.9 PPP
replace food_defl_19 = food / (lasp_avgnatU_v5 * alphaR19F) if urban == 0
replace food_defl_19 = food / (lasp_avgnatU_v5 * alphaU19F) if urban == 1
replace y_pcexp_fooddefl_19 = ((food_defl_19 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_19 = (y_pcexp_fooddefl_19/cpi2011/icp11/365)
gen poor_IPL19_fooddefl = rpcexp_ppp_fooddefl_19 < 1.9
			
gen food_defl_32 = .
gen y_pcexp_fooddefl_32 = .
gen rpcexp_ppp_fooddefl_32 = .
		
* 3.2 PPP
replace food_defl_32 = food / (lasp_avgnatU_v5 * alphaR32F) if urban == 0
replace food_defl_32 = food / (lasp_avgnatU_v5 * alphaU32F) if urban == 1
replace y_pcexp_fooddefl_32 = ((food_defl_32 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_32 = (y_pcexp_fooddefl_32/cpi2011/icp11/365)
gen poor_IPL32_fooddefl = rpcexp_ppp_fooddefl_32 < 3.2
			
gen food_defl_55 = .
gen y_pcexp_fooddefl_55 = .
gen rpcexp_ppp_fooddefl_55 = .
			
* 5.5 PPP
replace food_defl_55 = food / (lasp_avgnatU_v5 * alphaR55F) if urban == 0
replace food_defl_55 = food / (lasp_avgnatU_v5 * alphaU55F) if urban == 1
replace y_pcexp_fooddefl_55 = ((food_defl_55 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_55 = (y_pcexp_fooddefl_55/cpi2011/icp11/365)
gen poor_IPL55_fooddefl = rpcexp_ppp_fooddefl_55 < 5.5

* Label variables
label variable region "Island region - 6"
label variable region2 "Island region - lagging regions"
label variable icp11 "2011 USD PPP Conversion Rate - National"
label variable icp11rural "2011 USD PPP Conversion Rate - Rural"
label variable icp11urban "2011 USD PPP Conversion Rate - Urban"
label variable icp11urban "2011 USD PPP Conversion Rate - Urban"
label variable alphaR19F "Calibrated rural food deflator - 1.9 USD PPP"
label variable alphaU19F "Calibrated urban food deflator - 1.9 USD PPP"
label variable alphaR32F "Calibrated rural food deflator - 3.2 USD PPP"
label variable alphaU32F "Calibrated urban food deflator - 3.2 USD PPP"
label variable alphaR55F "Calibrated rural food deflator - 5.5 USD PPP"
label variable alphaU55F "Calibrated urban food deflator - 5.5 USD PPP"
label variable poor_NPL "Poor (=1), at national poverty line"
label variable y_pcexp "Annual nominal percapita consumption (food + nonfood)"
label variable rpcexp_ppp "Real daily percapita consumption (t food + t nonfood), standard povcalnet method"
label variable rpcexp_ppp_fooddefl_19 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 1.9 USD PPP FGT0"
label variable rpcexp_ppp_fooddefl_32 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 3.2 USD PPP FGT0"
label variable rpcexp_ppp_fooddefl_55 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 5.5 USD PPP FGT0"
			
*** Save the dataset
compress
save "$gdOutput/FINAL - Exppl Spatially Adjusted - 2012-SEPTEMBER.dta", replace
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2012-SEPTEMBER.dta", clear