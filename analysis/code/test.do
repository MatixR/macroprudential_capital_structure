//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 12/11/2017                                                           //
// Description: this file runs the benchmark table                            //
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
use "\cleaning\output\dataset_bank_regulation.dta", clear

* Particular
eststo clear
set more off

* Defining macros
local dependent       "leverage adj_leverage longterm_debt loans_leverage"	        					  			   
local independent     "b_ovr_rest b_ovr_cong b_cap_str b_off_sup b_ext_gov_ind"
local independent_alt     "b_ovr_rest  b_bank_owns_fc b_int_str_cap b_off_sup b_ext_gov_ind"
local independent_ds  "b_ovr_rest_ds b_ovr_cong_ds b_cap_str_ds b_off_sup_ds b_ext_gov_ind_ds"	        					  	        					  
local firm_control    "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control "inflation interest_rate gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"


//============================================================================//
//Table 1: benchmark regressions                                              //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

foreach var of local independent{
eststo: reghdfe leverage    `var'                                            ///
			                ,  absorb(multinationals#year ifscode#nace2)   keepsingletons           ///						 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
estadd local fe_4 "\checkmark" , replace
}
eststo: reghdfe leverage    `independent'                                    ///
			                 ,  absorb(multinationals#year ifscode#nace2)   keepsingletons           ///						 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
estadd local fe_4 "\checkmark" , replace
			
esttab using "\analysis\output\tables\temp\multinationals_times_year_country_times_sector_fe_ws.tex",      ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent')                                                      ///
   keep(`independent' )                                              ///
   stats(N N_clust r2 fe_1 fe_2,                                             ///
         fmt(%9.0fc %9.0fc a3)                                               ///
         labels("Observations"  "Number of Multinationals" "\$R^2\$" ///
		 "Multinational $\times$ year fixed effects" "Country $\times$ Industry fixed effects")) 
		  

