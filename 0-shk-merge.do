cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\excel-converted"

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\excel-converted" files "*.xlsx"
foreach file of local f {
    import excel using `"`file'"', firstrow clear
    rename *, lower
    rename tahun year
    rename average avg
    rename kota city
    save `"`file'"'.dta, replace    
    }    

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata\temp" files "*.dta"    
foreach file of local f {
    append using "`file'", force
    }
replace may=mei if missing(may)
drop mei    

save "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata\shk-rest.dta", replace

use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata\shk-rest.dta", clear

append using "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata\shk-2019-2021.dta"

foreach v of varlist jan-avg {
    replace `v' = strltrim(`v')
    replace `v' = stritrim(`v')
    replace `v' = strtrim(`v')
    replace `v' = strrtrim(`v')     
    replace `v' = subinstr(`v',",","",.)
    replace `v' = subinstr(`v'," ","",.)
    replace `v' = subinstr(`v',"-","",.)
}

replace city = regexr(city,"^[1−9][1-9][ ]+.","")
replace city = regexr(city,"^([0−9][0−9])","")
replace city = strltrim(city)
replace city = stritrim(city)
replace city = strtrim(city)
replace city = strrtrim(city)     
replace city = strltrim(city)
replace city = stritrim(city)
replace city = strtrim(city)
replace city = strrtrim(city)     
replace city = subinstr(city," ****)","",.)
replace city = subinstr(city," ***)","",.)
replace city = subinstr(city," **)","",.)
replace city = subinstr(city," *)","",.)
replace city = subinstr(city,"**)","",.)
replace city = subinstr(city,"*)","",.)
replace city = subinstr(city,")","",.)
replace city = subinstr(city,"*","",.)
replace city = subinstr(city," ***","",.)
replace city = strtrim(city)

drop if missing(year)
drop if missing(city)
drop if city=="`"
drop if city=="-"

replace city = "Lhokseumawe"      if city=="2 Lhokseumawe"
replace city = "Sibolga"          if city=="3 Sibolga"
replace city = "P. Siantar"       if city=="4 P. Siantar"
replace city = "Medan"            if city=="5 Medan"
replace city = "P. Sidempuan"     if city=="6 P. Sidempuan"
replace city = "Padang"           if city=="7 Padang"
replace city = "Pekanbaru"        if city=="8 Pekanbaru"
replace city = "Bandung"          if city=="20 Bandung"
replace city = "Cirebon"          if city=="2Cirebon"
replace city = "Bekasi"           if city=="22 Bekasi"
replace city = "Depok"            if city=="23 Depok"
replace city = "Tasikmalaya"      if city=="24 Tasikmalaya"
replace city = "Purwokerto"       if city=="25 Purwokerto"
replace city = "Surakarta"        if city=="26 Surakarta"
replace city = "Semarang"         if city=="27 Semarang"
replace city = "Tegal"            if city=="28 Tegal"
replace city = "Yogyakarta"       if city=="2Yogyakarta"
replace city = "Jember"           if city=="30 Jember"
replace city = "Sumenep"          if city=="3Sumenep"
replace city = "Kediri"           if city=="32 Kediri"
replace city = "Malang"           if city=="33 Malang"
replace city = "Probolinggo"      if city=="34 Probolinggo"
replace city = "Madiun"           if city=="35 Madiun"
replace city = "Surabaya"         if city=="36 Surabaya"
replace city = "Serang"           if city=="37 Serang"
replace city = "Tangerang"        if city=="38 Tangerang"
replace city = "Cilegon"          if city=="3Cilegon"
replace city = "Denpasar"         if city=="40 Denpasar"
replace city = "Mataram"          if city=="4Mataram"
replace city = "Bima"             if city=="42 Bima"
replace city = "Maumere"          if city=="43 Maumere"
replace city = "Kupang"           if city=="44 Kupang"
replace city = "Pontianak"        if city=="45 Pontianak"
replace city = "Singkawang"       if city=="46 Singkawang"
replace city = "Sampit"           if city=="47 Sampit"
replace city = "Palangkaraya"     if city=="48 Palangkaraya"
replace city = "Banjarmasin"      if city=="4Banjarmasin"
replace city = "Balikpapan"       if city=="50 Balikpapan"
replace city = "Samarinda"        if city=="5Samarinda"
replace city = "Tarakan"          if city=="52 Tarakan"
replace city = "Manado"           if city=="53 Manado"
replace city = "Palu"             if city=="54 Palu"
replace city = "Watampone"        if city=="55 Watampone"
replace city = "Makassar"         if city=="56 Makassar"
replace city = "Pare Pare"        if city=="57 Pare Pare"
replace city = "Palopo"           if city=="58 Palopo"
replace city = "Kendari"          if city=="5Kendari"
replace city = "Gorontalo"        if city=="60 Gorontalo"
replace city = "Mamuju"           if city=="6Mamuju"
replace city = "Ambon"            if city=="62 Ambon"
replace city = "Ternate"          if city=="63 Ternate"
replace city = "Manokwari"        if city=="64 Manokwari"
replace city = "Sorong"           if city=="65 Sorong"
replace city = "Jayapura"         if city=="66 Jayapura"
replace city = "Pekanbaru"         if city=="8 Pakanbaru"

replace city = "Lhokseumawe"      if city=="Hokseumawe"
replace city = "Lhokseumawe"      if city=="Lhokseumawe0"
replace city = "Banda Aceh"      if city=="Banda"
replace city = "Bandar Lampung"  if city=="Bandar"
replace city = "Baubau"          if city=="Bau-Bau"
replace city = "Palangka Raya"   if city=="Palangka"
replace city = "Palangka Raya"   if city=="Palangkaraya"
replace city = "Pangkalpinang"   if city=="Pangkal"
replace city = "Pangkalpinang"   if city=="Pangkal Pinang"
replace city = "Parepare"        if city=="Pare-Pare"
replace city = "Pematangsiantar" if city=="Pematang"
replace city = "Pematangsiantar" if city=="Pematang Sianta"
replace city = "Pematangsiantar" if city=="Pematang Siantar"
replace city = "Pematangsiantar" if city=="P. Siantar"
replace city = "Pematangsiantar" if city=="P.Siantar"
replace city = "Sampit"          if city=="Sampi"
replace city = "Tanjung Pinang"  if city=="Tanjungpinang"
replace city = "Jakarta"         if city=="DKI Jakarta"
replace city = "Jakarta"         if city=="DKI"
replace city = "Jakarta"         if city=="Dki Jakarta"
replace city = "Waingapu"        if city=="Waigapu"
replace city = "Kotabaru"        if city=="Kota baru"
replace city = "Bekasi"          if city=="BekasI"
replace city = "Dumai"           if city=="DumaI"
replace city = "Dumai"           if city=="D U M A I"
replace city = "Batam"           if city=="B A T A M"
replace city = "Padangsidimpuan" if city=="P. Sidempuan"
replace city = "Padangsidimpuan" if city=="Padangsidempuan"
replace city = "Pekanbaru"       if city=="Pakanbaru"
replace city = "Parepare"        if city=="Pare Pare"
replace city = "Purwokerto"      if city=="Purw Okerto"
replace city = "Banyuwangi"      if city=="Banyuw Angi"
replace city = "Singkawang"      if city=="Singkaw Ang"
replace city = "Manokwari"       if city=="Manokw Ari"
replace city = "Sukabumi"        if city=="Sukabumi 80"
replace city = "Sukabumi"        if city=="Sukabum i"
replace city = "Bengkulu"        if city=="Bengkulu0"
replace city = "Balikpapan"      if city=="Balikpapa"

replace city = "Banda Aceh"      if city=="BandaAceh"
replace city = "Pematangsiantar" if city=="PematangSiantar"
replace city = "Bandar Lampung"  if city=="BandarLampung"
replace city = "Tanjung Pandan"  if city=="TanjungPandan"
replace city = "Pangkalpinang"   if city=="PangkalPinang"
replace city = "Tanjung Pinang"  if city=="TanjungPinang"
replace city = "Palangka Raya"   if city=="PalangkaRaya"
replace city = "Banjarmasin"     if city=="Banjarmasi"

replace prov =	11	if city ==	"Meulaboh"
replace prov =	11	if city ==	"Banda Aceh"
replace prov =	11	if city ==	"Lhokseumawe"
replace prov =	12	if city ==	"Sibolga"
replace prov =	12	if city ==	"Pematangsiantar"
replace prov =	12	if city ==	"Medan"
replace prov =	12	if city ==	"Padangsidimpuan"
replace prov =	12	if city ==	"Gunungsitoli"
replace prov =	13	if city ==	"Padang"
replace prov =	13	if city ==	"Bukittinggi"
replace prov =	14	if city ==	"Tembilahan"
replace prov =	14	if city ==	"Pekanbaru"
replace prov =	14	if city ==	"Dumai"
replace prov =	15	if city ==	"Bungo"
replace prov =	15	if city ==	"Jambi"
replace prov =	16	if city ==	"Palembang"
replace prov =	16	if city ==	"Lubuklinggau"
replace prov =	17	if city ==	"Bengkulu"
replace prov =	18	if city ==	"Bandar Lampung"
replace prov =	18	if city ==	"Metro"
replace prov =	19	if city ==	"Tanjung Pandan"
replace prov =	19	if city ==	"Pangkalpinang"
replace prov =	21	if city ==	"Batam"
replace prov =	21	if city ==	"Tanjung Pinang"
replace prov =	31	if city ==	"Jakarta"
replace prov =	31	if city ==	"DKI Jakarta"
replace prov =	32	if city ==	"Bogor"
replace prov =	32	if city ==	"Sukabumi"
replace prov =	32	if city ==	"Bandung"
replace prov =	32	if city ==	"Cirebon"
replace prov =	32	if city ==	"Bekasi"
replace prov =	32	if city ==	"Depok"
replace prov =	32	if city ==	"Tasikmalaya"
replace prov =	33	if city ==	"Cilacap"
replace prov =	33	if city ==	"Purwokerto"
replace prov =	33	if city ==	"Kudus"
replace prov =	33	if city ==	"Surakarta"
replace prov =	33	if city ==	"Semarang"
replace prov =	33	if city ==	"Tegal"
replace prov =	34	if city ==	"Yogyakarta"
replace prov =	35	if city ==	"Jember"
replace prov =	35	if city ==	"Banyuwangi"
replace prov =	35	if city ==	"Sumenep"
replace prov =	35	if city ==	"Kediri"
replace prov =	35	if city ==	"Malang"
replace prov =	35	if city ==	"Probolinggo"
replace prov =	35	if city ==	"Madiun"
replace prov =	35	if city ==	"Surabaya"
replace prov =	36	if city ==	"Tangerang"
replace prov =	36	if city ==	"Cilegon"
replace prov =	36	if city ==	"Serang"
replace prov =	51	if city ==	"Singaraja"
replace prov =	51	if city ==	"Denpasar"
replace prov =	52	if city ==	"Mataram"
replace prov =	52	if city ==	"Bima"
replace prov =	53	if city ==	"Maumere"
replace prov =	53	if city ==	"Kupang"
replace prov =	53	if city ==	"Waingapu"    
replace prov =	61	if city ==	"Pontianak"
replace prov =	61	if city ==	"Singkawang"
replace prov =	61	if city ==	"Sintang"    
replace prov =	62	if city ==	"Sampit"
replace prov =	62	if city ==	"Palangka Raya"
replace prov =	62	if city ==	"Palangkaraya"
replace prov =	63	if city ==	"Tanjung"
replace prov =	63	if city ==	"Banjarmasin"
replace prov =	63	if city ==	"Kotabaru"    
replace prov =	64	if city ==	"Balikpapan"
replace prov =	64	if city ==	"Samarinda"
replace prov =	65	if city ==	"Tarakan"
replace prov =	65	if city ==	"Tanjung Selor"
replace prov =	71	if city ==	"Manado"
replace prov =	71	if city ==	"Kotamobagu"    
replace prov =	72	if city ==	"Palu"
replace prov =	72	if city ==	"Luwuk"    
replace prov =	73	if city ==	"Bulukumba"
replace prov =	73	if city ==	"Watampone"
replace prov =	73	if city ==	"Makassar"
replace prov =	73	if city ==	"Parepare"
replace prov =	73	if city ==	"Palopo"
replace prov =	74	if city ==	"Kendari"
replace prov =	74	if city ==	"Baubau"
replace prov =	75	if city ==	"Gorontalo"
replace prov =	76	if city ==	"Mamuju"
replace prov =	81	if city ==	"Ambon"
replace prov =	81	if city ==	"Tual"
replace prov =	82	if city ==	"Ternate"
replace prov =	91	if city ==	"Manokwari"
replace prov =	91	if city ==	"Sorong"
replace prov =	94	if city ==	"Merauke"
replace prov =	94	if city ==	"Timika"    
replace prov =	94	if city ==	"Jayapura"

save "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata\shk-price-2010-2022.dta", replace