********************************************************************************
*
*	Project			: Poverty Line Analysis
*	Task			: CPI Exercise
*	Subtask			: -
*	Input			: -
*	Note			: -
*	Author			: Putu Sanjiwacika Wibisana	(pwibisana@worldbank.org)
*
********************************************************************************

**** Load the Dataset

	clear
	
	* Input inflation subcomponent weights
	input item_code weights
		2	7.25
		3	8.46
		4	18.85
		5	4.73
		6	25.37
		7	16.19
		1	100.00
		8	19.15
	end
	
	merge 1:m item_code using "$gdData/CPI/mti_cpi_kp15_baseyear2012.dta"
	winsor2 cpi, replace cuts(1 99) trim by(province15)
	
	drop if inlist(item_code,1,4,7)
	
	sort year province15 item
	
	bysort year province15 (item_code): egen tot_weights = total(weights)
	bysort year province15 (item_code): gen norm_weights = weights*100/tot_weights
	
	gen x = cpi * (norm_weights/100)
	bysort year province15 (item_code): egen nf_cpi = total(x)
	
	collapse (max) nf_cpi, by(province15 year)
	
	sort province15 year
	bysort province15 (year): gen rel2011 = nf_cpi/nf_cpi[5]
	
	gen provcode = .
	replace provcode = 11 if province15 == "Prov. Aceh"
	replace provcode = 51 if province15 == "Prov. Bali"
	replace provcode = 36 if province15 == "Prov. Banten"
	replace provcode = 17 if province15 == "Prov. Bengkulu"
	replace provcode = 34 if province15 == "Prov. D I Yogyakarta"
	replace provcode = 31 if province15 == "Prov. DKI Jakarta"
	replace provcode = 75 if province15 == "Prov. Gorontalo"
	replace provcode = 15 if province15 == "Prov. Jambi"
	replace provcode = 32 if province15 == "Prov. Jawa Barat"
	replace provcode = 33 if province15 == "Prov. Jawa Tengah"
	replace provcode = 35 if province15 == "Prov. Jawa Timur"
	replace provcode = 61 if province15 == "Prov. Kalimantan Barat"
	replace provcode = 63 if province15 == "Prov. Kalimantan Selatan"
	replace provcode = 62 if province15 == "Prov. Kalimantan Tengah"
	replace provcode = 64 if province15 == "Prov. Kalimantan Timur"
	replace provcode = 65 if province15 == "Prov. Kalimantan Utara"
	replace provcode = 19 if province15 == "Prov. Kepulauan Bangka Belitung"
	replace provcode = 21 if province15 == "Prov. Kepulauan Riau"
	replace provcode = 18 if province15 == "Prov. Lampung"
	replace provcode = 81 if province15 == "Prov. Maluku"
	replace provcode = 82 if province15 == "Prov. Maluku Utara"
	replace provcode = 52 if province15 == "Prov. Nusa Tenggara Barat"
	replace provcode = 53 if province15 == "Prov. Nusa Tenggara Timur"
	replace provcode = 94 if province15 == "Prov. Papua"
	replace provcode = 91 if province15 == "Prov. Papua Barat"
	replace provcode = 14 if province15 == "Prov. Riau"
	replace provcode = 76 if province15 == "Prov. Sulawesi Barat"
	replace provcode = 73 if province15 == "Prov. Sulawesi Selatan"
	replace provcode = 72 if province15 == "Prov. Sulawesi Tengah"
	replace provcode = 74 if province15 == "Prov. Sulawesi Tenggara"
	replace provcode = 71 if province15 == "Prov. Sulawesi Utara"
	replace provcode = 13 if province15 == "Prov. Sumatera Barat"
	replace provcode = 16 if province15 == "Prov. Sumatera Selatan"
	replace provcode = 12 if province15 == "Prov. Sumatera Utara"
	
	preserve
		import excel "$gdData/CPI/CPI Weights - Province City.xlsx", sheet("Sheet1") firstrow clear
		drop City
		collapse (sum) weights=Weights, by(Provcode)
		replace weights = weights/100
		rename Provcode provcode
		tempfile temp
		save `temp'
	restore
	
	merge m:1 provcode using `temp'
	drop if _merge == 2
	drop _merge
	
	gen nat = .
	forval y = 2007/2019 {
		sum rel2011 [w=weights] if year == `y', d
		replace nat = `r(mean)' if year == `y'
	}
	
	gen spatial_var = rel2011/nat
	sort provcode year
	
	collapse (mean) spatial_var, by(province15)
	sort spatial_var
	
	