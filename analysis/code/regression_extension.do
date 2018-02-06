//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 14/12/2017                                                           //
// Description: this file runs the extensions table                           //
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
local dependent       "leverage adj_leverage adj_2_leverage debt_leverage longterm_debt"	        					  			   
local independent     "b_ovr_rest b_ovr_cong b_cap_str b_off_sup b_ext_gov_ind"
local independent_ds  "b_ovr_rest_ds b_ovr_cong_ds b_cap_str_ds b_off_sup_ds b_ext_gov_ind_ds"	        					  	        					  
local independent_int "c.b_ovr_rest#c.dfl_1_w c.b_ovr_cong#c.dfl_1_w c.b_cap_str#c.dfl_1_w c.b_off_sup#c.dfl_1_w c.b_ext_gov_ind#c.dfl_1_w"	        					  	        					  
local firm_control    "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w"
local country_control "inflation interest_rate gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order"
local firm_control_norisk    "fixed_total_w log_fixedasset_w profitability_w opportunity_w"

//============================================================================//
//Table 4: Spillover regressions                                              //
//Regressand: leverage                                                        //
//Fixed effects: multinational, year and industry                             //
//============================================================================//
eststo clear

foreach var of local independent{
eststo: reghdfe leverage `var' `var'_ds                                      ///
			                 tax_rate    tax_rate_ds                         ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals year nace2)               /// 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
}
eststo: reghdfe leverage `independent' `independent_ds'                      ///
			                 tax_rate    tax_rate_ds                         ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals year nace2)               /// 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace

			
esttab using "\analysis\output\tables\regressions\spillover_table.tex",      ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent' `independent_ds')                                     ///
   keep(`independent' `independent_ds' tax_rate tax_rate_ds)                 ///
   indicate("\emph{Firm controls} = `firm_control'"                          ///
            "\emph{Country controls} = `country_control'",                   ///
			label(\checkmark ""))                                            ///
   refcat(b_ovr_rest "\emph{Bank regulation}"                                ///
          b_ovr_rest_ds "\emph{Spillovers from bank regulation}"             ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fe_1 fe_2 fe_3,                                        ///
         fmt(%9.0fc %9.0fc a3)                                               ///
   labels("Observations"  "Number of Multinationals" "\$R^2\$"               ///
          "Multinational fixed effects" "Year fixed effects"                 ///
		  "Industry fixed effects"))                                         /// 

//============================================================================//
//Table 4: Interaction with degree of financial leverage regressions          //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year, country*year and industry                //
//============================================================================//
eststo clear

foreach var of local independent{
eststo: reghdfe leverage   c.`var'#c.dfl_1_w                                      ///
			                      dfl_1_w                        ///    
                            `firm_control_norisk ',                ///
				             absorb(multinationals#year ifscode nace2)               /// 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
}
eststo: reghdfe leverage  `independent_int'                      ///
			                 dfl_1_w                             ///    
                            `firm_control_norisk ' ,                ///
				             absorb(multinationals#year ifscode nace2)               /// 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace

			
esttab using "\analysis\output\tables\regressions\risk_table.tex",      ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent_int')                                     ///
   keep(`independent'  dfl_1_w)                 
   indicate("\emph{Firm controls} = `firm_control'"                          ///
            "\emph{Country controls} = `country_control'",                   ///
			label(\checkmark ""))                                            ///
   refcat(b_ovr_rest "\emph{Bank regulation}"                                ///
          b_ovr_rest_ds "\emph{Spillovers from bank regulation}"             ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fe_1 fe_2 fe_3,                                        ///
         fmt(%9.0fc %9.0fc a3)                                               ///
   labels("Observations"  "Number of Multinationals" "\$R^2\$"               ///
          "Multinational $\times$ year fixed effects"                        ///
		  "Country $\times$ year fixed effects"                  ///
		  "Industry fixed effects"))                                         /// 

//============================================================================//
//Table 5: sub-indexes regressions                                            //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

eststo: reghdfe leverage     *_ba                                            ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace

eststo: reghdfe leverage     *_fc                                            ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace

eststo: reghdfe leverage     *_cap                                           ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace

eststo: reghdfe leverage     *_gov                                           ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
			
esttab using "\analysis\output\tables\regressions\sub_indexes_table.tex",    ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   keep(*_ba *_fc *_cap *_gov tax_rate)                                      ///
   order(*_ba *_fc *_cap *_gov tax_rate)                                      ///
   indicate("\emph{Firm controls} = `firm_control'"                          ///
            "\emph{Country controls} = `country_control'",                   ///
			label(\checkmark ""))                                            ///
   refcat(b_sec_act_ba "\emph{Restriction on bank activities}"               ///
          b_bank_owns_fc "\emph{Financial conglomerates restrictiveness}"    ///
          b_ovr_str_cap "\emph{Capital regulation}"                          ///
		  b_ext_aud_gov "\emph{External governance}"                         ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fe_1 fe_2,                                             ///
         fmt(%9.0fc %9.0fc a3)                                               ///
         labels("Observations"  "Number of Multinationals" "\$R^2\$"         ///
          "Multinational $\times$ year fixed effects" "Industry fixed effects"))
		  

		  
//============================================================================//
//Table 6: alternative dependent variables regressions                        //
//Regressand: adjusted leverage, long- and short-term debt                    //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

foreach var of local dependent{
eststo: reghdfe `var'  `independent'                                         ///
			            tax_rate                                             ///    
                       `firm_control' `country_control',                     ///
				        absorb(multinationals#year nace2)                    ///
                        vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
}
			
esttab using "\analysis\output\tables\regressions\alt_leverage_table.tex",   ///
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
	