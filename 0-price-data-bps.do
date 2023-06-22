clear
cd "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev"

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*.xls"
foreach file of local f {
    import excel using "`file'", sheet("Sheet1") allstring cellrange(B9:O90) clear
    generate fn = "`file'"
    save "`file'.dta", replace
}

local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*.xls"
foreach file of local f {
    import excel using "`file'", sheet("Sheet1") allstring cellrange(A2:A2) clear
    generate fn = "`file'"
    save "`file'-name.dta", replace
}

clear
local f: dir "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\from-BPS\Pub Harga 2019\Tabel Publikasi Perumahan 2019_rev" files "*.dta"
foreach file of local f {
    if "`file'" == "01-batu bata.xls" {
        use "`file'", clear
    }
    else {
        append using "`file'"
    }    
}
save "00-housing-compile.dta", replace

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
save "00-housing-compile-name.dta", replace

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
save "2019-dta\00-food-compile-name.dta", replace

** health education transportation name
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
save "2019-dta\00-het-compile-name.dta", replace
export excel "2019-dta\00-het-compile-name.xlsx", firstrow(variables) replace

** clothing name
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Sandang\01-22.xls"
save "Publikasi Sandang\01-22-name.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(A2:A2) allstring): append using "Publikasi Sandang\23-44.xls"
save "Publikasi Sandang\23-44-name.dta", replace

use "Publikasi Sandang\01-22-name.dta", clear
append using "Publikasi Sandang\23-44-name.dta"
save "2019-dta\00-clothing-compile-name.dta", replace

** price
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Makanan\2019-food-1-46.xlsx"
save "Publikasi Makanan\2019-food-1-46.dta", replace
clear
xls2dta, clear allsheets generate(fn comm) importopts(cellrange(B9:O90) allstring): append using "Publikasi Makanan\2019-food-47-93.xlsx"
save "Publikasi Makanan\2019-food-47-93.dta", replace

use "Publikasi Makanan\2019-food-1-46.dta", clear
append using "Publikasi Makanan\2019-food-47-93.dta"
save "2019-dta\00-food-compile.dta", replace