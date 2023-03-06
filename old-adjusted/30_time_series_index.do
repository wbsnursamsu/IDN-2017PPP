* check index

clear
capture log close
set more off

global rawdat "C:\Users\wb594719\OneDrive - WBG\Poverty Line Analysis\Generated Data"
global output "C:\Users\wb594719\OneDrive - WBG\Poverty Line Analysis\Outputs\Graphs"


** prep merged data **
use "$rawdat/Laspeyres Spatial 2010-2021 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
gen urban = 0
replace urban = 1 if mod(provcode_urban,2)!=0

tostring urban, replace
replace urban = "Urban" if urban=="1"
replace urban = "Rural" if urban=="0"

tostring provcode_urban, replace
gen provcode = substr(provcode_urban,1,2)
destring provcode, replace
drop provcode_urban

bys urban year: egen rank = rank(-index)

reshape wide index rank, i(year urban) j(provcode)
order year urban index* rank*

// #delimit ;
// label define provname  
// 	11	"Aceh"
// 	12	"Sumatera Utara"
// 	13	"Sumatera Barat"
// 	14	"Riau"
// 	15	"Jambi"
// 	16	"Sumatera Selatan"
// 	17	"Bengkulu"
// 	18	"Lampung"
// 	19	"Kep. Bangka Belitung"
// 	21	"Kep. Riau"
// 	32	"Jawa Barat"
// 	33	"Jawa Tengah"
// 	34	"Di Yogyakarta"
// 	35	"Jawa Timur"
// 	36	"Banten"
// 	51	"Bali"
// 	52	"Nusa Tenggara Barat"
// 	53	"Nusa Tenggara Timur"
// 	61	"Kalimantan Barat"
// 	62	"Kalimantan Tengah"
// 	63	"Kalimantan Selatan"
// 	64	"Kalimantan Timur"
// 	65	"Kalimantan Utara"
// 	71	"Sulawesi Utara"
// 	72	"Sulawesi Tengah"
// 	73	"Sulawesi Selatan"
// 	74	"Sulawesi Tenggara"
// 	75	"Gorontalo"
// 	76	"Sulawesi Barat"
// 	81	"Maluku"
// 	82	"Maluku Utara"
// 	91	"Papua Barat"
// 	94	"Papua"	
// 	;


** trend time series graph by province

foreach i in Urban Rural {
	foreach j in index rank {
		twoway line `j'11-`j'21 year if urban=="`i'", xtitle("year") ytitle("laspeyres index") title("`j'_`i'")
		graph export "$output/`j'_`i'_11_21.png", replace
		twoway line `j'31-`j'64 year if urban=="`i'", xtitle("year") ytitle("laspeyres index") title("`j'_`i'")
		graph export "$output/`j'_`i'_31_64.png", replace
		twoway line `j'71-`j'94 year if urban=="`i'", xtitle("year") ytitle("laspeyres index") title("`j'_`i'")
		graph export "$output/`j'_`i'_71_94.png", replace		
		}
	}
