clear

*** Convert data ***
gl res "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\2020-bps"

/* food */
    cd "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi HK Kelp Makanan"

    ** food name
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi HK Kelp Makanan" files "*.xlsx"
    local rep=0
    foreach file of local f {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using `"`file'"'
        save "`rep'-name.dta", replace
        }

    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi HK Kelp Makanan" files "*-name.dta"
    foreach file of local f {
        if `"`file'"'=="1-name.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    drop if A==""
    drop if A=="2"
    save "food-name.dta", replace
    save "${res}\food-name.dta", replace

    ** food price
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi HK Kelp Makanan" files "*.xlsx"
    local rep=0
    foreach file in `f' {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear sheets("*.*" | "*-*") generate(fn comm) importopts(cellrange(B9:O98) allstring): append using `"`file'"'
        save "`rep'-price.dta", replace
        }

    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi HK Kelp Makanan" files "*-price.dta"
    foreach file of local f {
        if `"`file'"'=="1-price.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    save "food-price.dta", replace
    save "${res}\food-price.dta", replace


/* het */
    cd "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Kesehatan, Pendidikan dan Transportasi 2020"

    ** het name
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "01-20 up (r) ok.xlsx"
    save "1-name.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "21-41 up (r) ok.xlsx"
    save "2-name.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B2:B2) allstring): append using "42-60 up (r) ok.xlsx"
    rename B A
    save "3-name.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B2:B2) allstring): append using "61-84 up (r) ok.xlsx"
    rename B A
    save "4-name.dta", replace

    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Kesehatan, Pendidikan dan Transportasi 2020" files "*-name.dta"
    foreach file of local f {
        if `"`file'"'=="1-name.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    save "het-name.dta", replace
    save "${res}\het-name.dta", replace

    ** het price
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O98) allstring): append using "01-20 up (r) ok.xlsx"
    save "1-price.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O98) allstring): append using "21-41 up (r) ok.xlsx"
    save "2-price.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(C9:P98) allstring): append using "42-60 up (r) ok.xlsx"
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
    save "3-price.dta", replace
    xls2dta, clear allsheets generate(fn comm) importopts(cellrange(C9:P98) allstring): append using "61-84 up (r) ok.xlsx"
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
    save "4-price.dta", replace

    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Kesehatan, Pendidikan dan Transportasi 2020" files "*-price.dta"
    foreach file of local f {
        if `"`file'"'=="1-price.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    save "het-price.dta", replace
    save "${res}\het-price.dta", replace

    
/* housing */
    cd "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Perumahan 2020"

    ** housing name
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Perumahan 2020" files "*.xls"
    local rep=0
    foreach file of local f {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear sheets("Sheet1") generate(fn comm) importopts(cellrange(A2:A2) allstring): append using `"`file'"'
        save "`rep'-name.dta", replace    
        }    
    xls2dta, clear sheets("2020") generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "KURSI(r) (1)-26.xlsx"
    save "26-name.dta", replace
    xls2dta, clear sheets("2020") generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "LEMARI PAKAIAN (r) (1)-27.xlsx"
    save "27-name.dta", replace        
        
local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Perumahan 2020" files "*-name.dta"
    foreach file of local f {
        if `"`file'"'=="1-name.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }
    save "housing-name.dta", replace
    save "${res}\housing-name.dta", replace

    ** housing price
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Perumahan 2020" files "*.xls"
    local rep=0
    foreach file in `f' {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear sheets("Sheet1") generate(fn comm) importopts(cellrange(B9:O98) allstring): append using `"`file'"'
        save "`rep'-price.dta", replace
        }
    xls2dta, clear sheets("2020") generate(fn comm) importopts(cellrange(B9:O98) allstring): append using "KURSI(r) (1)-26.xlsx"
    save "26-price.dta", replace
    xls2dta, clear sheets("2020") generate(fn comm) importopts(cellrange(B9:O98) allstring): append using "LEMARI PAKAIAN (r) (1)-27.xlsx"
    save "27-price.dta", replace  
    
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Perumahan 2020" files "*-price.dta"
    foreach file of local f {
        if `"`file'"'=="1-price.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    save "housing-price.dta", replace
    save "${res}\housing-price.dta", replace


/* clothing */
    cd "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Sandang"

    ** clothing name
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Sandang" files "*.xls"
    local rep=0
    foreach file of local f {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using `"`file'"'
        save "`rep'-name.dta", replace    
        }    

local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Sandang" files "*-name.dta"
    foreach file of local f {
        if `"`file'"'=="1-name.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }
    save "clothing-name.dta", replace
    save "${res}\clothing-name.dta", replace

    ** clothing price
    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Sandang" files "*.xls"
    local rep=0
    foreach file in `f' {
        local rep=`rep'+1
        di `rep'
        xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O98) allstring): append using `"`file'"'
        save "`rep'-price.dta", replace
        }

    local f: dir "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\Publikasi Sandang" files "*-price.dta"
    foreach file of local f {
        if `"`file'"'=="1-price.dta" {
            use "`file'", replace
            }
        else {
            append using "`file'"
            }
        }    
    save "clothing-price.dta", replace
    save "${res}\clothing-price.dta", replace


/**** Merge price data with name ****/
cd "C:\Users\wb594719\OneDrive - WBG\Documents\price\2020_PUBLIKASI HARGA\2020-bps"

use "clothing-name.dta", clear
rename A com_name
merge 1:m fn comm using "clothing-price.dta", nogen
drop if A!=""
drop A
save "clothing-data.dta", replace

use "food-name.dta", clear
rename A com_name
merge 1:m fn comm using "food-price.dta", nogen
save "food-data.dta", replace

use "het-name.dta", clear
rename A com_name
merge 1:m fn comm using "het-price.dta", nogen
save "het-data.dta", replace

use "housing-name.dta", clear
rename A com_name
duplicates drop
merge 1:m fn comm using "housing-price.dta", nogen
save "housing-data.dta", replace

/* Merge all price data */
use "clothing-data.dta", clear  
append using "food-data.dta"
append using "het-data.dta"
append using "housing-data.dta"

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
replace city = subinstr(city,"*","",.)
replace city = subinstr(city," ***","",.)
replace city = strtrim(city)

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
replace city = "Sampit"          if city=="Sampi"
replace city = "Tanjung Pinang"  if city=="Tanjungpinang"
replace city = "Jakarta"         if city=="DKI Jakarta"
replace city = "Waingapu"        if city=="Waigapu"
replace city = "Kotabaru"        if city=="Kota baru"
replace city = "Bekasi"          if city=="BekasI"

gen prov = .
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

gen year=2020    
save "00-shk-price-2020.dta", replace




































































