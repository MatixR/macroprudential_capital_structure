//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 14/12/2017                                                           //
// Description: this file runs the table with distribution of subsidiary and  //    
//              firms across countries in the benchmark sample                //
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
local dependent       "leverage adj_leverage longterm_debt loans_leverage"	        					  			   
local independent     "b_ovr_rest b_ovr_cong b_cap_str b_off_sup b_ext_gov_ind"
local independent_ds  "b_ovr_rest_ds b_ovr_cong_ds b_cap_str_ds b_off_sup_ds b_ext_gov_ind_ds"	        					  	        					  
local firm_control    "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control "inflation interest_rate gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"

use "\cleaning\output\dataset_bank_regulation.dta", clear

* Drop observations with missing values
#delimit;
drop if missing(leverage,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w, tax_rate,
inflation, interest_rate, gdp_growth_rate, private_credit_GDP, 
political_risk, exchange_rate_risk, law_order,
b_ovr_rest, b_ovr_cong, b_cap_str, b_off_sup, b_ext_gov_ind);
#delimit cr      

* Create number of firms per multinational
bysort multinationals year: egen number_firms_mult =  count(firms)

* Create number of countries per multinational
by multinational_year country_id, sort: gen number_countries_mult = _n == 1 
by multinational_year: replace number_countries_mult = sum(number_countries_mult)
by multinational_year: replace number_countries_mult = number_countries_mult[_N] 

* Remove singletons by hand
drop if missing(nace2)     
summarize number_firms_mult number_countries_mult
while `r(min)' == 1{
drop if number_firms_mult == 1   
drop if number_countries_mult == 1
drop number_firms_mult number_countries_mult
bysort multinationals year: egen number_firms_mult =  count(firms)
by multinational_year country_id, sort: gen number_countries_mult = _n == 1 
by multinational_year: replace number_countries_mult = sum(number_countries_mult)
by multinational_year: replace number_countries_mult = number_countries_mult[_N] 
summarize number_firms_mult number_countries_mult   
}          

//============================================================================//
//Table 3: Number of firms per country per type                               //
//============================================================================//
eststo clear

* Parent firms and subsidiary by host country collumns
eststo: quiet estpost tab name_firm year 
esttab using "\analysis\output\tables\summary\number_firms_table.tex",       ///
cell(b(fmt(%9.0fc))) collabels(none)      ///
unstack noobs nonumber nomtitle fragment booktabs gaps replace               ///
varlabels(`e(labels)', blist(Total "\hline \addlinespace "))    ///
   eqlabels(none)                                                            ///
             
* Parent firms and subsidiary by host country collumns
eststo clear
set matsize 1000
eststo: quiet estpost tab name_parent year 

esttab using "\analysis\output\tables\summary\number_parent_table.tex",      ///
cell(b(fmt(%9.0fc))) collabels(none)      ///
unstack noobs nonumber nomtitle fragment booktabs gaps  replace              ///
varlabels(`e(labels)', blist(Total "\hline \addlinespace "))    ///
   eqlabels(none)                                                           
