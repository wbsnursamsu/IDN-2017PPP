	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */
    use "${gdOutput}/spdef-med-hh-2010-rn.dta", clear
    forval t=2011/2022 {
        append using "${gdOutput}/spdef-med-hh-`t'-rn.dta"
    }
    save "${gdOutput}/spdef-med-rn-2010-2022.dta", replace

    /* Province */
    use "${gdOutput}/spdef-med-rn-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov year    
    compress
    save "${gdOutput}/spdef-med-prv-rn-2010-2022.dta", replace   

	/* Regency */    
    use "${gdOutput}/spdef-med-rn-2010-2022.dta", clear    
    collapse (median) pdef [weight = popw] , by(prov rege year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov rege year    
    compress
    save "${gdOutput}/spdef-med-reg-rn-2010-2022.dta", replace   
	
    /* Stratum */    
    use "${gdOutput}/spdef-med-rn-2010-2022.dta", clear
    collapse (median) pdef [weight = popw] , by(prov urban year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"
    
    sort prov urban year
    compress
    save "${gdOutput}/spdef-med-str-rn-2010-2022.dta", replace   
    