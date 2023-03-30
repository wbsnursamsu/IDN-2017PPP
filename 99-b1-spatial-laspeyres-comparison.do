*** Check trend

** FOOD ONLY
use "${gdOutput}/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
tostring provcode_urban, replace
gen urban = substr(provcode_urban,3,2)
gen provcode = substr(provcode_urban,1,2)
destring urban provcode, replace
order provcode urban, first


*** Generate laspeyres trend by province
# delimit ;
label define r101
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

label define r105 1"Urban" 0"Rural"
label values urban r105

label values provcode r101

replace index=1.95 if index>=2

** Graph 
twoway line index year if urban==1, by(provcode) legend(size(small)) yscale(r(0.5 (0.5) 2)) xlabel(2002 (4) 2022)
graph export "${gdOutput}/Graphs/spatial index - urban.png", replace
twoway line index year if urban==0, by(provcode) legend(size(small)) yscale(r(0.5 (0.5) 2)) xlabel(2002 (4) 2022)
graph export "${gdOutput}/Graphs/spatial index - rural.png", replace


** FOOD FUEL ENERGY
use "${gdOutput}/Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 - ffe.dta", clear
tostring provcode_urban, replace
gen urban = substr(provcode_urban,3,2)
gen provcode = substr(provcode_urban,1,2)
destring urban provcode, replace
order provcode urban, first


*** Generate laspeyres trend by province
# delimit ;
label define r101
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

label define r105 1"Urban" 0"Rural"
label values urban r105

label values provcode r101

replace index=1.95 if index>=2

** Graph 
twoway line index year if urban==1, by(provcode) legend(size(small)) yscale(r(0.5 (0.5) 2)) xlabel(2002 (4) 2022)
graph export "${gdOutput}/Graphs-food-fuel-energy/spatial index - urban.png", replace
twoway line index year if urban==0, by(provcode) legend(size(small)) yscale(r(0.5 (0.5) 2)) xlabel(2002 (4) 2022)
graph export "${gdOutput}/Graphs-food-fuel-energy/spatial index - rural.png", replace