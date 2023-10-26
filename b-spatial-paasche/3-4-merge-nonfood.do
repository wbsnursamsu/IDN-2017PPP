	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */
    use "${gdOutput}/spdef-med-hh-2010-ps.dta", clear
    forval t=2011/2022 {
        append using "${gdOutput}/spdef-med-hh-`t'-ps.dta"
    }
    save "${gdOutput}/spdef-med-ps-2010-2022.dta", replace

    /* Province */
    use "${gdOutput}/spdef-med-ps-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov year    
    compress
    save "${gdOutput}/spdef-med-prv-ps-2010-2022.dta", replace   

	/* Regency */    
    use "${gdOutput}/spdef-med-ps-2010-2022.dta", clear    
    collapse (median) pdef [weight = popw] , by(prov rege year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov rege year    
    compress
    save "${gdOutput}/spdef-med-reg-ps-2010-2022.dta", replace   
	
    /* Stratum */    
    use "${gdOutput}/spdef-med-ps-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov urban year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"
    
    sort prov urban year
    compress
    save "${gdOutput}/spdef-med-str-ps-2010-2022.dta", replace   
    