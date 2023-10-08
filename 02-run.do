********************************************************************************
*	Project			: 2017 PPP IPL SPATIAL DEFLATOR

* CHECK DOFILE IN 05 and 06 and 08 FIRST TO AVOID PERIOD CUT !!!

********************************************************************************

* Please run 00_1_Init.do first before executing this do-file.
clear all
set more off
set maxvar 10000

* Check if filepaths have been established using 00_1_Init.do
if "${gdData}"=="" {
	display as error "Please run 00_1_Init.do first. Adjust the parameters according to your local directories"
	error 1
}
	
**** Step 1: Cleaning SUSENAS dataset
do "$gdDo\04-cons_mod_cleaning.do"
		
**** SPATIAL PAASCHE
cap noi do "${gdDo}/b-spatial-paasche/0-rent-price.do"

cap noi do "${gdDo}/b-spatial-paasche/1-data-setup.do"
if (_rc) {
    beep
	sleep 250
	beep
	sleep 250
	beep
	}

cap noi do "${gdDo}/b-spatial-paasche/2-paasche.do"
cap noi do "${gdDo}/b-spatial-paasche/3-merge-new.do"
cap noi do "${gdDo}/b-spatial-paasche/4-povrate-calculation.do"
		
**** Step 3: Reconstruct Poverty Lines using Laspeyres Spatial Index 
do "$gdDo\06-povline_reconstruction.do"
		
// **** Step 4: Running some Robustness Check on the index
// do "$gdDo\07-robustness_check.do"
		
**** Step 5: Calibrating Spatial Laspeyres to match published poverty rate
do "$gdDo\08-calibration.do"

**** Step 6: Validating calibration results
do "$gdDo\09-validation.do"