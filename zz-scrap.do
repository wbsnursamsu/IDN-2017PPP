** Spatially adjusted (food cons aggregate only), mean price as baseline, NOT calibrated to povcalnet rate
		
gen food_defl_215 = .
gen y_pcexp_fooddefl_215 = .
gen rpcexp_ppp_fooddefl_215 = .
			
* 2.15 PPP
replace food_defl_215 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_215 = food / (lasp_avgnatU_v5) if urban == 1
replace y_pcexp_fooddefl_215 = ((food_defl_215 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_215 = (y_pcexp_fooddefl_215/cpi2017/icp17/365)
gen poor_IPL215_fooddefl = rpcexp_ppp_fooddefl_215 < 2.15
			
gen food_defl_365 = .
gen y_pcexp_fooddefl_365 = .
gen rpcexp_ppp_fooddefl_365 = .
		
* 3.65 PPP
replace food_defl_365 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_365 = food / (lasp_avgnatU_v5) if urban == 1
replace y_pcexp_fooddefl_365 = ((food_defl_365 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_365 = (y_pcexp_fooddefl_365/cpi2017/icp17/365)
gen poor_IPL365_fooddefl = rpcexp_ppp_fooddefl_365 < 3.65
			
gen food_defl_685 = .
gen y_pcexp_fooddefl_685 = .
gen rpcexp_ppp_fooddefl_685 = .
			
* 6.85 PPP
replace food_defl_685 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_685 = food / (lasp_avgnatU_v5) if urban == 1
replace y_pcexp_fooddefl_685 = ((food_defl_685 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_685 = (y_pcexp_fooddefl_685/cpi2017/icp17/365)
gen poor_IPL685_fooddefl = rpcexp_ppp_fooddefl_685 < 6.85
** Spatially adjusted (food cons aggregate only), mean price as baseline, NOT calibrated to povcalnet rate
		
gen food_defl_215 = .
gen y_pcexp_fooddefl_215 = .
gen rpcexp_ppp_fooddefl_215 = .
			
* 2.15 PPP
replace food_defl_215 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_215 = food / (lasp_avgnatU_v5) if urban == 1
replace y_pcexp_fooddefl_215 = ((food_defl_215 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_215 = (y_pcexp_fooddefl_215/cpi2017/icp17/365)
gen poor_IPL215_fooddefl = rpcexp_ppp_fooddefl_215 < 2.15
			
gen food_defl_365 = .
gen y_pcexp_fooddefl_365 = .
gen rpcexp_ppp_fooddefl_365 = .
		
* 3.65 PPP
replace food_defl_365 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_365 = food / (lasp_avgnatU_v5) if urban == 1
replace y_pcexp_fooddefl_365 = ((food_defl_365 + nfood)/hhsize) * 12
replace rpcexp_ppp_fooddefl_365 = (y_pcexp_fooddefl_365/cpi2017/icp17/365)
gen poor_IPL365_fooddefl = rpcexp_ppp_fooddefl_365 < 3.65
			
gen food_defl_685 = .
gen y_pcexp_fooddefl_685 = .
gen rpcexp_ppp_fooddefl_685 = .
			
* 6.85 PPP
replace food_defl_685 = food / (lasp_avgnatU_v5) if urban == 0
replace food_defl_685 = food / (lasp_avgnatU_v5) if urban == 1
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

**# Bookmark #1

gen y_pcexp = pcexp * 12
gen rpcexp_ppp2 = .
replace rpcexp_ppp2 = (y_pcexp/cpi2011/icp11rural/365) if urban == 0
replace rpcexp_ppp2 = (y_pcexp/cpi2011/icp11urban/365) if urban == 1
gen poor_IPL19 = rpcexp_ppp2 < 1.9
gen poor_IPL32 = rpcexp_ppp2 < 3.2
gen poor_IPL55 = rpcexp_ppp2 < 5.5

**# Bookmark #2

gen rpcexp_ppp_fooddefl2 = .
			
replace rpcexp_ppp_fooddefl2 = (y_pcexp_fooddefl/cpi2011/icp11/365)
gen poor_IPL19_fooddefl = rpcexp_ppp_fooddefl2 < 1.9
gen poor_IPL32_fooddefl = rpcexp_ppp_fooddefl2 < 3.2
gen poor_IPL55_fooddefl = rpcexp_ppp_fooddefl2 < 5.5			