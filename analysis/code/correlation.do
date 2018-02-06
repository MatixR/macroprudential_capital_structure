//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 24/11/2017                                                           //
// Description: this file runs the correlation table                          //
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
	
	
	* Bank Regulation Survey
lab var b_sec_act_ba "Restrictions on securities activities"
lab var b_ins_act_ba "Restrictions on insurance activities"
lab var b_real_est_act_ba "Restrictions on real estate activities"
lab var b_ovr_rest "Restrictions on banking activities"
lab var b_bank_owns_fc "Bank owning nonfinancial firm"
lab var b_firm_owns_fc "Nonfinancial firm owning bank"
lab var b_financial_owns_fc "Financial firm owning bank"
lab var b_ovr_cong "Financial conglomerates restrictiveness"
lab var b_lim_for  "Limitations on foreign bank"
lab var b_entry_req "Entry requirements"
lab var b_frac_den "Entry applications denied"
lab var b_dom_den "Domestic applications denied"
lab var b_for_den "Foreign applications denied"
lab var b_cap_str  "Capital regulatory strigengy"
lab var b_ovr_str_cap  "Overall capital strigency"
lab var b_int_str_cap  "Initial capital stringency"
lab var b_off_sup  "Official supervisory power"
lab var b_pri_mon  "Private monitoring"
lab var b_dep_size  "Deposit insurance to bank asset"
lab var b_ins_dep  "Funding with insured deposit"
lab var b_mor_haz  "Moral hazard mitigation"
lab var b_conc_dep "Bank concentration in deposits"
lab var b_conc_ass "Bank concentration in assets"
lab var b_for_sha  "Foreign-owned banks"
lab var b_gov_sha  "Government-owned banks"
lab var b_ext_aud_gov "Strength of external audit"
lab var b_fin_trans_gov "Financial statement transparency"
lab var b_acc_prac_gov "Accounting practices"
lab var b_ext_rat_gov "External ratings"
lab var b_ext_gov_ind "External governance"
//============================================================================//
//Table 1: Summary statistics by firm                                         //
//============================================================================//
estpost correlate                                                              ///
`independent', matrix                                       ///
                    ///

esttab using "\analysis\output\tables\summary\correl.tex",                  ///
  replace label nomtitles nonumbers not unstack compress ///
  noobs fragment booktabs gaps collabels(none) ///
 
