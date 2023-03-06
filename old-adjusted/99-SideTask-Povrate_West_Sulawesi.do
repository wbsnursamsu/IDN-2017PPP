********************************************************************************
*
*	Project			: Poverty Line Analysis
*	Task			: Checking Poverty Impacts of Tsunami 2018
*	Subtask			: Palu, Donggala and Sigi districts 
*	Input			: -
*	Note			: -
*	Author			: Putu Sanjiwacika Wibisana	(pwibisana@worldbank.org)
*
********************************************************************************

	*** Load the dataset
	
	use "$gdData/Crosswalk/crosswalk_frame514_mar18_final.dta", clear
	
	use "$gdTemp/FINAL - Exppl Spatially Adjusted - 2002-2021.dta", clear
	
	gen district = ""
	replace district = "Palu" if provcode == 72 & kabcode == 71
	replace district = "Donggala" if provcode == 72 & kabcode == 5
	replace district = "Sigi" if provcode == 72  & kabcode == 10
	
	keep if district != ""
	
	collapse (mean) npl=poor_NPL ipl=poor_IPL19 ipl_a=poor_IPL19_fooddefl [w=weind], by(district year)
	sort district year
	
	local cells 4 9 14
	foreach i of varlist npl ipl ipl_a {
		gettoken c cells:cells
		preserve
			keep `i' district year
			reshape wide `i', i(district) j(year)
			export excel using "$gdOutput/PA_Poverty Rate in Tsunami-Impacted Region.xlsx", cell(B`c') firstrow(varlabels) sheetmodify 
		restore
	}
	
	
