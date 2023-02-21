cd "C:\Users\wb594719\OneDrive - WBG\Documents\GitHub\IDN-2017PPP\Output"

foreach t in 02 03 {
    use "SUS_Mod`t'", clear
    
    gen code02 = kode
	destring code02, replace
	
	merge m:1 code02 using "${gdTemp}/crosswalk-2002.dta", keepusing(code04 code05 code06 code15 code17 code18 item02 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item02 
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }
    
foreach t in 04 {
    use "SUS_Mod`t'", clear
    
    gen code04 = kode
	destring code04, replace
	
	merge m:1 code04 using "${gdTemp}/crosswalk-2004.dta", keepusing(code02 code05 code06 code15 code17 code18 item04 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item04 
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }

foreach t in 05 {
    use "SUS_Mod`t'", clear
    
    gen code05 = kode
	destring code05, replace
	
	merge m:1 code05 using "${gdTemp}/crosswalk-2005.dta", keepusing(code02 code04 code06 code15 code17 code18 item05 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item05
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }

foreach t in 06 07 08 09 10 11 12 13 14 {
    use "SUS_Mod`t'", clear
    
    gen code06 = kode
	destring code06, replace
	
	merge m:1 code06 using "${gdTemp}/crosswalk-2006.dta", keepusing(code02 code04 code05 code15 code17 code18 item06 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item06
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }    
    
foreach t in 15 16 {
    use "SUS_Mod`t'", clear
    
    gen code15 = kode
	destring code15, replace
	
	merge m:1 code15 using "${gdTemp}/crosswalk-2015.dta", keepusing(code02 code04 code05 code06 code17 code18 item15 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item15
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }    
    
foreach t in 17 {
    use "SUS_Mod`t'", clear
    
    gen code17 = kode
	destring code17, replace
	
	merge m:1 code17 using "${gdTemp}/crosswalk-2017.dta", keepusing(code02 code04 code05 code06 code15 code18 item17 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item17
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }        
    
foreach t in 18 19 20 21 22 {
    use "SUS_Mod`t'", clear
    
    gen code18 = kode
	destring code18, replace
	
	merge m:1 code18 using "${gdTemp}/crosswalk-2018.dta", keepusing(code02 code04 code05 code06 code15 code17 item18 composite)
	drop if _merge == 2
	drop _merge
    
    gen item = item18
    
	keep provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert year
	order year provcode urban kabcode urut mod kode item q v c hhsize code02 code04 code05 code06 code15 code17 code18 weind wert 
    
    save, replace
    }        