set trace off
clear
capture log close
set more off
version 11



capture program drop laspeyresspatial
program define laspeyresspatial
	version 11
	syntax varlist(min=1 max=2), hhid(varname) itemid(varname) itemidstart(integer) itemidend(integer) expenditure(varname) quantity(varname) hhweight(varname) sharetype(string) transactions(integer) [basep0var(varname)] [basep0val(integer 999)]
	

	* Syntax diagram explanation:
	* `varlist' denotes the geographical area for the price index: urban/rural, stratum, region, etc. maximum of 2 spatial variables can be selected
	* `hhid' is the unique household id variables
	* `itemid' is the unique food or non-food item id that will be used
	* `itemidstart' is the starting code of item id incorporated to the index calculation
	* `itemidend' is the ending code of item id incorporated to the index calculation
	* `expenditure' is the item expenditure variable in LCU
	* `quantity' is the item quantity variable 
	* `hhweight' is the household weight variable
	* `sharetype' is democratic or plutocratic
	* `transactions' imposes a minimum number of transactions per item per `varlist'
	
	*`basep0var' is the variable where region specific P0 will be calculated
	*`basep0val' is the variable value where region specific P0 will be calculated
	
	* Example:
	*1.Regional laspeyres where P0 is calculated at national price:
	* laspyresspatial r101 r105, hhid(wert) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(democratic) transactions(50)
	*2. Regional laspeyres where P0 is calculated at urban price:
	* laspyresspatial r101 r105, hhid(wert) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(democratic) transactions(50) basep0var(urban) basep0val(1)
	* Note:
	*-you need to load the consumption data before executing the laspesyresspatial ado
	*-you need to clean(drop) the consumption data from double accounting 
	
	
	global show dis in white

	$show "***************************************************"
	$show "***             Spatial PRICE INDEX             ***"
	$show "***************************************************"

	$show "***************************************************"
	$show "***                                             ***"
	$show "***        LASPEYRES FOR FOOD                   ***"
	$show "***             L = SUM(Wi0*Pi/P0)              ***"
	$show "***    where,                                   ***"
	$show "***  - L is an index by geographic area         ***"
	$show "***  - Wi0 is the share in total consumption    ***"
	$show "***      of food  of each item considered       ***"
	$show "***      by geographic area                     ***"
	$show "***  - Pi is median price by geographic area    ***"
	$show "***  - P0 is median price nationaly             ***"
	$show "***                                             ***"
	$show "***************************************************"
	$show "*** for question regarding this do/ado file     ***"
	$show "*** contact Imam Setiawan(isetiawan@worldbank.org)*"
	$show "***        created on 23-July-2022              ***"
	$show "***************************************************"
	
	
	
	$show "**************************************************"
	$show "***       1. SETTING UP THE FILES AND          ***"
	$show "***    GETTING UNIT VALUES AND EXPENDITURES    ***"
	$show "**************************************************"
	
	
	
	
	*creating spatial variables based on user's selected varlist
	local nv : word count `varlist'
	if `nv'>2 {
						display "Could not take more than 2 spatial variables"
						error 134
	 }
			  
	else if `nv'==2 {
						*creating new spatial variable based on user selected varlist
						tokenize `varlist' 
						gen `1'_`2'= `1'*100+`2'
						local spatial `1'_`2'
	}
	
	else if  `nv'==1 {
						*creating new spatial variable based on user selected varlist
						local spatial `varlist'	
	}
	
	else			{
						display " Enter spatial variables"
						error 102
	}

	
	*keeping only  items selected by user
	keep if inrange(`itemid',`itemidstart',`itemidend')

	
	*keeping only variables that relevant to the index calculation
	keep `varlist' `hhid' `itemid' `expenditure' `quantity' `hhweight' `spatial'
	
	
	
	tempfile raw
	sort `hhid'
	save `raw', replace
	


	by `hhid', sort: generate obs=_n 
	keep if obs==1
	drop obs
	drop `itemid' `quantity' `expenditure' 
	
	tempfile basic
	sort `hhid'
	save `basic', replace

	
	
	use `raw', clear
	
	*generating unit price for food
	gen uprice = `expenditure'/`quantity'

	save tempfood, replace

	* if all food items are included, a  problems appear:
	* - some items are not consumed in some geographic area 
	* only food items that are consumed in all geographical area will be included in the food bundle
	use tempfood, clear
	keep `hhid' `itemid' uprice `spatial' 
	collapse (count) uprice, by(`spatial'  `itemid')
	reshape wide uprice, i(`itemid') j(`spatial')
	egen willbein = rowmiss(uprice*)
	tab willbein, m
	recode willbein 0=1 *=0
	tab willbein, m


	*************************************************************
	* to impose a minimum number of observations by `spatial' 
	*************************************************************
	egen xmin = rowmin(up*)
	count if willbein==1
	count if willbein==1 & xmin>=5
	count if willbein==1 & xmin>=10
	count if willbein==1 & xmin>=15
	count if willbein==1 & xmin>=20
	count if willbein==1 & xmin>=25
	count if willbein==1 & xmin>=30
	count if willbein==1 & xmin>=`transactions'
	recode willbein 1=0 if xmin<`transactions'
	tab willbein, m
	drop xmin

	drop uprice*
	sort `itemid' 
	tempfile willbein
	save `willbein', replace

	use tempfood, clear
	sort `itemid' 
	merge m:1 `itemid'  using `willbein'
	tab _merge, m
	drop _merge
	sort `hhid' `itemid'


	*******************************************************************
	$show "share of food spending to be included in the chosen bundles"
	*******************************************************************
	egen double xshare = sum(`expenditure'*`hhweight'), by(`spatial' willbein)
	egen double xtot   = sum(`expenditure'*`hhweight'), by(`spatial')
	gen xi = xshare/xtot*100
	table `spatial' willbein, c(mean xi) f(%9.0f)
	drop xshare xtot xi

	keep if willbein==1
	drop willbein
	
	tempfile food
	save `food', replace


	***************************************************************
	$show "to find out how many items each bundle will have"
	$show "and how many food items in total (for all bundles)"
	***************************************************************
	use `food', clear
	collapse (count) uprice, by(`spatial' `itemid')
	collapse (count) uprice, by(`spatial')
	egen casestot = sum(uprice)
	l
	
	
	***************************************************************
	$show "median food prices by `spatial' 
	***************************************************************
	use `food', clear
	collapse (median) uprice [aw=`hhweight'], by(`spatial'  `itemid')
	rename uprice pi
	d
	summ
	sort `spatial'  `itemid'
	tempfile foodpi
	save `foodpi', replace


	*********************************************************************************
	$show "median food prices at national or by `basep0var' and `basepoval'
	*********************************************************************************
	local nvar: word count `basep0var' 
	local nval: word count `basep0val'
	if `nvar'==1 {
		
		
		 if `nval'>1{
			display " select one value for base region of p0 variabl"
						error 102
		}
		
		
		else if `nval'==1 & `basep0val' !=999 {
			display "region po variable =`basep0var' & base region value=`basep0val'" 
		
			use `food', clear
			keep if `basep0var'==`basep0val'
			* check only `basep0var'==`basep0val' is included
			tab `basep0var'
			collapse (median) uprice [aw=`hhweight'], by(`itemid')
			rename uprice p0
			d
			summ
			sort  `itemid'
			tempfile foodp0
			save `foodp0', replace
		}
		
		else  if `nval'==1 & `basep0val' ==999 {
		
		display " select value for base region of p0 variabel"
						error 102
		}	
	}
	
	

	
	

	if `nvar'==0 &  `basep0val'==999{
	
	display "P0 will be calculated at national"
	use `food', clear
	collapse (median) uprice [aw=`hhweight'], by(`itemid')
	rename uprice p0
	d
	summ
	sort  `itemid'
	tempfile foodp0
	save `foodp0', replace
	}

		
	
	****************************************
	$show "amounts spent"
	****************************************
	use `food', clear
	keep `hhid' `itemid' `expenditure'
	rename `expenditure' food
	reshape wide food, i(`hhid') j(`itemid')
	sort `hhid'
	tempfile foodv
	save `foodv', replace


	$show "**************************************************"
	$show "***      2. EXPENDITURE SHARES (WEIGHTS)       ***"
	$show "**************************************************"

	
	qui recode food*  (.=0)

	
	if "`sharetype'" == "plutocratic" {
											display "Plutocratic shares of expenditure"
										
											* "plutocratic shares"
											egen totalff = rsum(food*)
											sort `hhid'
											merge 1:1 `hhid' using `basic'
											tab _merge, m
											* making sure ALL households have shares!
											drop _merge
											sort `hhid'

											summ
											collapse (mean) food* totalff [aw=`hhweight'], by(`spatial')
											foreach v of varlist food* {
												gen share`v' = `v'/totalff
												}
											drop food* totalff
											
											renpfix sharefood share

											* confirming that the sum of shares should add up to 1
											egen x = rsum(share*)
											tab x
											drop x
										
	}
	
	else if "`sharetype'" == "democratic" {
											display "Democratic shares of expenditure"
											* "democratic" shares
											reshape long food, i(`hhid') j(`itemid')
											
											egen totalff = sum(food), by(`hhid')
											gen double share = food/totalff
											summ share, det
											drop food totalff
											
											reshape wide share, i(`hhid') j(`itemid')
											
											merge `hhid' using `basic'
											tab _m
											
											
											* making sure ALL households have shares!
											summ
											collapse (mean) share* [aw=`hhweight'], by(`spatial')
											
											* confirming that the sum of shares should add up to 1
											egen sharet = rsum(share*)
											tab sharet, m
											drop sharet
	
	}
	
	else {
											error 6
	
	}
	
	
	reshape long share, i(`spatial') j(`itemid')
	drop if share==0
	gsort `spatial' -share
	l
	sort `spatial' `itemid'
	tempfile tempshares
	save `tempshares', replace


	$show "**************************************************"
	$show "***    3. MERGING UNIT VALUES WITH SHARES      ***"
	$show "**************************************************"

	* median fuel prices by national
	use `foodp0', clear
	summ
	sort  `itemid'
	tempfile p0
	save `p0', replace


	* median food prices by `spatial' 
	use `foodpi', clear
	sort `spatial' `itemid'
	
	merge m:1  `itemid' using `p0'
	tab _merge, m
	drop _merge
	sort `spatial'  `itemid'
	*rename `itemid' `itemid'
	sort `spatial' `itemid'
	merge m:1 `spatial' `itemid' using `tempshares'
	tab _merge, m
	drop _merge
	
	summ

	gen index = share*pi/p0
	
	collapse (sum) index, by(`spatial' )
	label var index "Temporal price index by `spatial'

	table `spatial', c(mean index) f(%9.3f)

	
	
	erase tempfood.dta
	
	
	end
	

****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************	
/*	
global raw_data      C:\Users\WB326559\OneDrive - WBG\Working Folder\From Utz\IPL vs NPL povline\Raw Data\Raw Data Susenas Module
global created_data  C:\Users\WB326559\OneDrive - WBG\Working Folder\From Utz\IPL vs NPL povline\Created Data
global log           C:\Users\WB326559\OneDrive - WBG\Working Folder\From Utz\IPL vs NPL povline\Log
global do            C:\Users\WB326559\OneDrive - WBG\Working Folder\From Utz\IPL vs NPL povline\Do
*/
/*	

************************************	
***testing the ado with 2019 data***
************************************	
	
********************************************************************	
***Province Urban-Rural Spatial Index using democratic share 2019***
********************************************************************

cap log close
log using "$log\spatial_index_province_urban_rural_19_mar.log", replace	
use "$raw_data\susenas19mar_41.dta", clear
*droping subgroup to  avoid double accounting
drop if inlist(kode,1,8,16,52,62,72,98,106,120,125,133,146,151,183)
*running the spatial laspeyres
laspeyresspatial r101 r105, hhid(urut) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(democratic) transactions(50)
save "$created_data\spatial_index_province_urban_rural_19_mar.dta", replace
log close


********************************************************************	
***Province Urban-Rural Spatial Index using plutocratic share 2019***
********************************************************************

cap log close
log using "$log\spatial_index_province_urban_rural_19_mar.log", replace	
use "$raw_data\susenas19mar_41.dta", clear
*droping subgroup to  avoid double accounting
drop if inlist(kode,1,8,16,52,62,72,98,106,120,125,133,146,151,183)
*running the spatial laspeyres
laspeyresspatial r101 r105, hhid(urut) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(plutocratic) transactions(50)
save "$created_data\spatial_index_province_urban_rural_19_mar.dta", replace
log close


*******************************************************
***Region Spatial Index using democratic share 2019****
*******************************************************

cap log close
log using "$log\spatial_index_island_19_mar.log", replace	
use "$raw_data\susenas19mar_41.dta", clear
*droping subgroup to  avoid double accounting
drop if inlist(kode,1,8,16,52,62,72,98,106,120,125,133,146,151,183)

*generating island variabel

gen island=.
replace island=1 if r101>=11 & r101<=21
replace island=2 if r101>=31	 & r101<=51
replace island=3 if r101>=52 & r101<=53
replace island=4 if r101>=61 & r101<=65
replace island=5 if r101>=71	 & r101<=76	
replace island=6 if r101>=81	 & r101<=94


label define island 1"Sumatera" 2"Java-Bali" 3"Nusa-tenggara" 4"Kalimantan" 5"Sulawesi" 6"Maluku & Papua"
label values island island


*running the spatial laspeyres
laspeyresspatial island, hhid(urut) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(democratic) transactions(50)
save "$created_data\spatial_index_island_19_mar.dta", replace
log close


*******************************************************
***Region Spatial Index using plutocratic share 2019****
*******************************************************

cap log close
log using "$log\spatial_index_island_19_mar.log", replace	
use "$raw_data\susenas19mar_41.dta", clear
*droping subgroup to  avoid double accounting
drop if inlist(kode,1,8,16,52,62,72,98,106,120,125,133,146,151,183)

*generating island variabel

gen island=.
replace island=1 if r101>=11 & r101<=21
replace island=2 if r101>=31	 & r101<=51
replace island=3 if r101>=52 & r101<=53
replace island=4 if r101>=61 & r101<=65
replace island=5 if r101>=71	 & r101<=76	
replace island=6 if r101>=81	 & r101<=94


label define island 1"Sumatera" 2"Java-Bali" 3"Nusa-tenggara" 4"Kalimantan" 5"Sulawesi" 6"Maluku & Papua"
label values island island


*running the spatial laspeyres
laspeyresspatial island, hhid(urut) itemid(kode) itemidstart(1) itemidend(189) expenditure(b41k10) quantity(b41k9) hhweight(wert) sharetype(plutocratic) transactions(50)
save "$created_data\spatial_index_island_19_mar.dta", replace
log close

*/


***** some house keeping ******** 

/*
use "$raw_data\All SUS Mod 2010-2021.dta", clear

destring kode, replace
destring urut, replace

*generating island variabel

gen island=.
replace island=1 if provcode>=11 & provcode<=21
replace island=2 if provcode>=31	 & provcode<=51
replace island=3 if provcode>=52 & provcode<=53
replace island=4 if provcode>=61 & provcode<=65
replace island=5 if provcode>=71	 & provcode<=76	
replace island=6 if provcode>=81	 & provcode<=94


label define island 1"Sumatera" 2"Java-Bali" 3"Nusa-tenggara" 4"Kalimantan" 5"Sulawesi" 6"Maluku & Papua"
label values island island

*droping duplicates
duplicates drop urut year kode, force

save "$raw_data\All SUS Mod 2010-2021.dta" , replace
*/



/*
***************************************************************	
***Province Urban-Rural Spatial Index using democratic share***
***************************************************************



foreach year in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {



cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(50)
save "$created_data\spatial_index_province_urban_rural_`year'_mar.dta", replace
log close	
	
	
}



**************************************************
*** Island Spatial Index using democratic share***
**************************************************



foreach year in 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 {

cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial island, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(50)
save "$created_data\spatial_index_island_`year'_mar.dta", replace
log close	
	
	
}

*/


*********************************
******* sensitivity check *******
*********************************

/*

***************************************************************	
***Province Urban-Rural Spatial Index using democratic share***
***************************************************************

** min 20 trasactions for 2010-2014

foreach year in 2010 2011 2012 2013 2014  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t20.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(20)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t20.dta", replace
log close	
	
	
}





** min 75 trasactions for 2015-2021

foreach year in 2015 2016 2017 2018 2019 2020 2021 {



cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t75.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(75)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t75.dta", replace
log close	
	
	
}




**************************************************************
*** Island urban-rural Spatial Index using democratic share***
**************************************************************

** min 20 trasactions for 2010-2014

foreach year in 2010 2011 2012 2013 2014  {

cap log close
log using "$log\spatial_index_island_urban_rural_`year'_mar_t20.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial island urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(20)
save "$created_data\spatial_index_island_urban_rural`year'_mar_t20.dta", replace
log close	
	
}



** min 75 trasactions for 2015-2021

foreach year in  2015 2016 2017 2018 2019 2020 2021 {

cap log close
log using "$log\spatial_index_island_urban_rural_`year'_mar_t75.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial island urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(75)
save "$created_data\spatial_index_island_urban_rural_`year'_mar_t75.dta", replace
log close	


}

*/



/*

***************************************************************	
***Province Urban-Rural Spatial Index using democratic share***
***************************************************************

** min 50 trasactions for 2019

foreach year in 2019  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t50.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(50)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t50.dta", replace
log close	


}


** min 25 trasactions for 2019

foreach year in 2019  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t25.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(25)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t25.dta", replace
log close	

}


*/


/*
** min 50 trasactions for 2019 and plutocratic shares

foreach year in 2019  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t50_pluto.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(plutocratic) transactions(50)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t50_pluto.dta", replace
log close	


}

*/


/*
** min 150 trasactions for 2019 and plutocratic shares

foreach year in 2019  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t150_pluto.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(plutocratic) transactions(150)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t150_pluto.dta", replace
log close	
}
*/

	
	
/*	
** laspeyres  2012 using urban price as P0

foreach year in 2012  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t50_basep0_urban.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres
laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(50) basep0var(urban) basep0val(1)
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t50_basep0_urban.dta", replace
log close	
}



** laspeyres  2012 using national price as P0

	
	foreach year in 2012  {


cap log close
log using "$log\spatial_index_province_urban_rural_`year'_mar_t50_basep0_national.log", replace	
use "$raw_data\All SUS Mod 2010-2021.dta", clear
keep if year==`year'
*running the spatial laspeyres

laspeyresspatial provcode urban, hhid(urut) itemid(kode) itemidstart(2) itemidend(236) expenditure(v) quantity(q) hhweight(wert) sharetype(democratic) transactions(50) 
save "$created_data\spatial_index_province_urban_rural_`year'_mar_t50_basep0_national.dta", replace

log close	
}


*/
