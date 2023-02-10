********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Robustness Check
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

******* 1. Vs other price data *************************************************
**** vs Minimum Wage (BPS data)
** Import BPS minimum wage
clear
cd "$gdTemp"
import excel "$gdData/Provincial Minimum Wage/Upah Minimum Regional_Propinsi All.xlsx", sheet("Sheet1") firstrow
rename Provcode provcode
reshape long Y, i(provcode) j(year)
rename Y umr
tempfile provur01
save `provur01'
		
** Merge with new spatial deflator 
use "$gdOutput/Laspeyres Spatial 2002-2021 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
tostring provcode_urban, replace
gen provcode = substr(provcode_urban,1,2)
gen urban = (substr(provcode_urban,3,2) == "01")
destring provcode, replace
drop provcode_urban

merge m:1 provcode year using `provur01'
keep if _merge == 3
drop _merge
		
** Scatterplot
gen l_umr = ln(umr)
label variable l_umr "Log of Provincial Minimum Wage"
label variable index 
local graphs		
foreach y in 2010 2011 2012 2013 2014 2015 2016 2018 2019 2020 {			
	preserve
		keep if year == `y'
		foreach i in l_umr index {
			sum `i', d
			gen z = (`i' - `r(mean)') / `r(sd)'
			replace `i' = . if abs(z) >= 1.96
			drop z
		}
		spearman umr index
		local rho : display %4.3f `r(rho)'
		local p : display %4.3f `r(p)'
		tw (scatter l_umr index if year == `y') (lowess l_umr index if year == `y'), title("Year: `y'") graphregion(color(white)) yscale(range(13 15.2)) xscale(range(0.8 1.8))text(13.4 1.2 "Rho: `rho', p-value: `p'", place(se)) saving(g`y', replace) nodraw
		local graphs `graphs' g`y'.gph
	restore
}
			
grc1leg2 `graphs', r(2) c(5) ysize(4) xsize(10) ycom xcom title("Spatial Laspeyres vs Log of Provincial Minimum Wage") note("Spearman Rank Correlation coefficient is reported with its p-value." "Outliers are ommited--defined as values that exceeds 1.96 times standard deviation") b2title("Laspeyres Index") l1title("Log of Provincial Minimum Wage") graphregion(color(white)) ring(0)		
graph export "$gdOutput/Graphs/PA_Scatterplot Laspeyres vs Minwage.png", replace
	
**** vs CPI (from MTI) 
** Load and Clean	
use "$gdData/CPI/mti_cpi_kp15_baseyear2012.dta", clear
keep if item == "Total"	
rename kp15 provcode
recode provcode (1 = 11) (2 = 12) (3 = 13) (4 = 14) (5 = 15) (6 = 16) (7 = 17) (8 = 18) (9 = 31) (10 = 32) (11 = 33) (12 = 34) (13 = 35) (14 = 61) (15 = 62) (16 = 63) (17 = 64) (18 = 71) (19 = 72) (20 = 73) (21 = 74) (22 = 51) (23 = 52) (24 = 53) (25 = 81) (26 = 94) (27 = 82) (28 = 36) (29 = 19) (30 = 75) (31 = 21) (32 = 91) (33 = 76) (34 = 65)
gen region = .
tostring provcode, replace
replace region = 1 if substr(provcode,1,1) == "1" | substr(provcode,1,1) == "2"
replace region = 2 if substr(provcode,1,1) == "3" | substr(provcode,1,2) == "51"
replace region = 3 if substr(provcode,1,2) == "52" | substr(provcode,1,2) == "53"
replace region = 4 if substr(provcode,1,1) == "6"
replace region = 5 if substr(provcode,1,1) == "7"
replace region = 6 if substr(provcode,1,1) == "8" | substr(provcode,1,1) == "9"
destring provcode, replace
label define region 0 "National" 1 "Sumatera" 2 "Jawa-Bali" 3 "Nusa Tenggara" 4 "Kalimantan" 5 "Sulawesi" 6 "Maluku-Papua"
label values region region
tempfile provur01
save `provur01'
	
** Merging
use "$gdOutput/Laspeyres Spatial 2002-2021 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
tostring provcode_urban, replace
gen provcode = substr(provcode_urban,1,2)
gen urban = (substr(provcode_urban,3,2) == "01")
destring provcode, replace
drop provcode_urban
merge m:1 provcode year using `provur01'
keep if _merge == 3
drop _merge

** Scatterplot
label variable index 
local graphs
foreach y in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {	
	spearman cpi index if year == `y'
	local rho : display %4.3f `r(rho)'
	local p : display %4.3f `r(p)'
	tw (scatter cpi index if year == `y') (lowess cpi index if year == `y'), title("Year: `y'") graphregion(color(white))yscale(range(80 150)) xscale(range(0.8 1.8))text(90 1.2 "Rho: `rho', p-value: `p'", place(se)) saving(g`y', replace) nodraw	
	local graphs `graphs' g`y'.gph
}
			
grc1leg2 `graphs', r(2) c(5) ysize(4) xsize(10) ycom xcom title("Spatial Laspeyres vs Provincial CPI, All Items") note("Spearman Rank Correlation coefficient is reported with its p-value.") b2title("Laspeyres Index") l1title("CPI base year 2012") graphregion(color(white)) ring(0)	
graph export "$gdOutput/Graphs/PA_Scatterplot Laspeyres vs Provincial CPI.png", replace
	
**** UMR vs CPI (from MTI)
** Load CPI total
use "$gdData/CPI/mti_cpi_kp15_baseyear2012.dta", clear
keep if item == "Total"
rename kp15 provcode
recode provcode (1 = 11) (2 = 12) (3 = 13) (4 = 14) (5 = 15) (6 = 16) (7 = 17) (8 = 18) (9 = 31) (10 = 32) (11 = 33) (12 = 34) (13 = 35) (14 = 61) (15 = 62) (16 = 63) (17 = 64) (18 = 71) (19 = 72) (20 = 73) (21 = 74) (22 = 51) (23 = 52) (24 = 53) (25 = 81) (26 = 94) (27 = 82) (28 = 36) (29 = 19) (30 = 75) (31 = 21) (32 = 91) (33 = 76) (34 = 65)
tempfile cpi
save `cpi'
						
** Import BPS minimum wage
clear
import excel "$gdData/Provincial Minimum Wage/Upah Minimum Regional_Propinsi All.xlsx", sheet("Sheet1") firstrow
rename Provcode provcode
reshape long Y, i(provcode) j(year)
rename Y umr

** Merge
merge 1:1 provcode year using `cpi'
keep if _merge == 3
drop _merge

** Scatterplot
cap gen l_umr = ln(umr)
local graphs	
foreach y in 2010 2011 2012 2013 2014 2015 2016 2018 2019 {
	spearman cpi l_umr if year == `y'
	local rho : display %4.3f `r(rho)'
	local p : display %4.3f `r(p)'
	tw (scatter cpi l_umr if year == `y') (lowess cpi l_umr if year == `y'), title("Year: `y'") graphregion(color(white)) yscale(range(80 150)) xscale(range(13 15.2)) text(90 13.2 "Rho: `rho', p-value: `p'", place(se)) saving(g`y', replace) nodraw
	local graphs `graphs' g`y'.gph
}
			
grc1leg2 `graphs', r(2) c(5) ysize(4) xsize(10) ycom xcom title("Minimum Wage vs Provincial CPI, All Items") note("Spearman Rank Correlation coefficient is reported with its p-value.") b2title("Minimum Wage") l1title("CPI base year 2012") graphregion(color(white)) ring(0)
graph export "$gdOutput/Graphs/PA_Minimum Wage vs Provincial CPI.png", replace
