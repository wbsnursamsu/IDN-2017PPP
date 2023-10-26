	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */
    use "${gdOutput}/spdef-mean-hh-2010-wr.dta", clear
    forval t=2011/2022 {
        append using "${gdOutput}/spdef-mean-hh-`t'-wr.dta"
    }
    save "${gdOutput}/spdef-mean-hh-2010-2022-wr.dta", replace

    /* Province */
    use "${gdOutput}/spdef-mean-hh-2010-2022-wr.dta", clear
    collapse (mean) pdef [weight = popw] , by(prov year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov year    
    compress
    save "${gdOutput}/spdef-mean-prv-2010-2022.dta", replace   

    /* Stratum */    
    use "${gdOutput}/spdef-mean-hh-2010-2022-wr.dta", clear
    collapse (mean) pdef [weight = popw] , by(prov urban year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"
    
    sort prov urban year
    compress
    save "${gdOutput}/spdef-mean-str-2010-2022.dta", replace   
    
    /* Regency */    
    use "${gdOutput}/spdef-mean-hh-2010-2022-wr.dta", clear    
    collapse (mean) pdef [weight = popw] , by(prov rege year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov rege year    
    compress
    save "${gdOutput}/spdef-mean-reg-2010-2022.dta", replace   