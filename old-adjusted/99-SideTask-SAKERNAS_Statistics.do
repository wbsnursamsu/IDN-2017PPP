********************************************************************************
*
*	Project			: Poverty Line Analysis & PA Core Analytics
*	Task			: Some SAKERNAS Employment Statistics
*	Subtask			: -
*	Input			: -
*	Note			: -
*	Author			: Putu Sanjiwacika Wibisana	(pwibisana@worldbank.org)
*
********************************************************************************
	
	global SAKdir "$gdData/SAKERNAS/Coded Data/"
	
**** 1. Appending SAKERNAS datasets ****
	
	*** Set of SAKERNAS data ***
	
	#delimit ;
		local SAKERNAS `"
			"sak02_coding.dta"
			"sak03_coding.dta"
			"sak04_coding.dta"
			"sak05nov_coding.dta"
			"sak06aug_coding.dta"
			"sak07aug_coding.dta"
			"sak08aug_coding.dta"
			"sak09aug_coding.dta"
			"sak10aug_coding.dta"
			"sak11aug_coding.dta"
			"sak12aug_coding.dta"
			"sak13aug_coding.dta"
			"sak14aug_coding.dta"
			"sak15aug_coding.dta"
			"sak16aug_coding.dta"
			"sak17aug_coding.dta"
			"sak18aug_coding.dta"
			"sak19aug_coding.dta"
			"sak20aug_coding.dta"
			"sak21aug_coding.dta"
		"' ;
	#delimit cr
	
	*** Extract necessary information 
	
	forval y = 2002/2021 {
		gettoken sak SAKERNAS:SAKERNAS
		use "$SAKdir/`sak'", clear
		keep weight prov urban gender agegroup labforce* employed unemployed* ///
			 status sector3 formal_new formal_old income realmwage hrwage realhrwage ///
			 hour hour2
		gen year = `y'
		tempfile sak`y'
		save `sak`y''
	}
	
	*** Append
	
	forval y = 2002/2021 {
		if `y' == 2002 {
			use `sak`y'', clear
		}
		else {
			append using `sak`y''
		}
	}
	
	*** Save temp data
	
	save "$gdTemp/Temp", replace
	use "$gdTemp/Temp", clear
	
	
**** 2. Generate statistics ****

	global worksheet "PA_COVID19 Story - SAKERNAS.xlsx"
	
	*** i. LFPR & Employment Rate ***
		preserve
			collapse (mean) unemployed_core labforce_core [fw=weight], by(year)
			
			label variable unemployed_core "Unemmployment Rate"
			label variable labforce_core "LFPR"
			
			* Export to excel
			putexcel set "$gdOutput/$worksheet", modify sheet("Emp Rate & LFPR")
			putexcel B2 = "Employment Rate & Labor Force Participation Rate 2002-2021", bold
			export excel using "$gdOutput/$worksheet", sheet("Emp Rate & LFPR") sheetmodify cell(B4) firstrow(varlabels) keepcellfmt
			
		restore

	*** ii. Number of workers by employment status ***
		preserve
			keep if inlist(year,2017,2018,2019,2020,2021)
			levelsof status
			foreach i in `r(levels)' {
				local lab`i': label status `i'
				gen status_`i' = status == `i'
			}
			collapse (sum) status* [fw=weight], by(year)
			forval i = 1/7 {
				label variable status_`i' "`lab`i''"
			}
			drop status
			
			* Export to excel
			putexcel set "$gdOutput/$worksheet", modify sheet("Employment Status")
			putexcel B2 = "Number of Employment by Status, 2019-2021", bold
			export excel using "$gdOutput/$worksheet", sheet("Employment Status") sheetmodify cell(B4) firstrow(varlabels) keepcellfmt
			
		restore
		
	*** iii. Number of workers by Gender and Formality
		preserve
			keep if inlist(year,2017,2018,2019,2020,2021)
			egen gxf = group(gender formal_new), label
			collapse (sum) employed [fw=weight], by(year gxf)
			drop if employed == 0 
			reshape wide employed, i(year) j(gxf)
			local labels  `" "Female Informal" "Female Formal" "Male Informal" "Male Formal" "'
			forval i = 1/4 {
				gettoken l labels:labels
				label variable employed`i' "`l'"
			}
			
			* Export to excel
			putexcel set "$gdOutput/$worksheet", modify ///
			         sheet("Empl Gender x Formal")
			putexcel B2 = "Number of Employment by Status, 2019-2021", bold
			export excel using "$gdOutput/$worksheet", ///
			       sheet("Empl Gender x Formal") sheetmodify /// 
				   cell(B4) firstrow(varlabels) keepcellfmt
		restore	
		
	*** iv. Number of workers by 3 Sectors and Formality
	
		preserve
			keep if inlist(year,2017,2018,2019,2020,2021)
			egen sxf = group(sector3 formal_new), label
			collapse (sum) employed [fw=weight], by(year sxf)
			drop if employed == 0 
			reshape wide employed, i(year) j(sxf)
			local labels  `" "Agriculture Informal" "Agriculture Formal" "Industry Informal" "Industry Formal" "Services Informal" "Services Formal" "'
			forval i = 1/6 {
				gettoken l labels:labels
				label variable employed`i' "`l'"
			}
			
			* Export to excel
			putexcel set "$gdOutput/$worksheet", modify ///
			         sheet("Empl Sector3 x Formal")
			putexcel B2 = "Number of Employment by Sector (3 Main), 2019-2021", bold
			export excel using "$gdOutput/$worksheet", ///
			       sheet("Empl Sector3 x Formal") sheetmodify /// 
				   cell(B4) firstrow(varlabels) keepcellfmt
		restore	
		
	*** v. Real Income by Formal Informal (Only Self-Employed, Employee and Casual Worker for primary job)
	
		use "$gdTemp/Temp", clear
	
		preserve
			keep if inlist(year,2017,2018,2019,2020,2021)
			collapse (mean) realmwage [fw=weight], by(year formal_new)
			drop if realmwage == .
			reshape wide realmwage, i(year) j(formal_new)
			label variable realmwage0 "Informal"
			label variable realmwage1 "Formal"
			tempfile fi
			save `fi'
		restore	
		
		keep if inlist(year,2017,2018,2019,2020,2021)
		collapse (mean) realmwage [fw=weight], by(year)
		label variable realmwage "All"
		merge 1:1 year using `fi', nogen
		
		* Export to excel
		putexcel set "$gdOutput/$worksheet", modify ///
			     sheet("Rmwage Formal")
		putexcel B2 = "Real Monthly Wage by Formality Status (2012 IDR), 2017-2021", bold
		putexcel B3 = "NOTE: SAKERNAS only covers the wage of the following employment status: Self-Employed, Employee and Casual Worker", italic
		export excel using "$gdOutput/$worksheet", ///
		       sheet("Rmwage Formal") sheetmodify /// 
			   cell(B5) firstrow(varlabels) keepcellfmt
			   
	*** vi. Weekly Working Hours (All jobs) by Formal Informal
	
		use "$gdTemp/Temp", clear
	
		preserve
			keep if inlist(year,2017,2018,2019,2020,2021)
			collapse (mean) hour [fw=weight], by(year formal_new)
			drop if hour == .
			reshape wide hour, i(year) j(formal_new)
			label variable hour0 "Informal"
			label variable hour1 "Formal"
			tempfile fi
			save `fi'
		restore	
		
		keep if inlist(year,2017,2018,2019,2020,2021)
		collapse (mean) hour [fw=weight], by(year)
		label variable hour "All"
		merge 1:1 year using `fi', nogen
		
		* Export to excel
		putexcel set "$gdOutput/$worksheet", modify ///
			     sheet("Hour Formal")
		putexcel B2 = "Weekly Working Hour in all jobs by Formality Status, 2017-2021", bold
		export excel using "$gdOutput/$worksheet", ///
		       sheet("Hour Formal") sheetmodify /// 
			   cell(B4) firstrow(varlabels) keepcellfmt
			   
	******* Delete tempfile
	
	cap erase "$gdTemp/Temp"