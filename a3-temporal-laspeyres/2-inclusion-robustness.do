********************************************************************************
***                                                                          ***
***     A3. Laspeyres Temporal                                               ***
***     2. Inclusion criteria for robustness                                 ***
***         1. Drop if the share is below xx% of share of total cons         ***
***         2. Check whether items consumed all years by nat urban rural     ***
***         3. Drop commodities if only consumed below xx% of total HH       ***
***                                                                          ***
********************************************************************************

clear 
set more off

*** Set unit price data for all year (p1)
use "${gdTemp}/1-susenas-consumption-consistent-item-all-year.dta", clear
keep year provcode urban urut persistentcat code_all q v weind wert 
gen p1 = v/q
save "${gdTemp}/2-0-p1-unit-price.dta", replace

*** Set unit price data for 2017 (p0)
use "${gdTemp}/1-susenas-consumption-consistent-item-2017.dta", clear
keep year provcode urban urut persistentcat code_all q v weind wert 
gen p0 = v/q
save "${gdTemp}/2-0-p0-unit-price.dta", replace

********************************************************************************

*** SET THRESHOLD HERE
** Consumption share threshold (default 1% ~ 0.01)
local tshare = 0.01

** Transaction threshold (default 1% ~ 0.01)
local ttrans = 0.01

********************************************************************************

*** 1. Check whether items consumed all years by nat urban rural (share is 0 - 1)
***     a. Inclusion error of share depends on the average share over years
use "${gdTemp}/2-0-p1-unit-price.dta", clear
replace v = 0 if v==.
collapse (sum) v, by(urban year code_all persistentcat)

** 1.1. For all items
preserve
    bys urban year: egen totalvalue = total(v)
    gen sh_v = v/totalvalue
    keep sh_v urban year code_all

    ** Define threshold based on average of all years.
    collapse (mean) sh_v, by(urban code_all)

    * >>>> Exclude below 1% share. Change 1% here if want to change threshold <<<<
    gen inclusionshare = (sh_v>=`tshare')

    di "Inclusion based on consumption share:"
    table (code_all) (urban), stat(mean inclusionshare)

    keep urban code_all inclusionshare
    save "${gdTemp}/2-1-inclusion-share.dta", replace
restore

** 1.2. For food only
preserve
    keep if persistentcat=="food"
    bys urban year: egen totalvalue = total(v)
    gen sh_v = v/totalvalue
    keep sh_v urban year code_all

    ** Define threshold based on average of all years.
    collapse (mean) sh_v, by(urban code_all)

    * >>>> Exclude below 1% share. Change 1% here if want to change threshold <<<<
    gen inclusionshare_food = (sh_v>=`tshare')

    di "Inclusion based on consumption share:"
    table (code_all) (urban), stat(mean inclusionshare_food)

    keep urban code_all inclusionshare_food
    save "${gdTemp}/2-1-inclusion-share-food.dta", replace
restore

** 1.3. For fuel + energy only
preserve
    keep if (persistentcat=="fuel" | persistentcat=="energy")
    bys urban year: egen totalvalue = total(v)
    gen sh_v = v/totalvalue
    keep sh_v urban year code_all

    ** Define threshold based on average of all years.
    collapse (mean) sh_v, by(urban code_all)

    * >>>> Exclude below 1% share. Change 1% here if want to change threshold <<<<
    gen inclusionshare_fe = (sh_v>=`tshare')

    di "Inclusion based on consumption share:"
    table (code_all) (urban), stat(mean inclusionshare_fe)

    keep urban code_all inclusionshare_fe
    save "${gdTemp}/2-1-inclusion-share-fe.dta", replace
restore

*** COMPILE ALL
use "${gdTemp}/2-1-inclusion-share.dta", clear
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-share-food.dta"
drop _merge
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-share-fe.dta"
drop _merge

save "${gdTemp}/2-1-inclusion-share-all.dta", replace

********************************************************************************

*** 2. Prepare data for inclusion 
use "{gdTemp}/2-0-p1-unit-price.dta", clear

* generate number of HH if we want to have inclusion based on number of HH
preserve
    gen obs = 1
    collapse (sum) obs, by(urban year)
    tempfile hhnum
    save `hhnum',replace
restore

* check number of transaction and trend
replace p1 = . if p1==0
replace p1 = . if inlist(0,q,v)
collapse (count) p1, by(urban year code_all)
merge m:1 urban year using `hhnum', keepusing(obs)
reshape wide p1 obs, i(urban code_all) j(year)
save "${gdTemp}/2-0-inclusion-preparation.dta", replace

********************************************************************************

*** 3. Check whether items consumed all years by nat urban rural
use "${gdTemp}/2-0-inclusion-preparation.dta", clear
egen missingtrend = rowmiss(p1*)
gen inclusiontrend = (missingtrend==0 | missingtrend==.)

di "Inclusion based on trend:"
table () (urban), stat(mean inclusiontrend)

keep urban inclusiontrend
save "${gdTemp}/2-1-inclusion-trend.dta",replace 

********************************************************************************

*** 4. Mark commodities if only consumed below xx% of total HH (use 1% now)
use "${gdTemp}/2-0-inclusion-preparation.dta", clear
egen minstransaction = rowmin(p1*)
egen minobs = rowmin(obs*)
egen minshare = mintransaction/minobs

* >>>> Exclude below 1% share. Change 1% here if want to change threshold <<<<
gen inclusiontransaction = (minshare>=`ttrans')

di "Inclusion based on transaction number:"
table (urban) (code_all), stat(mean inclusiontransaction)

keep urban code_all inclusiontransaction
save "${gdTemp}/2-1-inclusion-transaction.dta", replace

********************************************************************************

*** 5. Combine inclusion and generate inclusion of commodities included
use "${gdTemp}/2-1-inclusion-share-all.dta", clear
merge m:1 urban using "${gdTemp}/2-1-inclusion-trend.dta",
drop _merge
merge 1:1 urban code_all using "${gdTemp}/2-1-inclusion-transaction.dta"
drop _merge

gen inclusion_all_ffe = (inclusionshare==1 & inclusiontrend==1 & inclusiontransaction==1)
gen inclusion_all_f = (inclusionshare_food==1 & inclusiontrend==1 & inclusiontransaction==1)
gen inclusion_all_fe = (inclusionshare_fe==1 & inclusiontrend==1 & inclusiontransaction==1)
save "${gdTemp}/2-1-inclusion-all.dta", replace