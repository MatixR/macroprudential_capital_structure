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
local dependent       "leverage adj_leverage longterm_debt loans_leverage"	        					  			   
local independent     "b_ovr_rest b_ovr_cong b_cap_str b_off_sup b_ext_gov_ind"
local independent_ds  "b_ovr_rest_ds b_ovr_cong_ds b_cap_str_ds b_off_sup_ds b_ext_gov_ind_ds"	        					  	        					  
local firm_control    "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control "inflation interest_rate gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"

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
//Table 1: Summary statistics by firm                                         //
//============================================================================//
estpost tabstat                                                              ///
leverage `independent' `independent_ds'                                      ///
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
//Table 2: Summary statistics by multinational                                //
//============================================================================//

* Create number of sectors per multinational
by multinational_year nace2, sort: gen number_sectors_mult = _n == 1 
by multinational_year: replace number_sectors_mult = sum(number_sectors_mult)
by multinational_year: replace number_sectors_mult = number_sectors_mult[_N] 

* Create total of asset per multinational
gen total_toas_mult = total_asset_multinational/1000000

* Create dummy for parent
bysort multinationals year: egen parent_mult = total(parent)
bysort multinational_year: keep if _n == 1

lab var number_firms_mult     "Number of firms"
lab var number_sectors_mult   "Industries"
lab var number_countries_mult "Countries"
lab var total_toas_mult       "Total asset (mn USD)"
lab var parent_mult           "Parent"

label variable number_sectors_mult `"\hspace{0.1cm} `: variable label number_sectors_mult'"'
label variable number_countries_mult `"\hspace{0.1cm} `: variable label number_countries_mult'"'

estpost tabstat                                                              ///
parent_mult number_firms_mult                                                ///
number_sectors_mult number_countries_mult,                                   ///                         
statistics(count mean sd min p50 max) columns(statistics)                    ///

esttab using "\analysis\output\tables\summary\summary_mult.tex",             ///
  replace label noobs nomtitles nonumbers fragment booktabs gaps collabels(none) ///
  cells("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) p50(fmt(0)) max(fmt(0))")       ///
  refcat(number_sectors_mult "Present in:", nolabel)		             
     

