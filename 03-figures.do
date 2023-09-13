
clear all
set trace off

           
use "${gdOutput}/1-index-povrate-2019-2021-2.dta", clear
gen population = 1
collapse (sum) population (median) pdef_re_fo_str pdef_re_ps_str ///
         pdef_re_mx_str pdef_re_wr_str pdef_re_fo_reg pdef_re_ps_reg ///
         pdef_re_mx_reg pdef_re_wr_reg [fw=int(weind)], by(year prov provname urban)

save "${gdTemp}/stat-figures.dta", replace
export excel using "${gdOutput}/stat-figures.xls", firstrow(variables) replace

/* graph scatterplot: population  - index */
twoway scatter population pdef_re_mx_reg
graph export "${gdOutput}/Graphs2/fig2-pop-index-scatter.png", as(png) replace

/* graph scatterplot: population  - index with rent - rural */
twoway (scatter population pdef_re_mx_reg) (scatter population pdef_re_wr_reg) if urban==0
graph export "${gdOutput}/Graphs2/fig3-pop-indexrent-rur.png", as(png) replace

/* graph scatterplot: population  - index with rent - urban */
twoway scatter population pdef_re_wr_reg if urban==1
graph export "${gdOutput}/Graphs2/fig3-pop-indexrent-urb.png", as(png) replace
