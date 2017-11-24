//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 24/11/2017                                                           //
// Description: this file runs the summary statistics table                   //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
if "`c(hostname)'" != "EG3523" {
global STATAPATH "S:"
}
else if "`c(hostname)'" == "EG3523" {
global STATAPATH "C:/Users/u1273941/Research/Projects/macroprudential_capital_structure"
}
cd "$STATAPATH"     
set more off

* Particular
eststo clear

* Defining macros
local dependent       "leverage"	        					  			   
local independent     "b_ovr_rest b_ovr_cong b_int_str b_off_sup b_pri_mon b_mor_haz"
local independent_ds  "b_ovr_rest_ds b_ovr_cong_ds b_int_str_ds b_off_sup_ds b_pri_mon_ds b_mor_haz_ds"	        					  	        					  
local firm_control    "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control "inflation gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"

* Drop observations with missing values
#delimit;
drop if missing(leverage,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w, tax_rate,
inflation, gdp_growth_rate, private_credit_GDP, 
political_risk, exchange_rate_risk, law_order);
#delimit cr

//============================================================================//
//Table 1: Summary statistics                                                 //
//============================================================================//


estpost tabstat                                                              ///
`dependent' `independent' `independent_ds'                                   ///
tax_rate tax_rate_ds `firm_control' `country_control',                       ///                         
statistics(count mean sd min p50 max) columns(statistics)                    ///

esttab using "\analysis\output\tables\summary\summary.tex",                  ///
  replace label noobs nomtitles nonumbers fragment booktabs gaps collabels(none) ///
  cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))")       ///
  refcat(leverage "\emph{Dependent variables}"                               ///
         b_ovr_rest "\emph{Bank regulation - direct}"                        ///
         b_ovr_rest_ds "\emph{Bank regulation - spillover}"                  ///
         tax_rate "\emph{Corporate tax}"                                     ///
	     risk_w "\emph{Firm characteristics}"                                ///
         inflation "\emph{Macroeconomic controls}", nolabel)		         ///
     

//============================================================================//
//Table 2: Number of firms per country per type                               //
//============================================================================//

* Parent firms and subsidiary by host country collumns
bysort id: keep if _n == 1

estpost tab country parent 
#delimit;
esttab using "\analysis\output\tables\summary\number_firms_orbis_1.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr

* Parent firms and subsidiary by host country collumns
use "\cleaning\output\dataset_orbis100_2.dta", clear
keep if unbalance_panel == 2007 & multinational ==1
#delimit;
drop if missing(leverage_w,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr

egen firm_parent_ID = group(id id_P)
bysort firm_parent_ID: keep if _n == 1
estpost tab country_id_P 

#delimit;
esttab using "\analysis\output\tables\summary\number_firms_orbis_2.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr
* Obs: final table merged by hand

* Movers
bysort id: gen dup = cond(_N==1,1,_n)
drop if dup==1
rename dup Movers
estpost tab Movers
#delimit;
esttab using "\analysis\output\tables\summary\movers.tex", 
cell(b) noobs fragment replace; 
#delimit cr
