foreach v in jan feb mar apr may jun jul aug sep oct nov dec avg {
	sort year provcode urban code17
	bys year provcode code17: egen p1_`v' = mean(p_g_`v') // Province
	bys year code17: egen p2_`v' = mean(p_g_`v') // National
	}
	
foreach v in jan feb mar apr may jun jul aug sep oct nov dec avg {
	gen dif_`v' = p_g_`v'/p1_`v' 
	}
	