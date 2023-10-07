	*----------------------------------------------------------------------*
	* MERGE SPATIAL DEFLATOR
	*----------------------------------------------------------------------*

clear all

    /* Merge all in HH index */
    use "${gdOutput}/paasche-deflator-hh-2010-wr.dta", clear
    forval t=2011/2022 {
        append using "${gdOutput}/paasche-deflator-hh-`t'-wr.dta"
    }
    save "${gdOutput}/paasche-deflator-wr-ALL.dta", replace

    /* Province */
    use "${gdOutput}/paasche-deflator-wr-ALL.dta", clear
    collapse (median) pdef [weight = popw] , by(prov year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov year    
    compress
    save "${gdOutput}/paasche-deflator-province-ALL.dta", replace   

    /* Stratum */    
    use "${gdOutput}/paasche-deflator-wr-ALL.dta", clear
    collapse (median) pdef [weight = popw] , by(prov urban year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"
    
    sort prov urban year
    compress
    save "${gdOutput}/paasche-deflator-stratum-ALL.dta", replace   
    
    /* Regency */    
    use "${gdOutput}/paasche-deflator-wr-ALL.dta", clear    
    collapse (median) pdef [weight = popw] , by(prov rege year) 
    replace pdef=1 if pdef==.
    la var pdef "Paasche spatial deflator with rent"

    sort prov rege year    
    compress
    save "${gdOutput}/paasche-deflator-regency-ALL.dta", replace   