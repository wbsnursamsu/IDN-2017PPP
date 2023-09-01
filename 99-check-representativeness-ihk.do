
drop if code18==.
duplicates tag ihkcat19, gen(dup)
bys ihkcat19: gen duplicate = 1 if dup>0
drop dup

** check included susenas commodities
preserve
    duplicates drop code18, force
    keep code18 name18
    gen select=1
    tempfile selectsus
    save `selectsus', replace
restore

** use
use "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Temp\0-sus-spatial-cons-2019.dta", clear
merge m:1 code18 using `selectsus'

collapse (sum) v, by(ditem_all select)