
    * -------------------------------------------------------------------- *
    * Setup price data from price survey to HH
    * -------------------------------------------------------------------- *
    
clear all
set more off

    /* SHK */

    *--------- 1. Select consistent commodities ---------*

use "${gdCrsw}/shk-concordance-v6-select.dta", clear
keep komoditas*
rename komoditas_all comm_all
duplicates drop
reshape long komoditas, i(comm_all) j(year)
drop if missing(komoditas)
save "${gdCrsw}/shk-concordance-v6-sreshape.dta", replace

    *--------- 2. Intrapolate & Extrapolate missing values ---------*

* set and merge data
use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Consumer price survey\stata/shk-price-2010-2022.dta", clear
replace komoditas=lower(komoditas)
replace komoditas=strltrim(komoditas)
replace komoditas=stritrim(komoditas)
replace komoditas=strrtrim(komoditas)
replace komoditas=strtrim(komoditas)
duplicates drop 

merge m:1 komoditas year using "${gdCrsw}/shk-concordance-v6-sreshape.dta" 
    drop if _merge!=3   // unmatched represent inconsistent items (missing more than 4 year data)
    drop _merge
order year comm_all komoditas unit prov city, first 

ren jan p1
ren feb p2
ren mar p3
ren apr p4
ren may p5
ren jun p6
ren jul p7
ren aug p8
ren sep p9
ren oct p10
ren nov p11
ren dec p12

drop avg komoditas unit 
sort comm_all prov city year

* clean data 
forval m=1/12 {
    replace p`m' = p`m'*1000 if p`m'<100           				// data is incorrectly identify thousands as decimals
	replace p`m' = p`m'/1000 if comm_all=="car" & year==2022	// car in 2022 changed to 000unit for consistency
    }
compress
    
* SAVE BEFORE INTERPOLATE
save "${gdTemp}/shk-raw-2010-2022.dta", replace

	*----- 2.1. intrapolate missing monthly data by month trend
	
greshape long p, i(year comm_all prov city) j(month)
bys year comm_all prov city: mipolate p month, gen(p1) forward
bys year comm_all prov city: mipolate p month, gen(p2) backward
bys year comm_all prov city: mipolate p month, gen(p3) nearest
replace p=p1 if missing(p)
replace p=p2 if missing(p)
replace p=p3 if missing(p)
drop p1 p2 p3
		
	*----- 2.2. intrapolate missing monthly and all data by year trend (IN PROVINCE LEVEL)
	
greshape wide p,i(year comm_all prov city) j(month)

* collapse to province level
forval v=1/12 {
	egen g`v' = gmean(p`v'), by(year prov comm_all)
	}
gcollapse (mean) g*, by(year prov comm_all)
renvars g1-g12,presub(g p)

* fill symmetrical data
fillin year prov comm_all 
drop _fillin

* interpolate stuffs
forval m=1/12 {
    bys comm_all prov: mipolate p`m' year, gen(p`m'_1) forward
	bys comm_all prov: mipolate p`m' year, gen(p`m'_2) backward
	bys comm_all prov: mipolate p`m' year, gen(p`m'_3) nearest
    replace p`m'=p`m'_1 if missing(p`m')
	replace p`m'=p`m'_2 if missing(p`m')
	replace p`m'=p`m'_3 if missing(p`m')
    drop p`m'_*
    }
egen pa = rowmean(p1-p12)                   // average monthly price
sort comm_all prov year
duplicates drop

*merge to get item subgroups
preserve 	
	use "${gdCrsw}/shk-concordance-v6-select.dta", clear
	keep ditem_all komoditas_all
	duplicates drop
	rename komoditas_all comm_all
	tempfile file0
	save `file0', replace
restore
	
merge m:1 comm_all using `file0', keepusing(ditem_all)
	keep if _merge==3
	drop _merge

order year ditem_all comm_all prov, first
save "${gdOutput}/shk-prov-comm-2010-2022.dta", replace

    *--------- 3. Save longform for price data analysis ---------* 

use "${gdOutput}/shk-prov-comm-2010-2022.dta", clear
greshape long p, i(year ditem_all comm_all prov) j(month)

* generate monthly date
gen mdate = ym(year,month)
format mdate %tm
order year month mdate ditem_all comm_all prov, first
save "${gdOutput}/shk-prov-comm-2010-2022-long.dta", replace
			
    *--------- 4. Save for spatial deflator works ---------* 

forval t=2010/2022 {
    use "${gdTemp}\shk-concordance-`t'.dta", clear
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas_all: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop code_c, force
        gen urban=1
        save "${gdTemp}\shk-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    drop code_2 
    duplicates drop komoditas_all, force
    rename komoditas_all comm_all
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "${gdOutput}/shk-prov-comm-2010-2022.dta", clear
        keep if year==`t'
        
    * geometric mean commodities 
        merge m:1 comm_all using `crwunique', keepusing(comm_all code_c)
            drop if _merge!=3
            drop _merge

        forval j=1/12 {
            egen p_`j' = gmean(p`j'), by(prov code_c)
        }            
    collapse (mean) p_*, by(year prov code_c)
    
    rename prov provcode
    rename code_c kode
    
    compress
    save "${gdTemp}/shk-price-prov-bpscode-`t'.dta", replace
    }    

/* merge SHK for spatial deflator */
clear
use "${gdTemp}/shk-price-prov-bpscode-2010.dta", clear

forval t=2011/2022 {
    append using "${gdTemp}/shk-price-prov-bpscode-`t'.dta"
    }

gen urban=1                                             // SHK
order year provcode urban, first
save "${gdTemp}/shk-price-prov-bpscode-ALL.dta", replace

			
*------------------------------------------------------------------------------*


    /* SHKP */

    *--------- 1. Select consistent commodities ---------*

use "${gdCrsw}/shkp-concordance-v4-select.dta", clear
keep komoditas*
rename komoditas_all comm_all
duplicates drop
reshape long komoditas, i(comm_all) j(year)
drop if missing(komoditas)
save "${gdCrsw}/shkp-concordance-v4-sreshape.dta", replace

    *--------- 2. Intrapolate & Extrapolate missing values ---------*

* set and merge data
use "C:\Users\wb594719\OneDrive - WBG\EEAPV IDN Documents\Village consumer price\stata/shkp-2010-2022-clean.dta", clear
replace komoditas=lower(komoditas)
replace komoditas=strltrim(komoditas)
replace komoditas=stritrim(komoditas)
replace komoditas=strrtrim(komoditas)
replace komoditas=strtrim(komoditas)
duplicates drop 

merge m:1 komoditas year using "${gdCrsw}/shkp-concordance-v4-sreshape.dta" 
    drop if _merge!=3   // unmatched represent inconsistent items (missing more than 4 year data)
    drop _merge
order year comm_all komoditas unit prov provcode, first 

ren jan p1
ren feb p2
ren mar p3
ren apr p4
ren may p5
ren jun p6
ren jul p7
ren aug p8
ren sep p9
ren oct p10
ren nov p11
ren dec p12

duplicates drop
drop avg komoditas unit 
sort comm_all prov provcode year

* clean data 
forval m=1/12 {
    replace p`m' = p`m'*1000 if p`m'<100           				// if data is incorrectly identify thousands as decimals
    replace p`m' = . if year==2013                              // 2013 SHKP publication is skipped/missing
    }
compress

* SAVE BEFORE INTERPOLATE
save "${gdTemp}/shkp-raw-2010-2022.dta", replace
    
	*----- 2.1. intrapolate missing monthly data by month trend
use "${gdTemp}/shkp-raw-2010-2022.dta", clear
drop prov 
rename provcode prov 
	
greshape long p, i(year comm_all prov) j(month)
bys year comm_all prov: mipolate p month, gen(p1) forward
bys year comm_all prov: mipolate p month, gen(p2) backward
bys year comm_all prov: mipolate p month, gen(p3) nearest
replace p=p1 if missing(p)
replace p=p2 if missing(p)
replace p=p3 if missing(p)
drop p1 p2 p3
		
	*----- 2.2. intrapolate missing monthly and all data by year trend (IN PROVINCE LEVEL)
	
greshape wide p,i(year comm_all prov) j(month)

* collapse to province level
forval v=1/12 {
	egen g`v' = gmean(p`v'), by(year prov comm_all)
	}
gcollapse (mean) g*, by(year prov comm_all)
renvars g1-g12,presub(g p)

* fill symmetrical data
fillin year prov comm_all 
drop _fillin

* interpolate stuffs
forval m=1/12 {
    bys comm_all prov: mipolate p`m' year, gen(p`m'_1) forward
	bys comm_all prov: mipolate p`m' year, gen(p`m'_2) backward
	bys comm_all prov: mipolate p`m' year, gen(p`m'_3) nearest
    replace p`m'=p`m'_1 if missing(p`m')
	replace p`m'=p`m'_2 if missing(p`m')
	replace p`m'=p`m'_3 if missing(p`m')
    drop p`m'_*
    }
egen pa = rowmean(p1-p12)                   // average monthly price
sort comm_all prov year
duplicates drop

*merge to get item subgroups
preserve 	
	use "${gdCrsw}/shkp-concordance-v4-select.dta", clear
	keep ditem_all komoditas_all
	duplicates drop
	rename komoditas_all comm_all
	tempfile file0
	save `file0', replace
restore
	
merge m:1 comm_all using `file0', keepusing(ditem_all)
	keep if _merge==3
	drop _merge

order year ditem_all comm_all prov, first
save "${gdOutput}/shkp-prov-comm-2010-2022.dta", replace

    *--------- 3. Save longform for price data analysis ---------* 

use "${gdOutput}/shkp-prov-comm-2010-2022.dta", clear
greshape long p, i(year ditem_all comm_all prov) j(month)

* generate monthly date
gen mdate = ym(year,month)
format mdate %tm
order year month mdate ditem_all comm_all prov, first
save "${gdOutput}/shkp-prov-comm-2010-2022-long.dta", replace			

    *--------- 4. Save for spatial deflator works ---------* 

forval t=2010/2022 {
    use "${gdTemp}\shkp-concordance-`t'.dta", clear
    drop if code_c==.
    
    g code_2 = code_c
    bys komoditas: replace code_2 = code_c[1]
    
    /* for cons hh data - replace code18 with code_2 and collapse */
    preserve
        keep code_c code_2
        duplicates drop code_c, force
        gen urban=0
        save "${gdTemp}\shkp-adjust-`t'.dta", replace
    restore
        
    replace code_c = code_2
    drop code_2 
    duplicates drop komoditas_all, force
    rename komoditas_all comm_all
    
    tempfile crwunique
    save `crwunique', replace

/*** merge price to crosswalk ***/
    
    *summing price survey data    
        use "${gdOutput}/shkp-prov-comm-2010-2022.dta", clear
        keep if year==`t'
        
    * geometric mean commodities 
        merge m:1 comm_all using `crwunique', keepusing(comm_all code_c)
            drop if _merge!=3
            drop _merge

        forval j=1/12 {
            egen p_`j' = gmean(p`j'), by(prov code_c)
        }            
    collapse (mean) p_*, by(year prov code_c)

    rename prov provcode    
    rename code_c kode
    
    drop if missing(provcode)
    compress
    save "${gdTemp}/shkp-price-prov-bpscode-`t'.dta", replace
    }    

/* merge SHK for spatial deflator */
clear
use "${gdTemp}/shkp-price-prov-bpscode-2010.dta", clear

forval t=2011/2022 {
    append using "${gdTemp}/shkp-price-prov-bpscode-`t'.dta"
    }

gen urban=0                                             // SHKP
order year provcode urban, first
save "${gdTemp}/shkp-price-prov-bpscode-ALL.dta", replace			
			
			
*------------------------------------------------------------------------------*
			
    /* APPEND EVERYTHING */
    
use "${gdTemp}/shk-price-prov-bpscode-ALL.dta", clear 
append using "${gdTemp}/shkp-price-prov-bpscode-ALL.dta"

foreach v of varlist p_1-p_12 {
	replace `v'=. if `v'==0
	}

sort year provcode urban kode	
save "${gdOutput}/price-data-spatial-2010-2022.dta",replace	
