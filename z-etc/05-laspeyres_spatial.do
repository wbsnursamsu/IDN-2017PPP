********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Do-files for Spatial Laspeyres
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************
	
**** Get the program (From Imam's do fie)
do "$gdDo/05-1-Laspeyres_Spatial_SUS_v5.do"
* Dump everything in the tempfile folder (the ado needs this)
cd "$gdTemp"

* 1st iteration	
**** Run for all data ****
* Province U-R, using National Urban as P0, food
foreach y in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
	capture log close
	log using "$gdLog/spatial_index_national_`y'_mar_basep0_urban_v5.log", replace	
	use "$gdOutput/SUS_Mod`y'.dta", clear
	keep if mod == 41
	destring kode, replace
	laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(1) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) minshare(1) transactions(0.16) basep0var(urban) basep0val(1)
	gen year = 2000 + `y'
	local yr = 2000 + `y'
	save "$gdTemp/Laspeyres_`yr'_naturbanP0", replace
	capture log close
}

forval t=2002/2022 {
	if `t' == 2002 {
		use "$gdTemp/Laspeyres_`t'_naturbanP0", clear
	} 
	else {
		append using "$gdTemp/Laspeyres_`t'_naturbanP0"
	}
}

save "$gdOutput/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", replace
