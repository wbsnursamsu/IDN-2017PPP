********************************************************************************
*	Project			: Poverty Line Analysis
*   Task            : Final spatial deflator adjustment 2000 - 2023 
********************************************************************************

    // address region code change first

use "${gdCrsw}/crosswalk-kabupaten-unique-2023.dta", clear
keep year bps_code_all bps_code prov kab
drop prov kab
greshape wide bps_code ,i(bps_code_all) j(year)
rename bps_code1998 code2000
rename bps_code1999 code2001
rename bps_code_all code_all
drop bps_code1993-bps_code1997
replace bps_code2000=code2000
replace bps_code2001=code2001
greshape long bps_code, i(code_all code2000 code2001) j(year)
destring bps_code code_all code2000 code2001 year, replace
duplicates drop
drop if bps_code==.
drop if code2000==. & year==2001
drop if code_all==3101 & bps_code==3175 & year==2001
drop if code_all==3101 & bps_code==3175 & year==2000

tempfile regcrs
save `regcrs', replace
    
    // add 2000 and 2001 deflator using average of 2002-2007 deflator

use "${gdOutput}/02-spdef-rgc-2002-2023-pip.dta", clear
expand 2 if year==2002, gen(a)
replace year=2000 if a==1
drop a
expand 2 if year==2002, gen(a)
replace year=2001 if a==1
drop a
replace pdef=. if inlist(year,2000,2001)
fillin prov rege year
drop _fillin 

gen bps_code = prov*100 + rege
merge m:1 bps_code year using `regcrs'
drop if _merge==2
drop _merge

gen a = 1 if inrange(year,2002,2007)        
sort code_all year
by code_all: egen adef= mean(pdef) if a==1
by code_all: egen max = max(adef)
replace pdef = max if inlist(year,2000,2001)

tostring bps_code prov rege, replace 
replace prov = substr(bps_code,1,2) if inlist(year,2000,2001)
replace rege = substr(bps_code,3,2) if inlist(year,2000,2001)
destring bps_code prov rege, replace 

sort prov rege year
by prov rege: replace pdef=(pdef[_n-1]+pdef[_n+1])/2 if pdef==. & prov==71 & rege==71 & year==2006 // add 2006 index to Manado 

drop if missing(pdef)
drop a adef max

drop if year==2013
tempfile pdef0023
save `pdef0023', replace 

    // 2013 deflator using province
    
use "${gdOutput}/02-spdef-prv-2002-2023-pip.dta", clear
keep if year==2013
rename pdef pdef13
tempfile pdef13
save `pdef13', replace
    
use `pdef0023', clear
merge m:1 prov year using `pdef13', nogen
replace pdef=pdef13 if year==2013 

// urban to national deflator adjustment for 2011 and 2017
gen id = 1
merge m:1 id using "${gdOutput}/0-urban-deflator-pip.dta"
drop id _merge

gen pdef2011 = pdef*udef2011
gen pdef2017 = pdef*udef2017
    
save "${gdOutput}/0-spatial-index-final.dta", replace