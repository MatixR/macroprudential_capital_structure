* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates graphs
cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear
set more off
keep if unbalance_panel == 2007 & multinational ==1
#delimit;
drop if missing(leverage_w,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr
tempfile tmp
keep ifscode year country 
bysort ifscode year: keep if _n==1
save `tmp'
use "\cleaning\temp\IBRN.dta", clear
keep if quarter == 4
merge 1:1 ifscode year using `tmp'
keep if _merge==3
drop _merge

//===========================================================
//====== Box plot of datapoints across countries for each MPP =======
//===========================================================

keep c_*_y ifscode year
drop c_sscb_y
preserve
rename c_*_y points#, renumber
egen tag = group(ifscode year)
reshape long points, i(tag) j(mpi)
#delimit;
graph hbox points, over(mpi,
relabel(1 "Capital buffer - real estate" 
        2 "Capital buffer - consumers"
		3 "Capital buffer - others"
		4 "Capital requirements"
		5 "Concentration limits"
		6 "Interbank exposure limits"
		7 "LTV ratio limits"
		8 "Reserve requirememts - foreign"
		9 "Reserve requirememts - local")) 
 ytitle("Data points") 
graphregion(color(white)) bgcolor(white);
#delimit cr
graph export "\analysis\output\graphs\box_plot_data.eps", as(eps) replace
//===========================================================
//====== Box plot of SD across countries for each MPP =======
//===========================================================
restore
foreach var of varlist c_*_y{
bysort ifscode (year): egen `var'_sd = sd(`var')
}
bysort ifscode: keep if _n==1
drop c_*_y year
rename c_*_sd sd#, renumber
reshape long sd, i(ifscode) j(mpi)
// now...
#delimit;
graph hbox sd, over(mpi,
relabel(1 "Capital buffer - real estate" 
        2 "Capital buffer - consumers"
		3 "Capital buffer - others"
		4 "Capital requirements"
		5 "Concentration limits"
		6 "Interbank exposure limits"
		7 "LTV ratio limits"
		8 "Reserve requirememts - foreign"
		9 "Reserve requirememts - local")) 
ytitle("Standard deviations")
graphregion(color(white)) bgcolor(white);
#delimit cr
graph export "\analysis\output\graphs\box_plot_sd.eps", as(eps) replace


//===========================================================
//====== Line graph of leverage vs macroprudential (each separetly) =======
//===========================================================

cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear
set more off
keep if unbalance_panel == 2007 & multinational ==1
#delimit;
drop if missing(leverage_w,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr
tempfile tmp1
gen leverage_re = leverage_w - 1
bysort year: egen leverage_avg = mean(leverage_re)
bysort year: egen leverage_sd = sd(leverage_re)
bysort year: keep if _n==1
keep leverage_sd leverage_avg year
gen lb=leverage_avg-leverage_sd
gen ub=leverage_avg+leverage_sd
save `tmp1'

use "\cleaning\temp\IBRN.dta", clear
foreach var of varlist c_*_y{
bysort year: egen `var'_avg = mean(`var')
bysort year: egen `var'_sd = sd(`var')
}
bysort year: keep if _n==1

merge 1:1 year using `tmp1'
keep if _merge==3
drop _merge

set obs `=_N+1'
replace year = 2007 if missing(year)
replace leverage_avg = 0 if missing(leverage_avg)
replace lb = 0 if missing(lb)
replace ub = 0 if missing(ub)

foreach var of varlist c_*_y{
replace `var'_avg = 0 if missing(`var'_avg)
replace `var'_sd = 0 if missing(`var'_sd)
gen `var'_lb=`var'_avg-`var'_sd
gen `var'_ub=`var'_avg+`var'_sd
}

sort year
#delimit;
graph twoway (line leverage_avg c_sscb_res_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )),  saving(buffer1, replace)
graphregion(color(white)) bgcolor(white) 
legend( col(1) order(1 "Leverage" 2 "Capital buffer - real est.") );

graph twoway (line leverage_avg c_sscb_cons_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(buffer2, replace)
graphregion(color(white)) bgcolor(white)
legend(col(1) order(1 "Leverage" 2 "Capital buffer - cons.") );

graph twoway (line leverage_avg c_sscb_oth_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(buffer3, replace)
graphregion(color(white)) bgcolor(white)
legend( col(1) order(1 "Leverage" 2 "Capital buffer - others") );

graph twoway (line leverage_avg c_cap_req_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(capital, replace)
graphregion(color(white)) bgcolor(white)
legend(col(1) order(1 "Leverage" 2 "Capital Requirements") );

graph twoway (line leverage_avg c_concrat_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(concentration, replace)
graphregion(color(white)) bgcolor(white)
legend( col(1) order(1 "Leverage" 2 "Concentration limits") );

graph twoway (line leverage_avg c_ibex_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(interbank, replace)
graphregion(color(white)) bgcolor(white)
legend( col(1) order(1 "Leverage" 2 "Interbank exposure") );

graph twoway (line leverage_avg c_ltv_cap_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(ltv, replace)
graphregion(color(white)) bgcolor(white)
legend( col(1) order(1 "Leverage" 2 "LTV ratio limits") );

graph twoway (line leverage_avg c_rr_foreign_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(rrf, replace)
graphregion(color(white)) bgcolor(white)
legend(col(1) order(1 "Leverage" 2 "Reserve req. - foreign") );

graph twoway (line leverage_avg c_rr_local_y_avg year, 
clwidth( medthick   medthick ) clcolor( edkblue  maroon )
 clpattern(solid dash )), saving(rrl, replace)
graphregion(color(white)) bgcolor(white)
legend(col(1) order(1 "Leverage" 2 "Reserve req. - local") );
#delimit cr

#delimit;
 gr combine buffer1.gph buffer2.gph buffer3.gph 
 capital.gph concentration.gph interbank.gph ltv.gph
 rrf.gph rrl.gph, 
 graphregion(color(white));
 #delimit cr
  graph export "\analysis\output\graphs\time_graphs.eps", as(eps) replace
