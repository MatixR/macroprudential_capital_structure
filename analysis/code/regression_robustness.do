//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 12/04/2017                                                           //
// Description: this file runs robustness checks                              //
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
local dependent         "leverage adj_leverage longterm_debt loans_leverage"	        					  			   
local independent       "b_ovr_rest b_ovr_cong b_cap_str b_off_sup b_ext_gov_ind"
local independent_ds    "b_ovr_rest_ds b_ovr_cong_ds b_cap_str_ds b_off_sup_ds b_ext_gov_ind_ds"	        					  	        					  
local firm_control      "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control   "inflation interest_rate gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"
local no_risk_control   "fixed_total_w log_fixedasset_w profitability_w"
local log_sales_control "risk_w fixed_total_w log_sales_w profitability_w opportunity_w"

//============================================================================//
//Table 2: robustness checks, unrestricted panel on observation               //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

foreach var of local independent{
eststo: reghdfe leverage `var'                                               ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

}
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

esttab using "\analysis\output\tables\regressions\robust_obs_table.tex",     ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent')                                                      ///
   keep(`independent' tax_rate)                                              ///
   indicate("\emph{Firm controls} = `firm_control'"                          ///
            "\emph{Country controls} = `country_control'",                   ///
			label(\checkmark ""))                                            ///
   refcat(b_ovr_rest "\emph{Bank regulation}"                                ///
          b_ovr_rest_ds "\emph{Spillovers from bank regulation}"             ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fe_1 fe_2,                                             ///
         fmt(%9.0fc %9.0fc a3)                                               ///
         labels("Observations"  "Number of Multinationals" "\$R^2\$"         ///
          "Multinational $\times$ year fixed effects" "Industry fixed effects"))   
		                                                                 		  
//============================================================================//
//Table 3: robustness checks, restricted panel on variables                   //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

* No negative profit
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control'                 ///
						     if profitability>0,                             ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* No mergers and acquisitions
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control'                 ///
						     if mover_indicator==1,                          ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* Considering only last survey (2011)
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control'                 ///
						     if year!=2007,                                  ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* Removing risk and opportunity variables
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `no_risk_control' `country_control',             ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* Alternative measure of size (log of sales)
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `log_sales_control' `country_control',           ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* Weighted observation by number of firms in country
eststo: reghdfe leverage `independent'                                       ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control'                 ///
							[aweight=number_firms],                          ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace

* Only listed firms
*eststo: reghdfe leverage `independent'                                       ///
*			                 tax_rate                                        ///    
*                           `firm_control' `country_control'                 ///
*							 if listed_tag == 1,                             ///
*				             absorb(multinationals#year nace2)               ///
*                             vce(cluster multinationals)                 
*estadd local fe_1 "\checkmark" , replace
*estadd local fe_2 "\checkmark" , replace


esttab using "\analysis\output\tables\regressions\robust_var_table.tex",     ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent')                                                      ///
   keep(`independent' tax_rate)                                              ///
   indicate("\emph{Firm controls} = `firm_control'"                          ///
            "\emph{Country controls} = `country_control'",                   ///
			label(\checkmark ""))                                            ///
   refcat(b_ovr_rest "\emph{Bank regulation}"                                ///
          b_ovr_rest_ds "\emph{Spillovers from bank regulation}"             ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fe_1 fe_2,                                             ///
         fmt(%9.0fc %9.0fc a3)                                               ///
         labels("Observations"  "Number of Multinationals" "\$R^2\$"         ///
          "Multinational $\times$ year fixed effects" "Industry fixed effects"))                       		   
		  
