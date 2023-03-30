**** Quantity graph plot - Temporal ****

*** 2002 - 2021
use "${gdOutput}\SUS_Mod02.dta", clear
collapse (mean) mean_q = q (sd) sd_q = q [aw=wert], by(year kode)
destring kode, replace
tempfile 2002dat
save `2002dat', replace

use "${gdOutput}\SUS_Mod21.dta", clear
collapse (mean) mean_q = q (sd) sd_q = q [aw=wert], by(year code02)
rename code02 kode
destring kode, replace
append using `2002dat'
drop if kode==248

gen min_q = mean_q-0.25*sd_q
gen max_q = mean_q+0.25*sd_q

** Graph quantity range
preserve
    drop if max_q>=1000
    replace max_q=199 if max_q>=200
    twoway (rcap max_q min_q kode if kode<=200 & year==2002) (rcap max_q min_q kode if kode<=200 & year==2021), legend(label(1 "2002") label(2 "2021")) title("Quantity range - 2002 & 2021") xtitle("Commodity code") ytitle("Mean + - 1/4 stdev")
    graph export "${gdOutput}/Graphs-additional/range-q-2002-2021.png", replace
restore

** Graph quantity mean
preserve 
    replace mean_q=199 if mean_q>=200
    twoway (scatter mean_q kode if year==2002) (scatter mean_q kode if year==2021), yline(200, lcolor(red)) legend(label(1 "Mean quantity - 2002") label(2 "Mean quantity - 2021")) text(195 295 "More than 200", color(red) size(small)) title("Quantity mean - 2002 & 2021") xtitle("Commodity code") ytitle("Mean")
    graph export "${gdOutput}/Graphs-additional/mean-q-2002-2021.png", replace
restore

**** Laspeyres temporal plot ****
use "${gdTemp}\cpi-all.dta", clear
gen cpi2017b = cpi2017/100
twoway (line cpi2017b year) (line tlasp_f2017r year) (line tlasp_f2017u year), title("Temporal trend comparison") xtitle("Year") ytitle("Index") legend(label(1 "CPI base 2017") label(2 "Laspeyres base 2017 - Rural") label(3 "Laspeyres base 2017 - Urban"))
graph export "${gdOutput}\Graphs-additional\temporal-index-comparison.png", replace