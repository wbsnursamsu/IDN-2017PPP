cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\"

forval t=2010/2022 {
    import excel using "excel\\`t'-shkp-clean.xlsx", firstrow allstring clear
    rename *, lower 
    save "excel\\`t'-shkp.dta", replace    
    }    
    
forval t=2010/2022 {
    append using "excel\\`t'-shkp.dta"
    save "stata\\shkp-2010-2022.dta", replace
    }

replace komoditas=items if missing(komoditas)
drop items
replace provinsi=kota if missing(provinsi)
drop kota
replace provinsi=city if missing(provinsi)
drop city 
replace apr=april if missing(apr)
drop april
replace jun=juni if missing(jun)
drop juni
rename mei may
replace jul=juli if missing(jul)
drop juli
replace aug=agustus if missing(aug)
drop agustus
replace sep=sept if missing(sep)
drop sept
replace dec=des if missing(dec)
drop des
replace year=tahun if missing(year)
drop tahun
replace average=ratarata if missing(average)
drop ratarata
replace unit=satuan if missing(unit)
drop satuan

drop r-au
order year provinsi komoditas unit, first
rename provinsi prov
rename average avg

destring year, replace
drop if missing(year)

foreach v of varlist komoditas unit {
    replace `v' = strltrim(`v')
    replace `v' = stritrim(`v')
    replace `v' = strtrim(`v')
    replace `v' = strrtrim(`v')     
}

foreach v of varlist jan-avg {
    replace `v' = strltrim(`v')
    replace `v' = stritrim(`v')
    replace `v' = strtrim(`v')
    replace `v' = strrtrim(`v')     
    replace `v' = subinstr(`v',",","",.)
    replace `v' = subinstr(`v'," ","",.)
    replace `v' = subinstr(`v',"-","",.)
}

replace prov = strltrim(prov)
replace prov = stritrim(prov)
replace prov = strtrim(prov)
replace prov = strrtrim(prov)     
replace prov = subinstr(prov," ****)","",.)
replace prov = subinstr(prov," ***)","",.)
replace prov = subinstr(prov," **)","",.)
replace prov = subinstr(prov," *)","",.)
replace prov = subinstr(prov,"**)","",.)
replace prov = subinstr(prov,"*)","",.)
replace prov = subinstr(prov,")","",.)
replace prov = subinstr(prov,"*","",.)
replace prov = subinstr(prov," ***","",.)
replace prov = "Kep. Riau" in 86229
replace prov = "Nanggroe Aceh Darussalam" if prov=="Aceh"
replace prov = "DI Yogyakarta" if prov=="D. I. Yogyakarta"
replace prov = "Kep. Riau" if prov=="Kepulauan Riau"
replace prov = "Kep. Bangka Belitung" if prov=="Kepulauan Bangka Belitung"

drop if prov=="Nasional/National"
drop if prov=="Nasional"
drop if prov=="Ganti Kualitas"
gen provcode=.
    replace provcode=11 if prov=="Nanggroe Aceh Darussalam"
    replace provcode=12 if prov=="Sumatera Utara"
    replace provcode=13 if prov=="Sumatera Barat"
    replace provcode=14 if prov=="Riau"
    replace provcode=15 if prov=="Jambi"
    replace provcode=16 if prov=="Sumatera Selatan"
    replace provcode=17 if prov=="Bengkulu"
    replace provcode=18 if prov=="Lampung"
    replace provcode=19 if prov=="Kep. Bangka Belitung"
    replace provcode=21 if prov=="Kep. Riau"
    replace provcode=31 if prov=="DKI Jakarta"
    replace provcode=32 if prov=="Jawa Barat"
    replace provcode=33 if prov=="Jawa Tengah"
    replace provcode=34 if prov=="DI Yogyakarta"
    replace provcode=35 if prov=="Jawa Timur"
    replace provcode=36 if prov=="Banten"
    replace provcode=51 if prov=="Bali"
    replace provcode=52 if prov=="Nusa Tenggara Barat"
    replace provcode=53 if prov=="Nusa Tenggara Timur"
    replace provcode=61 if prov=="Kalimantan Barat"
    replace provcode=62 if prov=="Kalimantan Tengah"
    replace provcode=63 if prov=="Kalimantan Selatan"
    replace provcode=64 if prov=="Kalimantan Timur"
    replace provcode=65 if prov==  "Kalimantan Utara"
    replace provcode=71 if prov=="Sulawesi Utara"
    replace provcode=72 if prov=="Sulawesi Tengah"
    replace provcode=73 if prov=="Sulawesi Selatan"
    replace provcode=74 if prov=="Sulawesi Tenggara"
    replace provcode=75 if prov=="Gorontalo"
    replace provcode=76 if prov=="Sulawesi Barat"
    replace provcode=81 if prov=="Maluku"
    replace provcode=82 if prov=="Maluku Utara"
    replace provcode=91 if prov=="Papua Barat"
    replace provcode=94 if prov=="Papua"
    
save "stata\\shkp-2010-2022-clean.dta", replace