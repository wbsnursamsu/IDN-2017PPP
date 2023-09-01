********************************************************************************
*	SUSENAS 2020 Consumption Module

clear all
cap log close
log using "${gdLog}/03-sus-cm-mar-2020.log", replace

********************************************************************************

********* YEAR = 2020 ***********

clear
set more off
cap log close

**** Data prep 2020

*** Consumption Module 41 (food), 188 unique code
use "${gdSUS}/MODULE/susenas20mar_41.dta",clear
tostring urut, replace
destring(r101-r105), replace

order urut, first
keep urut-r105 kode b41k9 b41k10 kalori r301
rename b41k10 v                              /* monetary value */
rename b41k9 q                               /* quantity */
rename kalori c                              /* calories */
rename r301 hhsize

tostring kode, replace
replace kode = "0" + kode if length(kode) == 2
replace kode = "00" + kode if length(kode) == 1
gen mod = 41

tempfile mar20_41
save `mar20_41'

*** Consumption Module 42 (non-food)
use "${gdSUS}/MODULE/susenas20mar_42.dta",clear
tostring urut, replace
destring(r101-r105), replace

order urut, first
keep urut-r105 kode b42k3 b42k4 b42k5 sebulan r301

sort urut kode
        
gen q = .									/* quantity */
gen v = .									/* monetary value */

gen kode2 = .
replace kode2 = 196 if inlist(kode,196,197)
replace kode2 = 198 if inlist(kode,198,199)
replace kode2 = 201 if inlist(kode,201,202)
replace kode2 = 203 if inlist(kode,203,204)
replace kode2 = 206 if inlist(kode,206,207)
replace kode2 = 208 if inlist(kode,208,209)
replace kode2 = 210 if inlist(kode,210,211)
replace kode2 = 212 if inlist(kode,212,213)
replace kode2 = 215 if inlist(kode,215,216)
replace kode2 = 217 if inlist(kode,217,218)
replace kode2 = 219 if inlist(kode,219,220)
replace kode2 = 221 if inlist(kode,221,222)

* Energy & Fuel
bysort urut kode2 (kode): replace b42k3 = b42k3[_n-1] if b42k3 == 0 
bysort urut kode2 (kode): replace b42k4 = b42k4[_n+1] if b42k4 == 0 
bysort urut kode2 (kode): replace b42k5 = b42k5[_n+1] if b42k5 == 0
bysort urut kode2 (kode): replace sebulan = sebulan[_n+1] if sebulan == 0 

* all non-good items
replace q = b42k3
replace v = sebulan
replace v = b42k4 if (v==0 | v==.)
replace v = b42k5/12 if (v==0 | v==.)
    
drop if inlist(kode,190,197,199,201,203,204,207,209,211,213,216,218,220,222)

drop b42k3 b42k4 b42k5 sebulan

rename r301 hhsize

tostring kode, replace
replace kode = "0" + kode if length(kode) == 2
replace kode = "00" + kode if length(kode) == 1
gen mod = 42

tempfile mar20_42
save `mar20_42'

**** Append

use `mar20_41'
append using `mar20_42'

* cw
gen code18 = kode
destring code18, replace

merge m:1 code18 using "${gdTemp}/crosswalk-2018.dta", keepusing(code02 code04 code05 code06 code15 code17 ditem_all item18 composite)
drop if _merge == 2
drop _merge

gen item = item18
gen year = 2020
drop if composite == 1
bys urut: egen t_v = total(v)
destring r101, replace

* region
gen provcode        = r101
gen kabcode         = r102
gen urban           = 0
replace urban       = 1 if r105==1
merge m:1 provcode kabcode using "${gdTemp}/region-crosswalk-2020.dta", keepusing(bps_code_all name_all)
drop if _merge==2
drop _merge

keep bps_code_all name_all provcode urban kabcode urut mod kode item ditem_all q v c t_v code02 code04 code05 code06 code15 code17 code18 year

* summarizing variables
collapse (sum) v (mean) t_v, by(year urut bps_code_all name_all provcode kabcode urban ditem_all)
gen shv_ = v/t_v
drop t_v
rename v v_ 
reshape wide shv_ v_, i(year urut bps_code_all name_all provcode kabcode urban) j(ditem_all) string

compress
save "$gdTemp/sus-cm-mar-2020.dta", replace
su shv_*