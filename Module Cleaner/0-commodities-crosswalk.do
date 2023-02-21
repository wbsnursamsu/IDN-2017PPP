********************************************************************************
*	Project			: PPP 2017 deflator
*	Task			: Separating commodities crosswalk by year
*	Subtask			: -
*	Input			: Consumption Module Crosswalk
*	Note			: -
********************************************************************************

clear
set more off
cap log close

*** Use crosswalk
use "${gdData}/Crosswalk/consumption_module_crosswalk_cat.dta", clear


*** Split crosswalk
** 2002
preserve
    drop if code02==.
    save "${gdTemp}/crosswalk-2002.dta", replace
restore

** 2004
preserve
    drop if code04==.
    save "${gdTemp}/crosswalk-2004.dta", replace
restore

** 2005
preserve
    drop if code05==.
    save "${gdTemp}/crosswalk-2005.dta", replace
restore

** 2006
preserve
    drop if code06==.
    save "${gdTemp}/crosswalk-2006.dta", replace
restore    

** 2015
preserve
    drop if code15==.
    save "${gdTemp}/crosswalk-2015.dta", replace
restore

** 2017
preserve
    drop if code17==.
    save "${gdTemp}/crosswalk-2017.dta", replace
restore        

** 2018
preserve
    drop if code18==.
    save "${gdTemp}/crosswalk-2018.dta", replace
restore        

