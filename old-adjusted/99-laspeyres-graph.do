use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
 

*** LASPEYRES FOOD ONLY

rename index lasp_food
tostring provcode_urban, replace
rename provcode_urban provcode
gen urban = substr(provcode,4,1)
gen provcode2 = substr(provcode,1,2)
drop provcode
rename provcode2 provcode
destring urban, replace
destring provcode, replace
reshape wide lasp_food, i(provcode urban) j(year)

# delimit ;
label define provname
11	"Nanggroe Aceh Darussalam"
12	"Sumatera Utara"
13	"Sumatera Barat"
14	"Riau"
15	"Jambi"
16	"Sumatera Selatan"
17	"Bengkulu"
18	"Lampung"
19	"Kep. Bangka Belitung"
21	"Kep. Riau"
31	"DKI Jakarta"
32	"Jawa Barat"
33	"Jawa Tengah"
34	"DI Yogyakarta"
35	"Jawa Timur"
36	"Banten"
51	"Bali"
52	"Nusa Tenggara Barat"
53	"Nusa Tenggara Timur"
61	"Kalimantan Barat"
62	"Kalimantan Tengah"
63	"Kalimantan Selatan"
64	"Kalimantan Timur"
65  "Kalimantan Utara"
71	"Sulawesi Utara"
72	"Sulawesi Tengah"
73	"Sulawesi Selatan"
74	"Sulawesi Tenggara"
75	"Gorontalo"
76	"Sulawesi Barat"
81	"Maluku"
82	"Maluku Utara"
91	"Papua Barat"
94	"Papua" ;

#delimit cr

la val provcode provname

graph dot lasp_food2002-lasp_food2022 if urban==0, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs\laspeyres-food-rural.png", replace
graph dot lasp_food2002-lasp_food2022 if urban==1, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs\laspeyres-food-urban.png", replace

tempfile foodonly
save `foodonly', replace

*** LASPEYRES FOOD + FUEL + ENERGY
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 - ffe.dta", clear

rename index lasp_ffe
tostring provcode_urban, replace
rename provcode_urban provcode
gen urban = substr(provcode,4,1)
gen provcode2 = substr(provcode,1,2)
drop provcode
rename provcode2 provcode
destring urban, replace
destring provcode, replace
reshape wide lasp_ffe, i(provcode urban) j(year)

# delimit ;
label define provname
11	"Nanggroe Aceh Darussalam"
12	"Sumatera Utara"
13	"Sumatera Barat"
14	"Riau"
15	"Jambi"
16	"Sumatera Selatan"
17	"Bengkulu"
18	"Lampung"
19	"Kep. Bangka Belitung"
21	"Kep. Riau"
31	"DKI Jakarta"
32	"Jawa Barat"
33	"Jawa Tengah"
34	"DI Yogyakarta"
35	"Jawa Timur"
36	"Banten"
51	"Bali"
52	"Nusa Tenggara Barat"
53	"Nusa Tenggara Timur"
61	"Kalimantan Barat"
62	"Kalimantan Tengah"
63	"Kalimantan Selatan"
64	"Kalimantan Timur"
65  "Kalimantan Utara"
71	"Sulawesi Utara"
72	"Sulawesi Tengah"
73	"Sulawesi Selatan"
74	"Sulawesi Tenggara"
75	"Gorontalo"
76	"Sulawesi Barat"
81	"Maluku"
82	"Maluku Utara"
91	"Papua Barat"
94	"Papua" ;

#delimit cr

la val provcode provname

graph dot lasp_ffe2002-lasp_ffe2022 if urban==0, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-ffe-rural.png", replace
graph dot lasp_ffe2002-lasp_ffe2022 if urban==1, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-ffe-urban.png", replace

merge 1:1 provcode urban using `foodonly'
drop _merge

graph dot lasp_ffe2002 lasp_food2002 if urban==0, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-food-vs-ffe-rural-2002.png", replace
graph dot lasp_ffe2022 lasp_food2022 if urban==0, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-food-vs-ffe-rural-2022.png", replace

graph dot lasp_ffe2002 lasp_food2002 if urban==1, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-food-vs-ffe-urban-2002.png", replace
graph dot lasp_ffe2022 lasp_food2022 if urban==1, over(provcode) exclude0
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs-food-fuel-energy\laspeyres-food-vs-ffe-urban-2022.png", replace