
//Preamble
	clear all
	
//Location
	global root "C:\Users\WB454594\OneDrive - WBG\Kazakhstan\PSIA" 
	global raw "C:\Users\WB454594\OneDrive - WBG\Kazakhstan\Data\KAZ_2015_HBS\KAZ_2015_HBS_v01_M\Data\Stata" 
	global in "C:\Users\WB454594\OneDrive - WBG\Kazakhstan\\Data\KAZ_2015_HBS\KAZ_2015_HBS_v01_M_v01_A_ECAPOV\Data\Harmonized"
	
//Open location ids
	import excel using "$root\katonew1.xlsx", firstrow clear
	rename te district_id
	tempfile locid1
	save `locid1'


	import excel using "$root\katonew2.xlsx", firstrow clear
	rename te district_id
	append using `locid1'
	
	tostring district_id, g(district_id_str)
	g area = substr(district_id, 1, 4)
	destring area, replace
	
	tempfile locid2
	save `locid2'
	
//Open data
	use "$root\ECAPOV_2015_Nominal@1.dta", clear
	rename district district_id
	tostring district_id, replace
	merge m:1 district_id using `locid2'
	
//keep full list 
	save "$root\ECAPOV_2015_Nominal_WMissing@1.dta", replace
	
//Make a file of just matched
	drop if _m==2
	assert _m==3
	drop _m
	
	save "$root\ECAPOV_2015_Nominal_NoMissing@1.dta", replace
	keep hhid region popw
	bys hhid: keep if _n==1
	tempfile regnames
	save `regnames'
		
//Rent file
	use "$raw\rio_d006.dta", clear
	ren nom_dx hhid
	tostring te, g(district_str)
	ren te district
	g area = substr(district_str, 1, 4)
	g region = substr(district_str, 1, 2)
	destring area, replace
	gen urban=(k==1)
	ren aren rent
	replace rent = rent*12 //Aibek says this was done incorrectly
	
	destring region, replace
	replace urban = 1 if region==75
	replace urban = 1 if region==71
	egen urb_rentest = median(rent) if rent!=0, by(urban)
	g urb_rent = 540000
	
//create ownership indicator
	g own  =0 
	replace own = 1 if vlad1==1

	tempfile rentan
	save `rentan'
	
//Create values for imputation
	tab region, g(regdum)	
	tempfile allimp
	save `allimp'
	keep hhid regdum* urban sump
	tempfile hhids
	save `hhids'
	clear
	use `allimp'
	
//Predict value for "basic" housing
	append using `hhids', gen(pred)
	replace j_pl = 42 if pred==1
	replace kol_k = 3 if pred==1
	replace tip_j = 1 if pred==1
	xi: reg rent j_pl kol_k i.tip_j  urban regdum*
	est store predrent
	xml_tab predrent , save("$root\\rentmod@1.xls") sh("Main") append below stats(N r2_p ll)
	predict pred_rent
	keep if pred==1
	keep pred_rent hhid sump
	g sump15 =sump
	g pred_rent15 =pred_rent
	g year = 2015
	tempfile predicted
	save `predicted'

//create table of rural/urban/ regional averages
	use `rentan', clear
	drop region
	merge 1:1 hhid  using `regnames'
	drop if _m==2
	drop _m
	merge 1:1 hhid using `predicted'
	assert _m==3
	drop _m
	

	g urbrent = rent
	replace urbrent = . if urban==0
	g urbcost = sump
	replace urbcost = . if urban==0
	g pred_urbrent = pred_rent
	replace pred_urbrent = . if urban==0
	

	g rurrent = rent
	replace rurrent = . if urban==1
	g pred_rurrent = pred_rent
	replace pred_rurrent = . if urban==1
	g rurcost = sump
	replace rurcost = . if urban==1
	
	g pred_rent_11 = pred_rent/1.26613
	g rent_11 = rent/1.26613
	
	g rent_price_ratio = sump/rent

	tempfile rentan2
	save `rentan2'
	

	loc vars rent sump urbrent urbcos rurrent rurcost pred_rent pred_rurrent pred_urbrent rent_price_ratio
	foreach i of loc vars {
		replace `i' = `i'/1000
		}
	*	collapse (mean) rent sump urbrent urbcos rurrent rurcost pred_rent pred_rurrent pred_urbrent pred_rent_11 rent_11 rent_price_ratio [aw=popw], by(region)
	
	collapse (median) rent sump urbrent urbcos rurrent rurcost pred_rent pred_rurrent pred_urbrent [aw=popw], by(region)
	
//Create quarterly file
	use `rentan2', clear
	expand 4
	bys hhid: g quarter = _n
		
	keep hhid ///
		rent ///
		urban ///
		district ///
		area ///
		quarter ///
		urb_rent ///
		sump ///
		pred*
		
	tempfile rent
	save `rent'
	
//Create a "Urban Rent" as a share of median consumption
	use "$root\ECAPOV_2015_Nominal_NoMissing@1.dta"
	g gallthh = gallpc_nadj*hhsize
	replace rent = rent*12
	g fshare  = g1pc/gall
	g rshare_ecapov = rent/gall
	collapse (mean) gallthh fshare rshare_ecapov, by(hhid popw)
	merge 1:1 hhid using `rentan2' //this was rentan before, but needed pred for elast
	g hhnohous =  gallthh
	replace gallthh = gallthh+rent
	replace rent = . if rent==0
	g rshare = rent/gallthh
	g sh_urb_rent = urb_rent/gallthh
	g diff_share = sh_urb_rent - rshare
	*collapse (median) rent sump hhnohous  [aw=popw], by(region)

	loc av rshare ///
		sh_urb_rent ///
		diff_share
	
	foreach i of loc av {
		replace `i' = . if `i' ==0
		}
		
	drop _m
	tempfile befelast
	save `befelast'
	
//Create dummies for affordability categories
	g rent0_10 = 0
	g rent11_20 = 0 
	g rent21_30 = 0 
	g rent31_40 = 0 
	g rent41_50 = 0 
	g rent51_above = 0 
	
	replace rent0_10 = 1 if rshare <=.10 & rshare!=.
	replace rent11_20 = 1 if rshare > .10 & rshare <=.20 & rshare!=.
	replace rent21_30 = 1 if rshare > .20 & rshare <=.30 & rshare!=.
	replace rent31_40 = 1 if rshare > .30 & rshare <=.40 & rshare!=.
	replace rent41_50 = 1 if rshare > .40 & rshare <=.50 & rshare!=.
	replace rent51_above = 1 if rshare > .50	 & rshare!=.
	
	g sh_above30 = 0
	replace sh_above30 = 1 if rshare >.30 & rshare!=.
	
//reopen
	*use `befelast', clear
	*collapse (mean) rshare sh_urb_rent diff_share fshare, by(area)
	collapse (mean) rshare sh_urb_rent diff_share fshare rent0_10 rent11_20 ///
		rent21_30 ///
		rent31_40  ///
		rent41_50 ///
		rent51_above sh_above30 [aw=popw], by(/*region*/ urban)
	
//differences in shares
	*save "$root\Rent_Shares_Consumption@2.dta", replace

//Quarterly Diary
	clear all
	tempfile temp_diary 
	save `temp_diary', replace emptyok

forvalues k=1/4 { 
	di in red "`k'"
	use "$raw\dnevnr_`k'kv.dta", clear
	*datalibweb, coun(KAZ) y(2015) type(ecaraw) surveyid(KAZ_2015_HBS) filen(dnevnr_`k'kv) clear files
	
	capture replace razd="" if razd=="q"	
	destring, replace
	
	tostring te, g(district_str)
	g area = substr(district_str, 1, 4)
	destring area, replace

	ren nom_dx hhid
	duplicates drop
	
	gen double code=kod_tu
	format code %14.0g
	ren edizm unit
	ren kvart quarter
	gen region=floor(te/10000000)
	rename te district
	gen urban=(k==1)
	ren potrk quantity    			/*quartely  quantity*/
	ren stoimk amount     			/*quartely  amount*/
	keep hhid code quarter unit region area district urban quantity amount razd  
	
	sum quantity amount unit if code==.
	drop if code==.   				/*  observations with no info on product codes. */
	/*drop if celpok != 1           AB: could drop purchases for other than cons purposes*/
	/*drop if charday != 1           AB: could drop if day was unusual*/
	
	append using `temp_diary'
	save `temp_diary', replace
}

//Median prices for in-kind consumption
	recode unit (166=1) (112=2) (796=3) (5111=4)

	gen pr=amount/quantity if razd==2

//prices by region/location/quarter 
	egen pr_1=median(pr) if pr!=0 , by (code unit quarter urban area) //lower level
	egen pr_2=median(pr) if pr!=0 , by (code unit quarter urban region) 
	egen pr_3=median(pr) if pr!=0 , by (code unit quarter urban) 
	egen pr_4=median(pr) if pr!=0 , by (code unit quarter)  //reference price
	egen pr_5=median(pr) if pr!=0 , by (code unit urban region) 
	egen pr_6=median(pr) if pr!=0 , by (code unit urban) 
	egen pr_7=median(pr) if pr!=0 , by (code unit)

	gen price=pr_1
	forvalues a=2/7 {
		replace price=pr_`a' if price==.
	}

	gen double cons=amount               /* already quarterly value*/
	replace cons=quantity*price if razd==4 // AB: note: own production valuation

	drop if code==.|cons==.
	keep if (unit==1 | unit==2) & razd==2  	//unit: 1=kg, 2=lt, 3=pieces

//Database of prices for products
	saveold "$root\Prices_by_Product@1.dta", replace
	
stop	
//Add rent
	append using `rent', gen(r)
	sort hhid
	g price_rent = price
	g price_pred_rent = price
	replace price_rent = rent if price==.
	replace price_pred_rent = pred_rent if price==.
	
	g qantity_rent = 1
	g amount_rent = amount
	g amount_pred_rent = amount
	replace amount_rent = rent if amount == .
	replace amount_pred_rent = pred_rent if amount == .
	g cons_rent = cons
	g cons_pred_rent = cons
	replace cons_rent = rent if cons_rent==.
	replace cons_pred_rent = pred_rent if cons_pred_rent==.
	replace code = 1 if r==1
	
//Get median rent prices at other levels
	egen pr_1_rent=median(rent) if rent!=0 , by (quarter urban area) //lower level
	egen pr_2_rent=median(rent) if rent!=0 , by (quarter urban region) 
	egen pr_3_rent=median(rent) if rent!=0 , by (quarter urban) 
	egen pr_4_rent=median(rent) if rent!=0 , by (quarter)  //reference price
	
	egen pr_1_prrent=median(pred_rent) if rent!=0 , by (quarter urban area) //lower level
	egen pr_2_prrent=median(pred_rent) if rent!=0 , by (quarter urban region) 
	egen pr_3_prrent=median(pred_rent) if rent!=0 , by (quarter urban) 
	egen pr_4_prrent=median(pred_rent) if rent!=0 , by (quarter)  //reference price
	
	forvalues i = 1/4 {
		replace pr_`i'_rent = pr_`i' if r==0
		replace pr_`i'_prrent = pr_`i' if r==0
		}

//collapse to total within household
	collapse (sum) amount amount_rent amount_pred_rent (min) area region urban pr_* quantity* price*, by (hhid quarter code) 
	egen freq = count(_n), by(code quarter region) 		/* drop if less than 5 housholds purchase that product, by region)*/
	drop if freq<5
	replace pr_1 =. if pr_1>pr_3*5 | pr_1<pr_3/5 		/* replacing  the outlier unit values - 5 times > or < than national unit value */
	replace pr_1_rent =. if pr_1_rent>pr_3_rent*5 | pr_1_rent<pr_3_rent/5
	replace pr_1_prrent =. if pr_1_prrent>pr_3_prrent*5 | pr_1_prrent<pr_3_prrent/5
	gen wpr = (pr_4/pr_1)*amount              			/* Item price index for the household */
	gen wpr_rent = (pr_4_rent/pr_1_rent)*amount_rent
	gen wpr_pred_rent = (pr_4_prrent/pr_1_prrent)*amount_pred_rent
	
//Save tempfile
	tempfile full_price
	save `full_price'
	
///	Create rent deflator rurb, and cost of dwelling
	use `rent'
	replace rent=. if rent==0
	egen rent3 = median(rent) if rent!=0, by(area urban)
	egen rent3_temp = median(rent) if rent!=0, by(area)
	replace rent3  = rent3_temp if rent3 ==.
	egen rent4 = median(rent) if rent!=0
	g rent_dist = rent3/rent4
	
	replace pred_rent=. if rent==0
	egen pred_rent3 = mean(pred_rent) if pred_rent!=0, by(area urban)
	egen pred_rent3_temp = mean(pred_rent) if pred_rent!=0, by(area)
	replace pred_rent3  = pred_rent3_temp if pred_rent3 ==.
	egen pred_rent4 = mean(pred_rent) if pred_rent!=0
	g pred_rent_dist = pred_rent3/pred_rent4
	
	egen house_cost3 = median(sump) if sump!=0, by(area urban)
	egen house_cost3_temp = median(sump) if sump!=0, by(area )
	replace house_cost3  = house_cost3_temp if house_cost3 ==.
	egen house_cost4 = median(sump) if rent!=0
	g house_cost = house_cost3/house_cost4

//	multiple of imputed rent
/*
	g multip_rent = sump/rent
	g multip_pred_rent = sump/pred_rent
	
	tempfile rent_dist_rurb_ncol
	save `rent_dist_rurb_ncol'
	
	tostring area, g(area_str)
	g region = substr(area_str, 1, 2)
	collapse (median) rent_dist pred_rent_dist rent house_cost multip_rent multip_pred_rent , by(area urban)
		
	tempfile rent_dist_rurb
	save `rent_dist_rurb'
	
	use `rent_dist_rurb_ncol', clear
	collapse (median) rent_dist pred_rent_dist rent house_cost multip_rent multip_pred_rent , by(area)
	tempfile rent_dist_all
	save `rent_dist_all'
	
	use `rent_dist_rurb_ncol', clear
	tostring area, g(area_str)
	g region = substr(area_str, 1, 2)
	collapse (median) rent_dist pred_rent_dist rent house_cost multip_rent multip_pred_rent , by(region)
	
	*use `rent_dist_rurb_ncol', clear
	*collapse (median) rent_dist pred_rent_dist rent house_cost multip_rent multip_pred_rent , by(region urban)
	*/ 
//Collapse with urban/rural
/*
	use `full_price', clear
	collapse (sum) amount amount_rent amount_pred_rent wpr wpr_rent wpr_pred_rent , by(area hhid urban quarter)
	gen rdef = amount/wpr
	g rdef_rent = amount_rent/wpr_rent
	g rdef_pred_rent = amount_pred_rent/wpr_pred_rent
	tempfile befcol
	save `befcol'
	tostring area, g(area_str)
	g region = substr(area_str, 1, 2)
	/*
	collapse (median) rdef rdef_rent rdef_pred_rent, by(region)
	collapse (median) rdef rdef_rent rdef_pred_rent, by(region urban)
	*/
	collapse (median) rdef rdef_rent rdef_pred_rent, by( area urban)
	
	tempfile sav1
	save `sav1'
	
//without urban
	use `befcol'
	collapse (median) rdef rdef_rent rdef_pred_rent, by(quarter area)
	tempfile sav2
	save `sav2'
	
//Save District/Rural/Urban
	use `sav1', clear
	merge m:1 area urban using `rent_dist_rurb'
	assert _m==3
	drop _m
	save "$root\kaz_hbs_spadef_rurb@3.dta", replace
	clear
	
	use `sav2', clear
	collapse (median) rdef rdef_rent rdef_pred_rent, by(quarter area)
	merge m:1 area using `rent_dist_all'
	assert _m==3
	drop _m
	
	merge m:1 area using "$root\Rent_Shares_Consumption@2.dta"
	drop if _m==2
	drop _m
	
	save "$root\kaz_hbs_spadef@4.dta", replace
	clear
	
//Fill in missing at district level
	set more off
	clear all
	mata
	function _spatmat(real matrix xy, real scalar radius, real scalar pow, real scalar inter){
		cN=rows(xy)
		latr = ( pi() / 180 ):*xy[.,2]
		lonr = ( pi() / 180 ):*xy[.,1]
		
		//Distance between i and j
		A = J(cN,cN,1) :* lonr
		B = J(cN,cN,1) :* lonr'
		C = J(cN,cN,1) :* latr
		D = J(cN,cN,1) :* latr'
		difflonr = abs( A - B )
		numer1 = ( cos(D):*sin(difflonr) ):^2
		numer2 = ( cos(C):*sin(D) :- sin(C):*cos(D):*cos(difflonr) ):^2
		numer = sqrt( numer1 :+ numer2 )
		denom = sin(C):*sin(D) :+ cos(C):*cos(D):*cos(difflonr)
		mDist = 6378.137 :* atan2( denom, numer )

		W=(mDist:<radius):*(inter:+mDist):^(-pow)
		return(W:/quadrowsum(W))
		}
		
	function _rdef(real matrix rdef, real matrix W){
		W=(W:*((rdef:!=0)'))
		W=W:/quadrowsum(W)
		
		return(rdef+((W*rdef):*(rdef:==0)))
		
	}
	end
	
//First for rurb file	
	//Impute for missing
		loc ind  rdef ///
			rdef_rent ///
			rent_dist ///
			house_cost ///
			rshare ///
			sh_urb_rent ///
			rdef_pred_rent
			
	//Loop over indicators	and quarters
		foreach i of loc ind {

	//Import numbeo data (RENT DEFLATOR)
		use "$root\\kaz_hbs_spadef@4.dta", clear
		collapse (mean) `i', by(area)
		tempfile spat
		save `spat'

	//IMPORT centroids
		import excel using "$root\KAZ_District_XY_V2.xls", clear first
		tostring te, g(district_id_str)
		g area = substr(district_id, 1, 4)
		destring area, replace
		merge 1:1 area using `spat'
			drop if _m==2
			drop _m
		
		replace `i' = 0 if `i' == .
		mata: st_view(xy=., ., tokens("X_Coord Y_Coord"),.)

	//ALL NEIGHBORS
		//_spatmat((longitude and latitude), maxdistance, exponent for distance )
		mata: weight=_spatmat(xy, 1000000,1,1e-6) 
		mata: st_view(def=.,.,tokens("`i'"),.)
		//_rdef(real matrix rdef, real matrix W)
		mata:def[.,.]=_rdef(def,weight)
		
		keep area `i'
		save "$root\`i'.dta", replace
		}
		
	use "$root\rdef.dta", clear
	merge 1:1 area using "$root\rdef_rent"
	assert _m==3
	drop _m
	merge 1:1 area using "$root\rent_dist"
	assert _m==3
	drop _m
	merge 1:1 area using "$root\house_cost"
	assert _m==3
	drop _m
	merge 1:1 area using "$root\rshare"
	assert _m==3
	drop _m
	merge 1:1 area using "$root\sh_urb_rent"
	assert _m==3
	drop _m
	merge 1:1 area using "$root\rdef_pred_rent"
	assert _m==3
	drop _m
	
	
//Save 
	save "$root\KAZ_2015_SpaDef@5.dta", replace
	outsheet using "$root\KAZ_2015_SpaDef@5.csv", c replace
*/
*/

//Poverty simulation
	use "$root\Panel@1.dta", clear
	
	//create var without spatial deflation
		g galltnospadef = gallT_scd_real_05*rdef
		apoverty  galltnospadef [aw=popw], line(5) gen(poor_05_5_nodef)
		apoverty  gallT_scd_real_05 [aw=popw], line(5) gen(poor_05_5def)
		
	stop
	
//Inequality simulation
	g pcrent = (rent*12)/hhsize
		
	g simineqgallT =  gallT+pcrent
/*
forvalues i = 2006/2015 {
	di `i'
	fastgini gallT_scd_real_05 [w=popw] if year==`i'
	fastgini simineqgallT [w=popw] if year==`i'
	
	*ineqdeco gallT_scd_real_11 [w=popw] if year==`i', w s
	*ineqdeco simineqgallT [w=popw] if year==`i', w s
	}
*/

//Elasticity
	use "$root\KAZ_Income@2.dta", clear
	keep if year ==2015
	drop gall* hhsize
	tempfile inc
	save `inc'


	use "$root\Panel@1.dta", clear		
	drop if year<2014
	capture drop sump
	merge 1:1 hhid year using "$root\hedonic2014.dta"
	drop if _m==1 & year==2014
	assert _m !=2
	drop _m
	
	capture destring sump, replace
	
	merge 1:1 hhid year using `predicted'
	
	replace sump = sump15 if year==2015
	replace pred_rent = pred_rent15 if year==2015
	drop if _m==1 & year==2015
	assert _m !=2
	drop _m

//Create rent and consumption variables
	replace rent = rent*12
	g gallthh  = gallT*hhsize
	replace gallthh = gallthh+rent
	g rentdiv = rent/1000
	g gallthhdiv = gallthh/1000
	replace gallthhdiv =. if gallthhdiv>15000
	g pred_rentdiv = pred_rent/1000
	g transdiv = (g7pc*hhsize)/1000
	g sumpdiv = sump/1000
	g lngallT = ln(gallT_scd_real_05)
	
//Covariates
	g almaty_astata = 0
	replace almaty_astata = 1 if region>69
	g other_urban = 0
	replace other_urban = 1 if almaty_astata==0 & urban==1
	g dum2015 = 0
	replace dum2015 = 1 if year==2015
	
	
//Put into Real terms
	g realrent = rentdiv/cpi2005
	g realgallthh =  gallthhdiv/cpi2005
	g realhhtrans = transdiv/cpi2005
	g realpred_rent = pred_rentdiv/cpi2005 
	g realhousecost = sumpdiv/cpi2005 
	
//Put into log terms
	g ln_h = ln(realrent)
	g ln_h2 = ln(realhousecost)
	g ln_y = ln(realgallthh)
	g ln_ph = ln(realpred_rent)
	g ln_trans = ln(realhhtrans)
		replace ln_trans = 0 if ln_trans==.
	
	tempfile befelast
	save `befelast'
	
	keep if year==2014

	twoway scatter rentdiv gallthhdiv , title(Engel Curve 2014) ytitle(Imputed Rent)  xtitle(Total Consumption) ///
		legend(label(1 "Consumption (in 1000s)") label(2 "National") label(3 "Urban") label(4 "Rural")) ///
		|| lfit rentdiv gallthhdiv [aw=popw] ///
		|| lfit rentdiv gallthhdiv [aw=popw] if urban==1 ///
		|| lfit rentdiv gallthhdiv [aw=popw] if urban==0 
		
	graph export "$root\consump_vs_housing2014.png", replace
	reg rentdiv gallthhdiv  [aw=popw]
	
	use `befelast', clear
	
	keep if year==2015
	twoway scatter rentdiv gallthhdiv , title(Engel Curve 2015) ytitle(Imputed Rent)  xtitle(Total Consumption) ///
		legend(label(1 "Consumption (in 1000s)") label(2 "National") label(3 "Urban") label(4 "Rural")) ///
		|| lfit rentdiv gallthhdiv [aw=popw] ///
		|| lfit rentdiv gallthhdiv [aw=popw] if urban==1 ///
		|| lfit rentdiv gallthhdiv [aw=popw] if urban==0 
		
	graph export "$root\consump_vs_housing2015.png", replace

//NO ASTANA ALMATY IN 2014!!!?
		
//Try to look at income
 	use `befelast', clear
	keep if year==2015
	merge 1:1 hhid using `inc'
	
//Consumption poverty
	apoverty  gallT_scd_real_05 [aw=popw], line(5) gen(poor_05_5def)
	
//Income vars
	g tot_inc_all_ppp11_day = tot_inc_realpc2011/icp2011/365.24
	g tot_inc_nom = tot_inc_all_ppp11_day*cpi2011*icp2011*365.24
	g hhtot_inc_nom_div = (tot_inc_nom*hhsize)/1000
	g hhtot_inc_nom = (tot_inc_nom*hhsize)
	replace hhtot_inc_nom_div =. if hhtot_inc_nom_div>20000
	g lnhhtot_inc_nom_div = ln(hhtot_inc_nom)
	g pens_inc = 0
	replace pens_inc=1 if d_pens>0
	
	reg ln_h lnhhtot_inc_nom_div  ln_ph ln_trans hhsize  [aw=popw]
			est store incdemand1

	reg ln_h lnhhtot_inc_nom_div  ln_ph ln_trans hhsize  [aw=popw] if urban==1 
			est store incurbdemand2
			
	reg ln_h lnhhtot_inc_nom_div  ln_ph ln_trans hhsize [aw=popw] if urban==0
			est store incrurdemand3
			
	reg ln_h lnhhtot_inc_nom_div  ln_ph ln_trans hhsize [aw=popw] if pens_inc==1
			est store incpensdemand3
	
	
//Consumption excluding rent
	reg ln_h lngallT  ln_ph ln_trans hhsize  [aw=popw]
			est store consdemand1

	reg ln_h lngallT  ln_ph ln_trans hhsize [aw=popw] if urban==1 
			est store consurbdemand2
			
	reg ln_h lngallT  ln_ph ln_trans hhsize [aw=popw] if urban==0
			est store consrurdemand3
			
	reg ln_h lngallT  ln_ph ln_trans hhsize [aw=popw] if pens_inc==1
			est store conspensdemand3
			
	reg ln_h lngallT  ln_ph ln_trans hhsize [aw=popw] if poor_05_5def1==1
			est store conspensdemand3		
			
		stop	
			
xml_tab incdemand1  incurbdemand2 incrurdemand3 consdemand1 consurbdemand2 consrurdemand3, save("$root\\Demand@1.xls") sh("Main") replace below stats(N r2_p ll)

	/*		
//Use house price/income/rent for elasticity
	reg ln_h2  lnhhtot_inc_nom_div ln_h ln_trans hhsize [aw=popw]
			est store d_house_1
		
	reg ln_h2  lnhhtot_inc_nom_div  ln_h ln_trans hhsize [aw=popw] if urban==1  
			est store d_house_2
		
	reg ln_h2  lnhhtot_inc_nom_div  ln_h ln_trans hhsize [aw=popw] if urban==0
			est store d_house_3
		
//Use house price/Comsumption/rent for elasticity
	reg ln_h2 lngallT  ln_h ln_trans hhsize  [aw=popw]
			est store demand1

	reg ln_h2 lngallT  ln_h ln_trans hhsize [aw=popw] if urban==1 
			est store demand2
			
	reg ln_h2 lngallT  ln_h ln_trans hhsize [aw=popw] if urban==0
			est store demand3
