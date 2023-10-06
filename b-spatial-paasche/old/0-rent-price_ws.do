

clear all
set trace off
	
forval t=2019/2019 {
    use "${gdCons}/sus-cm-mar-2019-full.dta", clear
    keep if inlist(ditem_all,"rent")            // rent only for rent price index 

    * match with hh susenas data (from SUSENAS Pipeline)
        merge m:1 urut provcode kabcode using "${gdSush}/sus-hh-mar-2019.dta", keepusing(electricity sanitation water gas house_own house_rent house_offcert house_areapc roof wall floor elec_type sani_type disp_type house_stat hcert_type roof_type wall_type floor_type) nogen
    
    g hhid = urut
    g prov = provcode
    g muni = kabcode
    g popw = wert
    
    * monthly rent
        g rent = v 
    
    * predicted rent
		tempfile befimp
		save `befimp'
		
        g pred_rent = .
        g areacode = provcode*10000 + kabcode*100 + urban
        reg rent house_areapc i.elec_type i.sani_type i.disp_type i.hcert_type i.roof_type i.wall_type i.floor_type i.areacode [w=wert], ro 
		
		keep rent house_areapc elec_type sani_type disp_type hcert_type roof_type wall_type floor_type areacode
		expand 1
		
		replace house_areapc=7.2 if house_areapc==.
		replace elec_type=1 if elec_type=.
		sani_type=2 disp_type=1 hcert_type=1 roof_type=1 wall_type=1 floor_type=1
		
		predict 
		
		
		
**# Bookmark #1
        adjust house_areapc=7.2 elec_type=1 sani_type=2 disp_type=1 hcert_type=1 roof_type=1 wall_type=1 floor_type=1, generate(pred_rent1 err) xb
        
    * housing ownership status
        g hstat = 1 if inlist(q,1,4) 
            replace hstat = 2 if inlist(q,2,3)
            replace hstat = 3 if inlist(q,5,6)        
        la def hstat 1 "Own" 2 "Rent" 3 "Others"
        la val hstat hstat
        
    * replace unit to 1 (unit has wrong entry as housing status)
        replace q = 1 if ditem_all=="rent"      // assuming all housing quantity is 1
        
    * replace rent to higher aggregation (rent is monthly)
        egen rent_1=wtmean(v) if rent!=0 , weight(popw) by (provcode kabcode urban)  // lower level
        egen rent_2=wtmean(v) if rent!=0 , weight(popw) by (provcode urban) 
        egen rent_3=wtmean(v) if rent!=0 , weight(popw) by (urban)   // reference level
    
        gen rent_nat = rent_3 // national or ref rent price 
        gen rent_str = rent_1
        forval j=2/3 {
            replace rent_str = rent_`j' if rent_str==.
        }
    
    * generate price index
        g rent_pi = rent_str/rent_nat * q
        
    * collapse to provcode urban
        collapse (median) rent_pi [w=popw], by(provcode urban)
        
    * save
        save "${gdOutput}/rent-price-`t'.dta", replace
        
        table (urban provcode) (), stat(mean rent_pi) nformat(%3.2f) nototals
        collect label levels urban 0 "Rural" 1 "Urban"

        # delimit ;
        collect label levels provcode
            11	"Nanggroe Aceh Darussalam"
            12	"Sumatera Utara"
            13	"Sumatera Barat"
            14	"Riau"
            15	"Jambi"
            16	"Sumatera Selatan"
            17	"Bengkulu"
            18	"Lampung"
            19	"Kep. Bangka Belitung"
            21	"Kep. Riau"
            31	"DKI Jakarta"
            32	"Jawa Barat"
            33	"Jawa Tengah"
            34	"DI Yogyakarta"
            35	"Jawa Timur"
            36	"Banten"
            51	"Bali"
            52	"Nusa Tenggara Barat"
            53	"Nusa Tenggara Timur"
            61	"Kalimantan Barat"
            62	"Kalimantan Tengah"
            63	"Kalimantan Selatan"
            64	"Kalimantan Timur"
            65  "Kalimantan Utara"
            71	"Sulawesi Utara"
            72	"Sulawesi Tengah"
            73	"Sulawesi Selatan"
            74	"Sulawesi Tenggara"
            75	"Gorontalo"
            76	"Sulawesi Barat"
            81	"Maluku"
            82	"Maluku Utara"
            91	"Papua Barat"
            94	"Papua" ;
        #delimit cr
        
    collect preview
    putexcel set "${gdOutput}/0-rent-price-comp.xlsx", sheet("`t'", replace) modify
    putexcel B2 = collect
    
}     
