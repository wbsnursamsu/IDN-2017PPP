	*----------------------------------------------------------------------*
	* MERGE
	*----------------------------------------------------------------------*
clear all

/* paasche */
foreach j in str reg {  
    foreach x in fo ps mx wr {
        forval t=2019/2021 {
            append using "${gdOutput}/paache-deflator-`j'-`t'-`x'.dta"
            replace year = `t' if year==.
        }
    save "${gdOutput}/paache-deflator-`j'-`x'-series.dta", replace    
    }
}

/* merge paache */
* stratum
use "${gdOutput}/paache-deflator-str-fo-series.dta", clear
    rename pdef_re pdef_re_fo_str
    rename pdef_hh pdef_hh_fo_str
merge 1:1 year prov urban using "${gdOutput}/paache-deflator-str-ps-series.dta", nogen
    rename pdef_re pdef_re_ps_str    
    rename pdef_hh pdef_hh_ps_str
merge 1:1 year prov urban using "${gdOutput}/paache-deflator-str-mx-series.dta", nogen
    rename pdef_re pdef_re_mx_str    
    rename pdef_hh pdef_hh_mx_str
merge 1:1 year prov urban using "${gdOutput}/paache-deflator-str-wr-series.dta", nogen
    rename pdef_re pdef_re_wr_str    
    rename pdef_hh pdef_hh_wr_str
    
la var pdef_re_fo_str "Paasche stratum lvl - regency uv - food hh"
la var pdef_re_ps_str "Paasche stratum lvl - regency uv - price svy"
la var pdef_re_mx_str "Paasche stratum lvl - regency uv - hh & price"
la var pdef_re_wr_str "Paasche stratum lvl - regency uv - hh & price & rent"

la var pdef_hh_fo_str "Paasche stratum lvl - hh uv - food hh"
la var pdef_hh_ps_str "Paasche stratum lvl - hh uv - price svy"
la var pdef_hh_mx_str "Paasche stratum lvl - hh uv - hh & price"
la var pdef_hh_wr_str "Paasche stratum lvl - hh uv - hh & price & rent"
    
order year urban prov pdef_re_fo_str pdef_re_ps_str pdef_re_mx_str pdef_re_wr_str pdef_hh_fo_str pdef_hh_ps_str pdef_hh_mx_str pdef_hh_wr_str
save "${gdOutput}/spatial-index-stratum.dta", replace


* municipality
use "${gdOutput}/paache-deflator-reg-fo-series.dta", clear
    rename pdef_re pdef_re_fo_reg
    rename pdef_hh pdef_hh_fo_reg
merge 1:1 year prov rege urban using "${gdOutput}/paache-deflator-reg-ps-series.dta", nogen
    rename pdef_re pdef_re_ps_reg    
    rename pdef_hh pdef_hh_ps_reg
merge 1:1 year prov rege urban using "${gdOutput}/paache-deflator-reg-mx-series.dta", nogen
    rename pdef_re pdef_re_mx_reg    
    rename pdef_hh pdef_hh_mx_reg
merge 1:1 year prov rege urban using "${gdOutput}/paache-deflator-reg-wr-series.dta", nogen
    rename pdef_re pdef_re_wr_reg    
    rename pdef_hh pdef_hh_wr_reg

la var pdef_re_fo_reg "Paasche regency lvl - regency uv - food hh"
la var pdef_re_ps_reg "Paasche regency lvl - regency uv - price svy"
la var pdef_re_mx_reg "Paasche regency lvl - regency uv - hh & price"
la var pdef_re_wr_reg "Paasche regency lvl - regency uv - hh & price & rent"

la var pdef_hh_fo_reg "Paasche regency lvl - hh uv - food hh"
la var pdef_hh_ps_reg "Paasche regency lvl - hh uv - price svy"
la var pdef_hh_mx_reg "Paasche regency lvl - hh uv - hh & price"
la var pdef_hh_wr_reg "Paasche regency lvl - hh uv - hh & price & rent"

order year urban prov pdef_re_fo_reg pdef_re_ps_reg pdef_re_mx_reg pdef_re_wr_reg pdef_hh_fo_reg pdef_hh_ps_reg pdef_hh_mx_reg pdef_hh_wr_reg
save "${gdOutput}/spatial-index-regency.dta", replace

//
// /* table */
// table (urban prov) () if year==2019, stat(mean pdef_re_fo pdef_re_ps pdef_re_mx pdef_re_wr pdef_hh_fo pdef_hh_ps pdef_hh_mx pdef_hh_wr) nformat(%3.2f) nototals
//     collect label levels urban 0 "Rural" 1 "Urban"
//    
//     # delimit ;
//     collect label levels prov 
//         11	"Nanggroe Aceh Darussalam"
//         12	"Sumatera Utara"
//         13	"Sumatera Barat"
//         14	"Riau"
//         15	"Jambi"
//         16	"Sumatera Selatan"
//         17	"Bengkulu"
//         18	"Lampung"
//         19	"Kep. Bangka Belitung"
//         21	"Kep. Riau"
//         31	"DKI Jakarta"
//         32	"Jawa Barat"
//         33	"Jawa Tengah"
//         34	"DI Yogyakarta"
//         35	"Jawa Timur"
//         36	"Banten"
//         51	"Bali"
//         52	"Nusa Tenggara Barat"
//         53	"Nusa Tenggara Timur"
//         61	"Kalimantan Barat"
//         62	"Kalimantan Tengah"
//         63	"Kalimantan Selatan"
//         64	"Kalimantan Timur"
//         65  "Kalimantan Utara"
//         71	"Sulawesi Utara"
//         72	"Sulawesi Tengah"
//         73	"Sulawesi Selatan"
//         74	"Sulawesi Tenggara"
//         75	"Gorontalo"
//         76	"Sulawesi Barat"
//         81	"Maluku"
//         82	"Maluku Utara"
//         91	"Papua Barat"
//         94	"Papua" ;
//     #delimit cr
//    
//     collect preview
//     putexcel set "${gdOutput}/0-index-comparison-2019.xlsx", sheet("index", replace) modify
//     putexcel B2 = collect

