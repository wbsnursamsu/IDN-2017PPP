	#delimit;
	use "${gdOutput}/1-povrate-index-2010-2022-mean.dta", clear;
    
    collapse (mean) poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55 [w=weind], by(year);
	
	twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_defl_ipl215 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_defl_ipl365 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_defl_ipl685 year, lp(-) lcol(forest_green)), 
        title("NPL vs Standard vs Adjusted IPL - National") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP - Standard") 
               label(3 "IPL 2.15 USD 2017 PPP - Deflated") 
               label(4 "IPL 3.65 USD 2017 PPP - Standard") 
               label(5 "IPL 3.65 USD 2017 PPP - Deflated") 
               label(6 "IPL 6.85 USD 2017 PPP - Standard") 
               label(7 "IPL 6.85 USD 2017 PPP - Deflated")) 
               xlabel(2010(1)2022, labsize(vsmall)) ylabel(,labsize(vsmall)) leg(size(vsmall));
        graph export "${gdOutput}/Graphs-mean/1-povrate-comparison-nat.png", replace;
	#delimit cr
	
	/* urban rural */
	#delimit;		
	use "${gdOutput}/1-povrate-index-2010-2022-mean.dta", clear;
	
	collapse (mean) poor_npl 
        poor_ipl215 poor_defl_ipl215 
		poor_ipl365 poor_defl_ipl365 
		poor_ipl685 poor_defl_ipl685
		poor_ipl19 poor_defl_ipl19
		poor_ipl32 poor_defl_ipl32
		poor_ipl55 poor_defl_ipl55 [w=weind], by(year urban);
		
	twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_defl_ipl215 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_defl_ipl365 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_defl_ipl685 year, lp(-) lcol(forest_green)) 
        if urban==1, 
        title("NPL vs Standard vs Adjusted IPL - National Urban") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP - Standard") 
               label(3 "IPL 2.15 USD 2017 PPP - Deflated") 
               label(4 "IPL 3.65 USD 2017 PPP - Standard") 
               label(5 "IPL 3.65 USD 2017 PPP - Deflated") 
               label(6 "IPL 6.85 USD 2017 PPP - Standard") 
               label(7 "IPL 6.85 USD 2017 PPP - Deflated")) 
               xlabel(2010(1)2022, labsize(vsmall)) ylabel(,labsize(vsmall)) leg(size(vsmall));
        graph export "${gdOutput}/Graphs-mean/1-povrate-comparison-nat-urb.png", replace;
      
	twoway 
        (line poor_npl year, lp(l) lcol(black)) 
        (line poor_ipl215 year, lp(l) lcol(red)) 
        (line poor_defl_ipl215 year, lp(-) lcol(red)) 
        (line poor_ipl365 year, lp(l) lcol(blue)) 
        (line poor_defl_ipl365 year, lp(-) lcol(blue)) 
        (line poor_ipl685 year, lp(l) lcol(forest_green)) 
        (line poor_defl_ipl685 year, lp(-) lcol(forest_green)) 
        if urban==0, 
        title("NPL vs Standard vs Adjusted IPL - National Rural") 
        note("Deflator uses household UV for food and prices for non-food, and is at regency level")
        xtitle("year") ytitle("P0 Rate") 
        legend(label(1 "NPL") 
               label(2 "IPL 2.15 USD 2017 PPP - Standard") 
               label(3 "IPL 2.15 USD 2017 PPP - Deflated") 
               label(4 "IPL 3.65 USD 2017 PPP - Standard") 
               label(5 "IPL 3.65 USD 2017 PPP - Deflated") 
               label(6 "IPL 6.85 USD 2017 PPP - Standard") 
               label(7 "IPL 6.85 USD 2017 PPP - Deflated")) 
               xlabel(2010(1)2022, labsize(vsmall)) ylabel(,labsize(vsmall)) leg(size(vsmall));
        graph export "${gdOutput}/Graphs-mean/1-povrate-comparison-nat-rur.png", replace;
		
	#delimit cr
	
	/* regions */	
	#delimit;
	use "${gdOutput}/1-povrate-index-2010-2022-mean.dta", clear	;
        collapse (mean) 
			poor_npl 
			poor_ipl215 poor_defl_ipl215 
			poor_ipl365 poor_defl_ipl365 
			poor_ipl685 poor_defl_ipl685
			poor_ipl19 poor_defl_ipl19
			poor_ipl32 poor_defl_ipl32
			poor_ipl55 poor_defl_ipl55 
			[w=weind], by(year region urban);
	
		twoway 	
			(line poor_ipl365 year, lp(solid) lcol(maroon) lw(medthick)) 
			(line poor_defl_ipl365 year, lp(dash) lcol(maroon) lw(medthick))
			if urban==0, 
			by(region, scale(0.75) title("Standard vs Deflated IPL 3.65 - by Rural Region") graphregion(color(white)))
			legend(label(1 "IPL 3.65 USD - Standard") 
				   label(2 "IPL 3.65 USD - Deflated"))
			xtitle("Year") ytitle("P0 Rate")
		    xlabel(2010(1)2022, labsize(vsmall)) ylabel(,labsize(vsmall)) leg(size(vsmall));
		graph export "$gdOutput/Graphs-mean/1-povrate-comparison-region-rur.png", replace;

		twoway 	
			(line poor_ipl365 year, lp(solid) lcol(navy) lw(medthick)) 
			(line poor_defl_ipl365 year, lp(dash) lcol(navy) lw(medthick))
			if urban==1, 
			by(region, scale(0.75) title("Standard vs Deflated IPL 3.65 - by Urban Region") graphregion(color(white)))
			legend(label(1 "IPL 3.65 USD - Standard") 
				   label(2 "IPL 3.65 USD - Deflated"))
			xtitle("Year") ytitle("P0 Rate")
		    xlabel(2010(1)2022, labsize(vsmall)) ylabel(,labsize(vsmall)) leg(size(vsmall));
		graph export "$gdOutput/Graphs-mean/1-povrate-comparison-region-urb.png", replace;
		