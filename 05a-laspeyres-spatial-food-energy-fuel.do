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
foreach y in 22 {
	capture log close
	log using "$gdLog/spatial_index_national_`y'_mar_basep0_urban_v5.log", replace	
	use "$gdOutput/SUS_Mod`y'.dta", clear
	keep if inlist(item,"food","energy","fuel")
	destring kode, replace
	laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(1) itemidend(500) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) minshare(1) transactions(0.16) basep0var(urban) basep0val(1)
	gen year = 2000 + `y'
	local yr = 2000 + `y'
	save "$gdTemp/Laspeyres_`yr'_naturbanP0-ffe", replace
	capture log close
}
foreach y in 2002 2006 2010 2014 2018 2022 {
	if `y' == 2002 {
		use "$gdTemp/Laspeyres_`y'_naturbanP0-ffe", clear
	} 
	else {
		append using "$gdTemp/Laspeyres_`y'_naturbanP0-ffe"
	}
	cap erase "$gdTemp/Laspeyres_`y'_naturbanP0-ffe"
}
save "$gdOutput/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 - ffe.dta", replace
