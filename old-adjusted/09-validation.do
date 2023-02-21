********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Calibration Result Validation
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Result Validation
use "$gdOutput/Exppl - Laspeyres Merged 2002-2022.dta", clear
replace cpi2017 = cpi2017/100
label define urban 0 "Rural" 1 "Urban"
label variable urban urban
drop if urut == ""
	
*** Data prep
* Merge
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 2.15 USD PPP - Food Deflation 2022.dta", nogen
rename (alphaR alphaU) (alphaR215F alphaU215F)
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 3.65 USD PPP - Food Deflation 2022.dta", nogen
rename (alphaR alphaU) (alphaR365F alphaU365F)
merge m:1 year using "$gdOutput/Spatial Laspeyres Calibrator - 6.85 USD PPP - Food Deflation 2022.dta", nogen
rename (alphaR alphaU) (alphaR685F alphaU685F)
drop if inlist(year,2000,2001)
		
** National Poverty Rate
gen poor_NPL = pcexp < povline

** Baseline (to match)
gen y_pcexp = pcexp * 12
gen rpcexp_ppp = .
replace rpcexp_ppp = (y_pcexp/cpi2017/icp17rural/365) if urban == 0
replace rpcexp_ppp = (y_pcexp/cpi2017/icp17urban/365) if urban == 1
gen poor_IPL215 = rpcexp_ppp < 2.15
gen poor_IPL365 = rpcexp_ppp < 3.65
gen poor_IPL685 = rpcexp_ppp < 6.85
			
** Spatially adjusted (food cons aggregate only), mean price as baseline, calibrated to povcalnet rate
		
gen food_defl_215 = .
gen y_pcexp_fooddefl_215 = .
gen rpcexp_ppp_fooddefl_215 = .
			
* 2.15 PPP
replace food_defl_215 = food / (lasp_avgnatU_v5 * alphaR215F) if urban == 0
replace food_defl_215 = food / (lasp_avgnatU_v5 * alphaU215F) if urban == 1
replace y_pcexp_fooddefl_215 = ((food_defl_215 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_215 = (y_pcexp_fooddefl_215/cpi2017/icp17/365)
gen poor_IPL215_fooddefl = rpcexp_ppp_fooddefl_215 < 2.15
			
gen food_defl_365 = .
gen y_pcexp_fooddefl_365 = .
gen rpcexp_ppp_fooddefl_365 = .
		
* 3.65 PPP
replace food_defl_365 = food / (lasp_avgnatU_v5 * alphaR365F) if urban == 0
replace food_defl_365 = food / (lasp_avgnatU_v5 * alphaU365F) if urban == 1
replace y_pcexp_fooddefl_365 = ((food_defl_365 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_365 = (y_pcexp_fooddefl_365/cpi2017/icp17/365)
gen poor_IPL365_fooddefl = rpcexp_ppp_fooddefl_365 < 3.65
			
gen food_defl_685 = .
gen y_pcexp_fooddefl_685 = .
gen rpcexp_ppp_fooddefl_685 = .
			
* 6.85 PPP
replace food_defl_685 = food / (lasp_avgnatU_v5 * alphaR685F) if urban == 0
replace food_defl_685 = food / (lasp_avgnatU_v5 * alphaU685F) if urban == 1
replace y_pcexp_fooddefl_685 = ((food_defl_685 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_685 = (y_pcexp_fooddefl_685/cpi2017/icp17/365)
gen poor_IPL685_fooddefl = rpcexp_ppp_fooddefl_685 < 6.85

* Label variables
label variable region "Island region - 6"
label variable region2 "Island region - lagging regions"
label variable icp17 "2017 USD PPP Conversion Rate - National"
label variable icp17rural "2017 USD PPP Conversion Rate - Rural"
label variable icp17urban "2017 USD PPP Conversion Rate - Urban"
label variable alphaR215F "Calibrated rural food deflator - 2.15 USD PPP"
label variable alphaU215F "Calibrated urban food deflator - 2.15 USD PPP"
label variable alphaR365F "Calibrated rural food deflator - 3.65 USD PPP"
label variable alphaU365F "Calibrated urban food deflator - 3.65 USD PPP"
label variable alphaR685F "Calibrated rural food deflator - 6.85 USD PPP"
label variable alphaU685F "Calibrated urban food deflator - 6.85 USD PPP"
label variable poor_NPL "Poor (=1), at national poverty line"
label variable y_pcexp "Annual nominal percapita consumption (food + nonfood)"
label variable rpcexp_ppp "Real daily percapita consumption (t food + t nonfood), standard povcalnet method"
label variable rpcexp_ppp_fooddefl_215 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 2.15 USD PPP FGT0"
label variable rpcexp_ppp_fooddefl_365 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 3.65 USD PPP FGT0"
label variable rpcexp_ppp_fooddefl_685 "Real daily percapita consumption (st food + t nonfood) adjusted to Povcalnet 6.85 USD PPP FGT0"
			
*** Save the dataset
compress
save "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", replace
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
		
*** Quick check national & international U/R pl nationally
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
collapse (mean) poor_NPL poor_IPL215 [w=weind], by(year urban)
tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL215 year if urban == 0, lp(dash) lcol(maroon)) (line poor_IPL215 year if urban == 1, lp(dash) lcol(navy)), title("Standard IPL 2.15 USD PPP and NPL Poverty Rate") legend(label(1 "National Poverty Rate - Rural") label(2 "National Poverty Rate  - Urban") label(3 "IPL 2.15 USD PPP - Rural")  label(4 "IPL 2.15 USD PPP - Urban")) graphregion(color(white)) scale(0.75)
graph export "$gdOutput/Graphs/PA_Standard NPL & IPL Povrate.png", replace
	
** Quick check national & international U/R pl, by region
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
collapse (mean) poor_NPL poor_IPL215 [w=weind], by(year region urban)
tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL215 year if urban == 0, lp(dash) lcol(maroon)) (line poor_IPL215 year if urban == 1, lp(dash) lcol(navy)), by(region, title("Standard IPL 2.15 USD PPP and NPL Poverty Rate") graphregion(color(white)) scale(0.75)) legend(label(1 "National Poverty Rate - Rural") label(2 "National Poverty Rate  - Urban") label(3 "IPL 2.15 USD PPP - Rural") label(4 "IPL 2.15 USD PPP - Urban")) 
graph export "$gdOutput/Graphs/PA_Standard NPL & IPL Povrate - By Region.png", replace

** Display correction factor, Food consumption aggregate deflation
local graphs
local ipls 2.15 3.65 6.85
forval i = 0/2  {
	gettoken ipl ipls:ipls
	use "$gdOutput/Spatial Laspeyres Calibrator - `ipl' USD PPP - Food Deflation 2022.dta", clear
	reshape long alpha, i(year) j(area) string
	gen urban = (area == "U")
	label define urban 0 "Rural" 1 "Urban
	label values urban urban
	tw (bar alpha year), by(urban, graphregion(color(white)) title("`ipl' USD PPP")) yscale(range(0.5 1.5)) xscale(range(2010 2021)) yline(1, lc(maroon%70) lp(dash))xtitle("Year") ytitle("Correction Factor") saving(cal`i', replace) 
	local graphs `graphs' cal`i'.gph
}
graph combine `graphs', r(1) c(3) ycom xcom iscale(0.8) ysize(1) xsize(3) graphregion(color(white)) title("Spatial Laspeyres Correction Factor - Food Deflation Only") note("Reference P0s are national urban & national rural povcalnet estimate.")
graph export "$gdOutput/Graphs/PA_Calculated Calibration Factor - Food Deflation.png", replace

** Poverty Rate at National, by Urban
local ipls 215 365 685
local ipls2 2.15 3.65 6.85
forval i = 0/2  {
	gettoken ipl ipls:ipls
	gettoken ipl2 ipls2:ipls2
	use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
	collapse (mean) poor_NPL poor_IPL`ipl'* [w=weind], by(year urban)
	tw (line poor_NPL year, lp(dash) lcol(maroon)) (line poor_IPL`ipl' year, lp(solid) lcol(maroon)) (line poor_IPL`ipl'_fooddefl year, lp(dash_dot) lcol(maroon)), by(urban, scale(0.75) graphregion(color(white)) title("NPL, Standard vs Adjusted IPL `ipl2' - National")) legend(label(1 "National Poverty Line") label(2 "`ipl2' IPL") label(3 "`ipl2' IPL - Spatially Deflated")) xtitle("Year") ytitle("P0 Rate")
	graph export "$gdOutput/Graphs/PA_NPL Standard vs Adjusted IPL `ipl2' P0 - National.png", replace
}

** By island region
local ipls 215 365 685
local ipls2 2.15 3.65 6.85
forval i = 0/2  {
	gettoken ipl ipls:ipls
	gettoken ipl2 ipls2:ipls2
	use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
	collapse (mean) poor_NPL poor_IPL`ipl'* [w=weind], by(year region urban)
	tw (line poor_NPL year if urban == 0, lp(solid) lcol(maroon)) (line poor_NPL year if urban == 1, lp(solid) lcol(navy)) (line poor_IPL`ipl' year if urban == 0, lp(dash_dot) lcol(maroon) lw(medthick)) (line poor_IPL`ipl' year if urban == 1, lp(dash_dot) lcol(navy) lw(medthick)) (line poor_IPL`ipl'_fooddefl year if urban == 0, lp(dot) lcol(maroon) lw(medthick)) (line poor_IPL`ipl'_fooddefl year if urban == 1, lp(dot) lcol(navy) lw(medthick)), by(region, scale(0.75) title("Standard vs Adjusted IPL `ipl2' - by Region") graphregion(color(white))) legend(label(1 "NPL - Rural") label(2 "NPL - Urban") label(3 "`ipl2' IPL - Rural") label(4 "`ipl2' IPL - Urban") label(5 "`ipl2' IPL - Rural, Spatially Adjusted") label(6 "`ipl2' IPL - Urban, Spatially Adjusted")) xtitle("Year") ytitle("P0 Rate")
	graph export "$gdOutput/Graphs/PA_NPL Standard vs Adjusted IPL `ipl2' P0 - by Region All Graphs.png", replace
}

** All provinces
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
collapse (mean) poor_NPL poor_IPL* [w=weind], by(year region)			
tw (line poor_NPL year if region == 1) (line poor_NPL year if region == 2) (line poor_NPL year if region == 3) (line poor_NPL year if region == 4) (line poor_NPL year if region == 5) (line poor_NPL year if region == 6), legend(label(1 "Sumatera") 	   label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi")label(6 "Maluku-Papua")) title("NPL") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g1, replace)
		
tw (line poor_IPL215 year if region == 1) (line poor_IPL215 year if region == 2) (line poor_IPL215 year if region == 3) (line poor_IPL215 year if region == 4) (line poor_IPL215 year if region == 5) (line poor_IPL215 year if region == 6), legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi") label(6 "Maluku-Papua")) title("IPL 2.15 USD PPP") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g2, replace)

tw (line poor_IPL215_fooddefl year if region == 1) (line poor_IPL215_fooddefl year if region == 2) (line poor_IPL215_fooddefl year if region == 3) (line poor_IPL215_fooddefl year if region == 4) (line poor_IPL215_fooddefl year if region == 5) (line poor_IPL215_fooddefl year if region == 6), legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi") label(6 "Maluku-Papua")) title("IPL 2.15 USD PPP - Spatially Deflated") graphregion(color(white)) xtitle("Year") ytitle("P0 Rate") saving(g3, replace)

grc1leg2 g1.gph g2.gph g3.gph, r(1) c(3) ycom xcom iscale(0.9) ysize(2) xsize(5) graphregion(color(white)) title("Regional Poverty Trends") scale(0.75) note("Reference P0s for the adjusted IPL graph are national urban & national rural povcalnet estimate.")
graph export "$gdOutput/Graphs/PA_Regional Poverty Trends.png", replace	
		
*** Combined urban+rural trends
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
collapse (mean) poor_NPL poor_IPL215* [w=weind], by(year region urban)
label define urban 0 "Rural" 1 "Urban", modify
label values urban urban
local graphs
local counter 1 2 3 4
local desc `" "NPL" "Standard 2.15 IPL" "Deflated (Total) 2.15 IPL" "Deflated (Food Only) 2.15 IPL" "'
foreach i in poor_NPL poor_IPL215 poor_IPL215_fooddefl {
	gettoken c counter:counter
	gettoken d desc:desc
	tw (line `i' year if region == 1) (line `i' year if region == 2, lw(medthick)) (line `i' year if region == 3) (line `i' year if region == 4) (line `i' year if region == 5, lp(dash) lw(medthick)) (line `i' year if region == 6, lp(dash) lw(medthick)), by(urban, title("`d'") graphregion(color(white)) scale(0.75)) legend(label(1 "Sumatera") label(2 "Java-Bali") label(3 "Nusa Tenggara") label(4 "Kalimantan") label(5 "Sulawesi")label(6 "Maluku-Papua")) xtitle("Year") ytitle("P0 Rate") yscale(range(0 0.5)) saving(g`c', replace)
	local graphs `graphs' g`c'.gph
}
grc1leg2 `graphs', r(2) c(2) ycom xcom iscale(0.75) ysize(3) xsize(4) graphregion(color(white)) title("Urban-Rural Poverty Trends") scale(0.75) note("Reference P0s for the adjusted IPL graph are national urban & national rural povcalnet estimate.")
graph export "$gdOutput/Graphs/PA_Urban-Rural Poverty Trends.png", replace	
		
*** Food/Non-food ratio by Region	
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2022.dta", clear
gen foodratio = food/(food+nfood)
collapse (mean) foodratio [w=weind], by(year region urban)	
tw (line foodratio year if urban == 0, lcol(maroon)) (line foodratio year if urban == 1, lcol(navy)), by(region, title("Share of Food to Consumption Aggregate, by Region") graphregion(color(white)) scale(0.75)) legend(label(1 "Rural") label(2 "Urban")) xtitle("Year") ytitle("Ratio")
graph export "$gdOutput/Graphs/PA_Share of Food to Cons Aggregate.png", replace	
	