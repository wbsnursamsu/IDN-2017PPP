
foreach t in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
    if `t'== 02 {
        use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\paache-deflator-`t'.dta", clear
        gen year=2002
    }
    else {
        append using "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\paache-deflator-`t'.dta"
        replace year=20*100+`t' if year==.
    }
}

gen provcode_urban = region*100+urban
rename rdef paache_index

tempfile paache
save `paache', replace

use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Laspeyres Spatial 2002-2022 Prov-UR Demshare - NatUrbanP0 - v5 do-file.dta", clear
rename index laspeyres_index
merge 1:1 provcode_urban year using `paache'
drop _merge

tostring provcode_urban, replace
gen prov = substr(provcode_urban,1,2)
destring prov, replace

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

label values prov r101

** graphs
forval t=2002/2022 {
    graph dot laspeyres_index paache_index if urban==1 & year==`t', over(prov) saving(gurban, replace)
    graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs\laspeyres-paache-comparison-urban-`t'.png", replace
    graph dot laspeyres_index paache_index if urban==0 & year==`t', over(prov) saving(grural, replace)
    graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs\laspeyres-paache-comparison-rural-`t'.png", replace
    grc1leg2 gurban.gph grural.gph, r(1) c(2) ycom xcom iscale(0.75) ysize(3) xsize(4) graphregion(color(white)) title("Year = `t'") scale(0.75)
    graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\Graphs\laspeyres-paache-comparison-`t'.png", replace	
}

la var laspeyres_index "Laspeyres Index"
la var paache_index "Paache Index"    
** table
forval t=2002/2022 {
    table (prov) if year==`t' & urban==1, stat(mean laspeyres_index paache_index) nototals nformat(%5.4f)
    * save
        if `t'==2002 {
            putexcel set "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\spatial-paache-laspeyres-comparison.xlsx", sheet("`t'") replace
        }
        else {
            putexcel set "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\spatial-paache-laspeyres-comparison.xlsx", sheet("`t'") modify
        }
        putexcel B3 = collect
        putexcel B2 = "Urban & Year = `t'"
    table (prov) if year==`t' & urban==0, stat(mean laspeyres_index paache_index) nototals nformat(%5.4f)
    * save
            putexcel set "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\spatial-paache-laspeyres-comparison.xlsx", sheet("`t'") modify
        putexcel H3 = collect
        putexcel H2 = "Rural & Year = `t'"        
}

** line
#delimit ;
twoway (line laspeyres_index year if urban==1 & prov==94, lp(solid) lcol(maroon) lw(medthick)) 
       (line paache_index year if urban==1 & prov==94, lp(solid) lcol(navy) lw(medthick)) 
       (line laspeyres_index year if urban==0 & prov==94, lp(dash_dot) lcol(maroon) lw(medthick)) 
       (line paache_index year if urban==0 & prov==94, lp(dash_dot) lcol(navy) lw(medthick))
       , title("Laspeyres vs Paache, Papua") 
       legend(label(1 "Laspeyres Urban") label(2 "Paache Urban") label(3 "Laspeyres Rural") label(4 "Paache Rural")) ;
#delimit cr
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\spatial-paache-laspeyres-trend-papua.png", replace

#delimit ;
twoway (line laspeyres_index year if urban==1 & prov==91, lp(solid) lcol(maroon) lw(medthick)) 
       (line paache_index year if urban==1 & prov==91, lp(solid) lcol(navy) lw(medthick))
       (line laspeyres_index year if urban==0 & prov==91, lp(dash_dot) lcol(maroon) lw(medthick)) 
       (line paache_index year if urban==0 & prov==91, lp(dash_dot) lcol(navy) lw(medthick))       
       , title("Laspeyres vs Paache, Papua Barat") 
       legend(label(1 "Laspeyres Urban") label(2 "Paache Urban") label(3 "Laspeyres Rural") label(4 "Paache Rural"));
#delimit cr       
graph export "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\spatial-paache-laspeyres-trend-papbar.png", replace

order provcode_urban prov urban laspeyres_index paache_index 
save "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\paache-laspeyres-index.dta", replace
export excel "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output\paache-laspeyres-index.xlsx", firstrow(variables) replace
