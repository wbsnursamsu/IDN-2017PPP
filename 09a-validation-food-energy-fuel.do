********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Calibration Result Validation
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Result Validation
use "$gdOutput/Exppl - Laspeyres Merged 2002-2022 - ffe.dta", clear
replace cpi2017 = cpi2017/100
replace cpi2011 = cpi2011/100
label define urban 0 "Rural" 1 "Urban"
label variable urban urban
drop if urut == ""
	
*** Data prep
drop if inlist(year,2000,2001)
		
** National Poverty Rate
gen poor_NPL = pcexp < povline

** Baseline (to match)
gen y_pcexp = pcexp * 12

* PPP 2017
gen rpcexp_ppp2017 = .
replace rpcexp_ppp2017 = (y_pcexp/cpi2017/icp17rural/365) if urban == 0
replace rpcexp_ppp2017 = (y_pcexp/cpi2017/icp17urban/365) if urban == 1
gen poor_IPL215 = rpcexp_ppp2017 < 2.15
gen poor_IPL365 = rpcexp_ppp2017 < 3.65
gen poor_IPL685 = rpcexp_ppp2017 < 6.85

* PPP 2011 
gen rpcexp_ppp2011 = .
replace rpcexp_ppp2011 = (y_pcexp/cpi2011/icp11rural/365) if urban == 0
replace rpcexp_ppp2011 = (y_pcexp/cpi2011/icp11urban/365) if urban == 1
gen poor_IPL19 = rpcexp_ppp2011 < 1.9
gen poor_IPL32 = rpcexp_ppp2011 < 3.2
gen poor_IPL55 = rpcexp_ppp2011 < 5.5
			
** Spatially adjusted (food cons aggregate only), mean price as baseline
		
gen food_defl = .
gen y_pcexp_fooddefl = .
gen rpcexp_ppp2017_fooddefl = .
gen rpcexp_ppp2011_fooddefl = .
			
replace food_defl = food / (laspeyres_ffe)
replace y_pcexp_fooddefl = ((food_defl + nfood)/hhsize) * 12
replace rpcexp_ppp2017_fooddefl = (y_pcexp_fooddefl/cpi2017/icp17/365)
replace rpcexp_ppp2011_fooddefl = (y_pcexp_fooddefl/cpi2011/icp11/365)

* PPP 2017
gen poor_IPL215_fooddefl = rpcexp_ppp2017_fooddefl < 2.15
gen poor_IPL365_fooddefl = rpcexp_ppp2017_fooddefl < 3.65
gen poor_IPL685_fooddefl = rpcexp_ppp2017_fooddefl < 6.85			

* PPP 2011 
gen poor_IPL19_fooddefl = rpcexp_ppp2011_fooddefl < 1.9
gen poor_IPL32_fooddefl = rpcexp_ppp2011_fooddefl < 3.2
gen poor_IPL55_fooddefl = rpcexp_ppp2011_fooddefl < 5.5			

* Label variables
label variable region "Island region - 6"
label variable region2 "Island region - lagging regions"
label variable icp17 "2017 USD PPP Conversion Rate - National"
label variable icp17rural "2017 USD PPP Conversion Rate - Rural"
label variable icp17urban "2017 USD PPP Conversion Rate - Urban"
label variable poor_NPL "Poor (=1), at national poverty line"
label variable y_pcexp "Annual nominal percapita consumption (food + nonfood)"
label variable rpcexp_ppp2017 "Real daily percapita consumption (t food + t nonfood) - PPP 2017"
label variable rpcexp_ppp2011 "Real daily percapita consumption (t food + t nonfood) - PPP 2011"
label variable rpcexp_ppp2017_fooddefl "Real daily percapita consumption (st food + t nonfood) - PPP 2017"
label variable rpcexp_ppp2011_fooddefl "Real daily percapita consumption (st food + t nonfood) - PPP 2011"

* label urban rural
la def urb 0 "Rural" 1 "Urban"
la val urban urb
			
*** Save the dataset
compress
save "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", replace
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
		
// *** Quick check national & international U/R pl nationally
// use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
// collapse (mean) poor_NPL poor_IPL215 [w=weind], by(year urban)
// tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL215 year if urban == 0, lp(dash) lcol(maroon)) (line poor_IPL215 year if urban == 1, lp(dash) lcol(navy)), title("Standard IPL 2.15 USD PPP and NPL Poverty Rate") legend(label(1 "National Poverty Rate - Rural") label(2 "National Poverty Rate  - Urban") label(3 "IPL 2.15 USD PPP - Rural")  label(4 "IPL 2.15 USD PPP - Urban")) graphregion(color(white)) scale(0.75)
// graph export "$gdOutput/Graphs-food-fuel-energy/PA_Standard NPL & IPL Povrate.png", replace
//	
// ** Quick check national & international U/R pl, by region
// use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
// collapse (mean) poor_NPL poor_IPL215 [w=weind], by(year region urban)
// tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL215 year if urban == 0, lp(dash) lcol(maroon)) (line poor_IPL215 year if urban == 1, lp(dash) lcol(navy)), by(region, title("Standard IPL 2.15 USD PPP and NPL Poverty Rate") graphregion(color(white)) scale(0.75)) legend(label(1 "National Poverty Rate - Rural") label(2 "National Poverty Rate  - Urban") label(3 "IPL 2.15 USD PPP - Rural") label(4 "IPL 2.15 USD PPP - Urban")) 
// graph export "$gdOutput/Graphs-food-fuel-energy/PA_Standard NPL & IPL Povrate - By Region.png", replace


** Poverty Rate at National, by Urban
local ipls 215 365 685
local ipls2 2.15 3.65 6.85
forval i = 0/2  {
	gettoken ipl ipls:ipls
	gettoken ipl2 ipls2:ipls2
	use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
	collapse (mean) poor_NPL poor_IPL`ipl'* [w=weind], by(year urban)
	tw (line poor_NPL year, lp(dash) lcol(maroon)) (line poor_IPL`ipl' year, lp(solid) lcol(maroon)) (line poor_IPL`ipl'_fooddefl year, lp(dash_dot) lcol(maroon)), by(urban, scale(0.75) graphregion(color(white)) title("NPL, Standard vs Adjusted IPL `ipl2' - National")) legend(label(1 "National Poverty Line") label(2 "`ipl2' IPL") label(3 "`ipl2' IPL - Spatially Deflated"))  xtitle("Year") ytitle("P0 Rate")
	graph export "$gdOutput/Graphs-food-fuel-energy/PA_NPL Standard vs Adjusted IPL `ipl2' P0 - National - PPP2017.png", replace
}

local ipls 19 32 55
local ipls2 1.9 3.2 5.5
forval i = 0/2  {
	gettoken ipl ipls:ipls
	gettoken ipl2 ipls2:ipls2
	use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
	collapse (mean) poor_NPL poor_IPL`ipl'* [w=weind], by(year urban)
	tw (line poor_NPL year, lp(dash) lcol(maroon)) (line poor_IPL`ipl' year, lp(solid) lcol(maroon)) (line poor_IPL`ipl'_fooddefl year, lp(dash_dot) lcol(maroon)), by(urban, scale(0.75) graphregion(color(white)) title("NPL, Standard vs Adjusted IPL `ipl2' - National")) legend(label(1 "National Poverty Line") label(2 "`ipl2' IPL") label(3 "`ipl2' IPL - Spatially Deflated"))  xtitle("Year") ytitle("P0 Rate")
	graph export "$gdOutput/Graphs-food-fuel-energy/PA_NPL Standard vs Adjusted IPL `ipl2' P0 - National - PPP2011.png", replace
}

** By island region
local ipls 215 365 685
local ipls2 2.15 3.65 6.85
forval i = 0/2  {
	gettoken ipl ipls:ipls
	gettoken ipl2 ipls2:ipls2
	use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
	collapse (mean) poor_NPL poor_IPL`ipl'* [w=weind], by(year region urban)
	tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL`ipl' year if urban == 0, lp(dash_dot) lcol(maroon) lw(medthick)) (line poor_IPL`ipl' year if urban == 1, lp(dash_dot) lcol(navy) lw(medthick)) (line poor_IPL`ipl'_fooddefl year if urban == 0, lp(dot) lcol(maroon) lw(medthick)) (line poor_IPL`ipl'_fooddefl year if urban == 1, lp(dot) lcol(navy) lw(medthick)), by(region, scale(0.75) title("Standard vs Adjusted IPL `ipl2' - by Region") graphregion(color(white))) legend(label(1 "NPL - Rural") label(2 "NPL - Urban") label(3 "`ipl2' IPL - Rural") label(4 "`ipl2' IPL - Urban") label(5 "`ipl2' IPL - Rural, Spatially Deflated") label(6 "`ipl2' IPL - Urban, Spatially Deflated")) xtitle("Year") ytitle("P0 Rate")
	graph export "$gdOutput/Graphs-food-fuel-energy/PA_NPL Standard vs Adjusted IPL `ipl2' P0 - by Region All Graphs-food-fuel-energy.png", replace
}

** All provinces
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
collapse (mean) poor_NPL poor_IPL* [w=weind], by(year region)			
tw (line poor_NPL year if region == 1) (line poor_NPL year if region == 2) (line poor_NPL year if region == 3) (line poor_NPL year if region == 4) (line poor_NPL year if region == 5) (line poor_NPL year if region == 6), legend(label(1 "Sumatera") 	   label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi")label(6 "Maluku-Papua")) title("NPL") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g1, replace)
		
tw (line poor_IPL215 year if region == 1) (line poor_IPL215 year if region == 2) (line poor_IPL215 year if region == 3) (line poor_IPL215 year if region == 4) (line poor_IPL215 year if region == 5) (line poor_IPL215 year if region == 6), legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi") label(6 "Maluku-Papua")) title("IPL 2.15 USD PPP") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g2, replace)

tw (line poor_IPL215_fooddefl year if region == 1) (line poor_IPL215_fooddefl year if region == 2) (line poor_IPL215_fooddefl year if region == 3) (line poor_IPL215_fooddefl year if region == 4) (line poor_IPL215_fooddefl year if region == 5) (line poor_IPL215_fooddefl year if region == 6), legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi") label(6 "Maluku-Papua")) title("IPL 2.15 USD PPP - Spatially Deflated") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g3, replace)

grc1leg2 g1.gph g2.gph g3.gph, r(1) c(3) ycom xcom iscale(0.9) ysize(2) xsize(5) graphregion(color(white)) title("Regional Poverty Trends") scale(0.75) 
graph export "$gdOutput/Graphs-food-fuel-energy/PA_Regional Poverty Trends.png", replace	
		
*** Combined urban+rural trends
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
collapse (mean) poor_NPL poor_IPL215* [w=weind], by(year region urban)
label define urban 0 "Rural" 1 "Urban", modify
label values urban urban
local Graphs
local counter 1 2 3 4
local desc `" "NPL" "Standard 2.15 IPL" "Deflated (Total) 2.15 IPL" "Deflated (Food Only) 2.15 IPL" "'
foreach i in poor_NPL poor_IPL215 poor_IPL215_fooddefl {
	gettoken c counter:counter
	gettoken d desc:desc
	tw (line `i' year if region == 1) (line `i' year if region == 2, lw(medthick)) (line `i' year if region == 3) (line `i' year if region == 4) (line `i' year if region == 5, lp(dash) lw(medthick)) (line `i' year if region == 6, lp(dash) lw(medthick)), by(urban, title("`d'") graphregion(color(white)) scale(0.75)) legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi")label(6 "Maluku-Papua")) xtitle("Year") ytitle("P0 Rate") yscale(range(0 0.5)) saving(g`c', replace)
	local Graphs `Graphs' g`c'.gph
}
grc1leg2 `Graphs', r(2) c(2) ycom xcom iscale(0.75) ysize(3) xsize(4) graphregion(color(white)) title("Urban-Rural Poverty Trends") scale(0.75)
graph export "$gdOutput/Graphs-food-fuel-energy/PA_Urban-Rural Poverty Trends.png", replace	
		
// *** Food/Non-food ratio by Region	
// use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022 - ffe.dta", clear
// gen foodratio = food/(food+nfood)
// collapse (mean) foodratio [w=weind], by(year region urban)	
// tw (line foodratio year if urban == 0, lcol(maroon)) (line foodratio year if urban == 1, lcol(navy)), by(region, title("Share of Food to Consumption Aggregate, by Region") graphregion(color(white)) scale(0.75)) legend(label(1 "Rural") label(2 "Urban")) xtitle("Year") ytitle("Ratio")
// graph export "$gdOutput/Graphs-food-fuel-energy/PA_Share of Food to Cons Aggregate.png", replace	
	