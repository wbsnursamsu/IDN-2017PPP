*** CHECK TOTAL CONSUMPTION OF EACH CONSUMPTION MODULE ***

clear all
set more off

*** CHECK TOTAL CONSUMPTION OF EACH CONSUMPTION MODULE ***

foreach t in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
    use "${gdOutput}/SUS_Mod`t'.dta", clear
    * change to month
    gen v_food = v*4 if item=="food"
    gen v_enfuel = v if inlist(item,"energy","fuel")
    foreach var of varlist v_food v_enfuel {
        replace `var' = 0 if missing(`var')
    }
    collapse (sum) v v_food v_enfuel, by(urut)
    merge 1:1 urut using "${gdTemp}/exppl_e`t'",keepusing(year urban food nfood pcexp region region2 weind wert)
    gen d_food = v_food/food
    gen s_food = v_food/(food+nfood)
    gen s_food_t = food/(food+nfood)
    gen s_enfuel = v_enfuel/(food+nfood)
    drop _merge
    
    save "${gdTemp}/99-sus-cons-`t'.dta", replace
}

use "${gdTemp}/99-sus-cons-02.dta", replace

foreach t in 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
    append using "${gdTemp}/99-sus-cons-`t'.dta"
}

save "${gdTemp}/99-sus-cons-02-22.dta", replace

** CREATE GRAPH

use "${gdTemp}/99-sus-cons-02-22.dta", clear
collapse (mean) v_food v_enfuel food nfood d_food s_food s_food_t s_enfuel [w=wert], by(year region urban)
drop if year==2022

** Share urban
tw (line s_food year if urban==1) (line s_enfuel year if urban==1), by(region, title("Share of Food & Energy Fuel to Consumption Agg, by Region, Urban")) legend(label(1 "Food") label(2 "Energy Fuel")) xtitle("Year") ytitle("Ratio")
graph export "${gdOutput}/Graphs-additional/share-urban.png", replace

** Share rural
tw (line s_food year if urban==0) (line s_enfuel year if urban==0), by(region, title("Share of Food & Energy Fuel to Consumption Agg, by Region, Rural")) legend(label(1 "Food") label(2 "Energy Fuel")) xtitle("Year") ytitle("Ratio")
graph export "${gdOutput}/Graphs-additional/share-rural.png", replace

*** Food share using true data
gen s_nfood_t = nfood/(food+nfood)
* Rural
tw (line s_food_t year if urban==0) (line s_nfood_t year if urban==0), by(region, title("Share of Food & NonFood in agg module, by Region, Rural")) legend(label(1 "Food") label(2 "Non Food")) xtitle("Year") ytitle("Ratio")
graph export "${gdOutput}/Graphs-additional/share-true-rural.png", replace

* Urban
tw (line s_food_t year if urban==1) (line s_nfood_t year if urban==1), by(region, title("Share of Food & NonFood in agg module, by Region, Urban")) legend(label(1 "Food") label(2 "Non Food")) xtitle("Year") ytitle("Ratio")
graph export "${gdOutput}/Graphs-additional/share-true-urban.png", replace

** Comparison food module and aggregate
use "${gdTemp}/99-sus-cons-02-22.dta", clear
drop if year==2022
collapse (mean) v_food food d_food s_food s_food_t [w=wert], by(year)

tw (line s_food year, lcol(maroon)) (line s_food_t year, lcol(navy)), title("Comparison of food share, true data vs commodities data") legend(label(1 "Commodity food share") label(2 "True food share")) xtitle("Year") ytitle("Ratio")
graph export "${gdOutput}/Graphs-additional/comparison-food-share.png", replace

tw (line v_food year, lcol(maroon)) (line food year, lcol(navy)), title("Comparison of food value, true data vs commodities data") legend(label(1 "Commodity food share") label(2 "True food share")) xtitle("Year") ytitle("Value")
graph export "${gdOutput}/Graphs-additional/comparison-food-value.png", replace

