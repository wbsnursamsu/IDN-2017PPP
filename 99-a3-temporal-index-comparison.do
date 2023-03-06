clear all
set more off

*** CPI comparison

use "${gdTemp}/5-1-temp-lasp-ur-2017-ffe.dta", clear
reshape wide tlasp_ffe_2017,i(year) j(urban)
rename tlasp_ffe_20170 tlasp_ffe2017r
rename tlasp_ffe_20171 tlasp_ffe2017u
tempfile ffedat
save `ffedat', replace

use "${gdTemp}/5-1-temp-lasp-ur-2017-f.dta", clear
reshape wide tlasp_f_2017,i(year) j(urban)
rename tlasp_f_20170 tlasp_f2017r
rename tlasp_f_20171 tlasp_f2017u
tempfile fdat
save `fdat', replace

use "${gdData}/CPI/CPI International Povrate - Reno 2017ppp.dta", clear
merge 1:1 year using `ffedat', nogen
merge 1:1 year using `fdat', nogen

save "${gdTemp}/cpi-all.dta", replace

