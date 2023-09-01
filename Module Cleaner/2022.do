********************************************************************************
*	SUSENAS 2022 Consumption Module

clear all
cap log close
log using "${gdLog}/03-sus-cm-mar-2022.log", replace

********************************************************************************

********* YEAR = 2022 ***********
clear
set more off
cap log close

**** Data prep 2022

*** Consumption Module 41 (food), 188 unique code
use "${gdSUS}/MODULE/susenas22mar_41.dta",clear
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

tempfile mar22_41
save `mar22_41'

*** Consumption Module 42 (non-food)
use "${gdSUS}/MODULE/susenas22mar_42.dta",clear
tostring urut, replace
destring(r101-r105), replace

order urut, first
keep urut-r105 kode b42k3 b42k4 b42k5 sebulan r301

sort urut kode
        
gen q = .									/* quantity */
gen v = .									/* monetary value */

gen kode2 = .
replace kode2 = 205 if inlist(kode,205,206)
replace kode2 = 207 if inlist(kode,207,208)
replace kode2 = 210 if inlist(kode,210,211)
replace kode2 = 212 if inlist(kode,212,213)
replace kode2 = 215 if inlist(kode,215,216)
replace kode2 = 217 if inlist(kode,217,218)
replace kode2 = 219 if inlist(kode,219,220)
replace kode2 = 221 if inlist(kode,221,222)
replace kode2 = 224 if inlist(kode,224,225)
replace kode2 = 226 if inlist(kode,226,227)
replace kode2 = 228 if inlist(kode,228,229)
replace kode2 = 230 if inlist(kode,230,231)

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
    
drop if inlist(kode,199,206,208,209,211,213,216,218,220,222,225,227,229,231)

drop b42k3 b42k4 b42k5 sebulan

rename r301 hhsize

tostring kode, replace
replace kode = "0" + kode if length(kode) == 2
replace kode = "00" + kode if length(kode) == 1
gen mod = 42

tempfile mar22_42
save `mar22_42'

**** Append

use `mar22_41'
append using `mar22_42'

* cw
gen code22 = kode
destring code22, replace

merge m:1 code22 using "${gdTemp}/crosswalk-2022.dta", keepusing(code02 code04 code05 code06 code15 code17 code18 ditem_all item22 composite)
drop if _merge == 2
drop _merge

gen item = item22
gen year = 2022
drop if composite == 1
bys urut: egen t_v = total(v)
destring r101, replace

* region
gen provcode        = r101
gen kabcode         = r102
gen urban           = 0
replace urban       = 1 if r105==1
merge m:1 provcode kabcode using "${gdTemp}/region-crosswalk-2022.dta", keepusing(bps_code_all name_all)
drop if _merge==2
drop _merge

keep bps_code_all name_all provcode urban kabcode urut mod kode item ditem_all q v c t_v code02 code04 code05 code06 code15 code17 code18 code22 year
drop if ditem_all==""

* summarizing variables
collapse (sum) v (mean) t_v, by(year urut bps_code_all name_all provcode kabcode urban ditem_all)
gen shv_ = v/t_v
drop t_v
rename v v_ 
reshape wide shv_ v_, i(year urut bps_code_all name_all provcode kabcode urban) j(ditem_all) string

compress
save "$gdTemp/sus-cm-mar-2022.dta", replace
su shv_*