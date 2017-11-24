//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
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
drop if missing(inflation, gdp_growth_rate, private_credit_GDP, political_risk, exchange_rate_risk, law_order)

//============================================================================//
//Table 1: benchmark regressions                                              //
//Regressand: leverage                                                        //
//============================================================================//

foreach var of local independent{
eststo: reghdfe `dependent' `var' `var'_ds                                   ///
			                 tax_rate    tax_rate_ds                         ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals year) keepsingletons      ///
                             vce(cluster multinationals)                 
estadd local fixed "Yes" , replace
}
eststo: reghdfe `dependent' `independent' `independent_ds'                   ///
			                 tax_rate    tax_rate_ds                         ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals year) keepsingletons      ///
                             vce(cluster multinationals)                 
estadd local fixed "Yes" , replace
			
esttab using "\analysis\output\tables\regressions\benchmark_table.tex",      ///
   replace se(3) b(3) label  booktabs  fragment notes                        /// 
   mlabels(none) collabels(none)  nomtitles nonumbers                        ///                                        
   order(`independent' `independent_ds')                                     ///
   refcat(b_ovr_rest "\emph{Bank regulation - direct}"                       ///
          b_ovr_rest_ds "\emph{Bank regulation - spillover}"                 ///
          tax_rate "\emph{Corporate tax}"                                    ///
	      risk_w "\emph{Firm characteristics}"                               ///
          inflation "\emph{Macroeconomic controls}", nolabel)		         ///
   stats(N N_clust r2 fixed, fmt(%9.0fc %9.0fc a2)                           ///
   labels("Observations"  "Number of Multinationals" "\$R^2\$"               ///
          "Multinational*year fixed effects"))                               ///                        
