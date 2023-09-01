********************************************************************************
*	Project			: Poverty Line Analysis
*	Task			: Run all do-files for Consumption Module extraction
*	Subtask			: -
*	Input			: -
*	Note			: -
********************************************************************************

**** Run all data cleaning do-files
* Note: Due to peculiarity of the data cleaning issues for each round of SAKERNAS, I've written the cleaning code for each SUSENAS dataset separately in the folder  "SUSENAS Consumption Module Cleaner". This is to avoid confusion and likely mistakes should the cleaner is put under a single do-file.
forval y = 2002/2022 {
	cap confirm file "$gdDo/Module Cleaner/`y'.do"
	if _rc != 0 {
		di "File for the year does not exist"
	}
	else {
		di "No action needed"		
	}
	do "$gdDo/Module Cleaner/`y'.do"
}
**** Labeling all data and converting strings to numeric
foreach y in 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 {
	use "$gdTemp/SUS_Mod`y'.dta", clear
	cap drop if kode == ""
	cap drop if kode == .
	isid urut kode
	label variable year 		"SUSENAS year"
	label variable provcode 	"BPS Province code from the SUSENAS year"
	label variable urban	 	"Is Urban"
	label variable kabcode  	"BPS Kabupaten code from the SUSENAS year"
	label variable urut		 	"HH Identifier"
	label variable mod		 	"SUSENAS module"
	label variable kode			"Food item code, excluding composites"
	label variable q			"Total quantity consumed (Last 1 week)"
	label variable v			"Total values consumed (Last 1 week)"
	label variable c			"Total calories (Last 1 week)"
	label variable hhsize		"Household size"
	label variable weind		"Individual weights (unique to HH)"
	label variable wert 		"Household weights (unique to HH)"
	cap erase "$gdTemp/SUS_Mod`y'.dta"
	save "$gdOutput/SUS_Mod`y'.dta", replace 
}
	