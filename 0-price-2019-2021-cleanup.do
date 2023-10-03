cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata"

append using 00-shk-price-2019.dta
append using 00-shk-price-2020.dta
append using 00-shk-price-2021.dta

keep com_name year
duplicates drop
gen com_name2=subinstr(com_name,", 2019","",.) if year==2019
replace com_name2=subinstr(com_name,", 2020","",.) if year==2020
replace com_name2=subinstr(com_name,", 2021","",.) if year==2021
replace com_name2=subinstr(com_name2,", 2020","",.)

keep com_name2 year
gen a = 1
reshape wide a, i(com_name2) j(year)

save "19-21-dummy.dta", replace
export excel using "19-21-dummy.xlsx", firstrow(variables)

/* commodity codes 2019 - 2021 */
clear all
import excel using "19-21-match.xlsx", firstrow
drop a*
rename Unit unit
save "19-21-match.dta", replace

clear 
append using 00-shk-price-2019.dta
append using 00-shk-price-2020.dta
append using 00-shk-price-2021.dta

gen com_name2=subinstr(com_name,", 2019","",.) if year==2019
replace com_name2=subinstr(com_name,", 2020","",.) if year==2020
replace com_name2=subinstr(com_name,", 2021","",.) if year==2021
replace com_name2=subinstr(com_name2,", 2020","",.)

merge m:1 com_name2 using "19-21-match.dta"
drop _merge

drop com_name com_name2 ihkcode19 ihkcat19 fn comm category
order year komoditas unit prov city, first

destring jan-avg, replace force
save "shk-2019-2021.dta", replace