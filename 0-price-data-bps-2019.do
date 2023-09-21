clear

*** Convert data ***
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\"

** name
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Makanan\2019-food-1-46.xlsx"
save "Publikasi Makanan\2019-food-1-46-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Makanan\2019-food-47-93.xlsx"
save "Publikasi Makanan\2019-food-47-93-name.dta", replace

use "Publikasi Makanan\2019-food-1-46-name.dta", clear
append using "Publikasi Makanan\2019-food-47-93-name.dta"
g category = "food"
g ihkcode19 = strofreal(_n) 
g ihkcat19 = category + "-" + ihkcode19
save "2019-dta\00-food-compile-name.dta", replace

* health education transportation name
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\01-20.xlsx"
save "Publikasi Makanan\2019-het-01-20-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\21-41.xlsx"
save "Publikasi Makanan\2019-het-21-41-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B2:B2) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\42-60.xlsx"
rename B A
save "Publikasi Makanan\2019-het-42-60-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B2:B2) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\61-82.xlsx"
rename B A
save "Publikasi Makanan\2019-het-61-82-name.dta", replace

use "Publikasi Makanan\2019-het-01-20-name.dta", clear
append using "Publikasi Makanan\2019-het-21-41-name.dta"
append using "Publikasi Makanan\2019-het-42-60-name.dta"
append using "Publikasi Makanan\2019-het-61-82-name.dta"
g category = "het"
g ihkcode19 = strofreal(_n) 
g ihkcat19 = category + "-" + ihkcode19
save "2019-dta\00-het-compile-name.dta", replace
export excel "2019-dta\00-het-compile-name.xlsx", firstrow(variables) replace

* clothing name
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Sandang\01-22.xls"
save "Publikasi Sandang\01-22-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Sandang\23-44.xls"
save "Publikasi Sandang\23-44-name.dta", replace

use "Publikasi Sandang\01-22-name.dta", clear
append using "Publikasi Sandang\23-44-name.dta"
g category = "clothing"
g ihkcode19 = strofreal(_n) 
g ihkcat19 = category + "-" + ihkcode19
save "2019-dta\00-clothing-compile-name.dta", replace

* housing name
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev"

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*.xls"
foreach file of local f {
    import excel using "`file'", sheet("Sheet1") allstring cellrange(A2:A2) clear
    generate fn = "`file'"
    save "`file'-name.dta", replace
}

clear
local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*-name.dta"
foreach file of local f {
    if "`file'" == "01-batu bata.xls-name" {
        use "`file'", clear
    }
    else {
        append using "`file'"
    }    
}
g category = "housing"
g ihkcode19 = strofreal(_n) 
g ihkcat19 = category + "-" + ihkcode19
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\"
save "2019-dta\00-housing-compile-name.dta", replace

** price
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\"

* food
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Makanan\2019-food-1-46.xlsx"
save "Publikasi Makanan\2019-food-1-46.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Makanan\2019-food-47-93.xlsx"
save "Publikasi Makanan\2019-food-47-93.dta", replace

use "Publikasi Makanan\2019-food-1-46.dta", clear
append using "Publikasi Makanan\2019-food-47-93.dta"
save "2019-dta\00-food-compile.dta", replace

* clothing
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Sandang\01-22.xls"
save "Publikasi Sandang\01-22.dta", replace
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Sandang\23-44.xls"
save "Publikasi Sandang\23-44.dta", replace

use "Publikasi Sandang\01-22.dta", clear
append using "Publikasi Sandang\23-44.dta"
save "2019-dta\00-clothing-compile.dta", replace

* het
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\01-20.xlsx"
save "Publikasi Kesehatan Pendidikan Transpor\01-20-price.dta", replace
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\21-41.xlsx"
save "Publikasi Kesehatan Pendidikan Transpor\21-41-price.dta", replace
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(C9:P90) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\42-60.xlsx"
rename C B
rename D C
rename E D
rename F E
rename G F
rename H G
rename I H
rename J I
rename K J
rename L K
rename M L
rename N M
rename O N
rename P O
save "Publikasi Kesehatan Pendidikan Transpor\42-60-price.dta", replace
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(C9:P90) allstring): append using "Publikasi Kesehatan Pendidikan Transpor\61-82.xlsx"
rename C B
rename D C
rename E D
rename F E
rename G F
rename H G
rename I H
rename J I
rename K J
rename L K
rename M L
rename N M
rename O N
rename P O
save "Publikasi Kesehatan Pendidikan Transpor\61-82-price.dta", replace

use "Publikasi Kesehatan Pendidikan Transpor\01-20-price.dta", clear
append using "Publikasi Kesehatan Pendidikan Transpor\21-41-price.dta"
append using "Publikasi Kesehatan Pendidikan Transpor\42-60-price.dta"
append using "Publikasi Kesehatan Pendidikan Transpor\61-82-price.dta"
save "2019-dta\00-het-compile.dta", replace

* housing
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev"

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*.xls"
foreach file of local f {
    import excel using "`file'", sheet("Sheet1") allstring cellrange(B9:O90) clear
    generate fn = "`file'"
    save "`file'-price.dta", replace
}

clear
local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*-price.dta"
foreach file of local f {
    if "`file'" == "01-batu bata-price.xls" {
        use "`file'", clear
    }
    else {
        append using "`file'"
    }    
}
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\"
save "2019-dta\00-housing-compile-price.dta", replace


/**** Merge price data with name ****/
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\2019-dta"

use "00-clothing-compile.dta", clear
merge m:1 comm using "00-clothing-compile-name.dta", nogen
save "00-clothing-price.dta", replace

use "00-food-compile.dta", clear
merge m:1 comm using "00-food-compile-name.dta", nogen
save "00-food-price.dta", replace

use "00-het-compile.dta", clear
merge m:1 comm using "00-het-compile-name.dta", nogen
save "00-het-price.dta", replace

use "00-housing-compile-price.dta", clear
merge m:1 fn using "00-housing-compile-name.dta", nogen
rename fn comm
save "00-housing-price.dta", replace

/* Merge all price data */
use "00-clothing-price.dta", clear  
append using "00-food-price.dta"
append using "00-het-price.dta"
append using "00-housing-price.dta"

order A, first
rename A itemname
rename B city
rename C jan
rename D feb
rename E mar
rename F apr
rename G may
rename H jun
rename I jul
rename J aug 
rename K sep
rename L oct
rename M nov
rename N dec
rename O avg

replace city = subinstr(city," ****)","",.)
replace city = subinstr(city," ***)","",.)
replace city = subinstr(city," **)","",.)
replace city = subinstr(city," *)","",.)
replace city = subinstr(city,"**)","",.)
replace city = subinstr(city,"*)","",.)
replace city = subinstr(city,")","",.)
replace city = strtrim(city)

replace city = "Banda Aceh"      if city=="Banda"
replace city = "Bandar Lampung"  if city=="Bandar"
replace city = "Baubau"          if city=="Bau-Bau"
replace city = "Palangkaraya"    if city=="Palangka"
replace city = "Pangkalpinang"   if city=="Pangkal"
replace city = "Pangkalpinang"   if city=="Pangkal Pinang"
replace city = "Parepare"        if city=="Pare-Pare"
replace city = "Pematangsiantar" if city=="Pematang"
replace city = "Pematangsiantar" if city=="Pematang Sianta"
replace city = "Pematangsiantar" if city=="Pematang Siantar"
replace city = "Sampit"          if city=="Sampi"
replace city = "Tanjung Pinang"  if city=="Tanjungpinang"

gen prov = .
    replace prov =	11	if city ==	"Meulaboh"
    replace prov =	11	if city ==	"Banda Aceh"
    replace prov =	11	if city ==	"Lhokseumawe"
    replace prov =	12	if city ==	"Sibolga"
    replace prov =	12	if city ==	"Pematangsiantar"
    replace prov =	12	if city ==	"Medan"
    replace prov =	12	if city ==	"Padangsidimpuan"
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
    replace prov =	61	if city ==	"Pontianak"
    replace prov =	61	if city ==	"Singkawang"
    replace prov =	62	if city ==	"Sampit"
    replace prov =	62	if city ==	"Palangka Raya"
    replace prov =	63	if city ==	"Tanjung"
    replace prov =	63	if city ==	"Banjarmasin"
    replace prov =	64	if city ==	"Balikpapan"
    replace prov =	64	if city ==	"Samarinda"
    replace prov =	65	if city ==	"Tarakan"
    replace prov =	71	if city ==	"Manado"
    replace prov =	72	if city ==	"Palu"
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
    replace prov =	94	if city ==	"Jayapura"
    
save "00-shk-price-2019.dta", replace




































































