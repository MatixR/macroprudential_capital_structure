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
//Table 1: benchmark regressions                                              //
//Regressand: leverage                                                        //
//Fixed effects: multinational*year and industry                              //
//============================================================================//
eststo clear

foreach var of local independent{
eststo: reghdfe leverage    `var'                                            ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
							 keepsingletons                                  ///							 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
}
eststo: reghdfe leverage    `independent'                                    ///
			                 tax_rate                                        ///    
                            `firm_control' `country_control',                ///
				             absorb(multinationals#year nace2)               ///
							 keepsingletons                                  ///							 
                             vce(cluster multinationals)                 
estadd local fe_1 "\checkmark" , replace
estadd local fe_2 "\checkmark" , replace
estadd local fe_3 "\checkmark" , replace
			
esttab using "\analysis\output\tables\regressions\benchmark_table.tex",      ///
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
		  

