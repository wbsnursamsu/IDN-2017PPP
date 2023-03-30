********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Poverty Line Reconstruction & Asset Index
*	Subtask			: Merging HH Aggregate Expenditure data to Spatial Laspeyres
*	Input			: -
*	Note			: -
********************************************************************************
	
***** COMBINING DATASETS - EXPENDITURE *****************************************

*** Extracting SUSENAS total consumption from each years and making HH Identifier
* urut: HH identifier	

**# Bookmark #1

foreach i in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
	di "Loading SUSENAS `i' "
	* IF condition due to different filename pattern of exppl. See raw data folder
	* for more information
	if `i' >= 11 {
		local fname "exppl`i'mar.dta"
	}
	else {
		local fname "exppl`i'.dta"
	}
	use "$gdData/Exppl/`fname'", clear
	* Create HH Identifier (urut)
	if inlist(`i',02,03,04,05,06,07,08,09,10,11) {
		egen urut = concat(b1r1 b1r2 b1r3 b1r4 b1r5 b1r7 b1r8)
	}
	else if `i' == 12 {
		drop urut
		egen urut = concat(b1r1-b1r8), format(%14.0f) 
		preserve
			use "$gdData/SUSENAS/Data/MODULE/susenas12mar_43.dta", clear
			egen urut = concat(b1r1-b1r8), format(%14.0f) 
			tempfile temp
			save `temp'
		restore
		merge 1:1 urut using `temp', keepusing(food nfood b2r1)
		gen hhsize = b2r1
	}
	else if `i' == 13 {
		format urut %14.0f
		egen i = concat(urut b1r1-b1r8), format(%14.0f) 
		drop urut
		rename i urut
	}
	else if `i' == 14 {
		replace urut = strtrim(urut)
	}
	else if `i' == 15 {
		preserve
			use "$gdData/SUSENAS/Data/MODULE/susenas15mar_43.dta", clear
			tempfile temp
			save `temp'
		restore
		merge 1:1 urut using `temp', keepusing(food nfood r301 r101 r102 r105)
		gen hhsize = r301
	}
	else if `i' == 17 {
		rename renum urut
	}
	else if `i' == 20 {
		rename nonfood nfood
		rename r301 hhsize
	}
	tostring urut, replace
	* Province code, kabupaten (district) code and urban dummy
	* For year 2014, kabupaten code needs to be extracted from HH identifier
	if `i' < 15 {
		rename b1r1 provcode
		gen urban = b1r5 == 1
		if `i' == 13 {
			gen kabcode = .
		}
		else if `i' == 14 {
			destring urut, gen(y)
			gen z = y/(10^11)
			replace z=floor(z)
			tostring z, replace
			replace z = substr(z,3,2)
			destring z, replace
			rename z kabcode
		}
		else {
			rename b1r2 kabcode
		}
	}
	else if `i' < 23 {
		rename r101 provcode
		gen urban = r105 == 1
		rename r102 kabcode
		if `i' == 22 {
			rename r301 hhsize
		}
	}
	
	gen year = 2000 + `i'
	keep year provcode kabcode urban urut food nfood hhsize pcexp wert weind povline 
	tempfile exp`i'
	save `exp`i''
}

**** Merge all annual data & Add some identifiers
use `exp02', clear
foreach i in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
	di "Appending `i'"
	preserve 
		use `exp`i'', clear
		isid urut year
	restore
	append using `exp`i'', force
}


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
merge m:1 year using "$gdData/CPI/CPI International Povrate - Reno 2017ppp.dta"
drop _merge

save "$gdTemp/susenas-combine-2002-2022.dta", replace	
    
**** Merge with new spatial deflator 
use "$gdOutput/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
tostring provcode_urban, replace
gen provcode = substr(provcode_urban,1,2)
gen urban = (substr(provcode_urban,3,2) == "01")
destring provcode, replace
drop provcode_urban
rename index lasp_avgnatU_v5
tempfile provur01
save `provur01'

use "$gdTemp/susenas-combine-2002-2022.dta", clear
merge m:1 provcode urban year using `provur01'
drop if _merge == 1
drop _merge
save "$gdOutput/Exppl - Laspeyres Merged 2002-2022.dta", replace
	