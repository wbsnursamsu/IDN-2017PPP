********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Miscellaneous requests
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Calibrated vs non-calibrated povrate
use "$gdOutput/FINAL - Exppl Spatially Adjusted - 2002-2021.dta", clear
* Generate uncalibrated, spatially adjusted povrate
* 1.9 PPP
gen f19 = food / (lasp_avgnatU_v5)
gen cons_agg19 = ((f19 + nfood)/hhsize) * 12
gen rpcexp_cons_agg19 = (cons_agg19/cpi2011/icp11/365)
gen poor_IPL19_noncal = rpcexp_cons_agg19 < 1.9

**** Generate graphs by region
collapse (mean) poor_IPL19_noncal poor_IPL19_fooddefl [w=weind], by(year urban region)
keep if year >= 2010
tw (line poor_IPL19_noncal year if urban == 0) (line poor_IPL19_noncal year if urban == 1) (line poor_IPL19_fooddefl year if urban == 0) (line poor_IPL19_fooddefl year if urban == 1), by(region) legend(label(1 "Noncalibrated rural") label(2 "Noncalibrated urban") label(3 "Calibrated rural") label(4 "Calibrated urban"))