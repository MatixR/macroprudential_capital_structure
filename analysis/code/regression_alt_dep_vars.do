* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the first set of robustness checks presented in tables 3 and 4: alternative dependent variables

* Defining locals
* Macroprudential variables				        					  			   
local regressors "c_cap_req_y c_ltv_cap_y c_rr_local_y"
local regressors_ds "c_cap_req_y_ds c_ltv_cap_y_ds c_rr_local_y_ds"
local regressors_int "int_c_cap_req_y int_c_ltv_cap_y int_c_rr_local_y"
* Dependent variables
local alternative_dependent "leverage_w adj_leverage_w debt_leverage_w longterm_debt_w loans_leverage_w"			        				  
* Control variables			  
local firm_control "fixed_total_w log_fixedasset_w profitability_w"
local country_control "inflation  political_risk private_credit_GDP"

//===============================================================
//====== Table 3: robutness checks                         ======
//====== Regressand: alternative leverage measures         ======
//====== Regressors: LTV, reserve and capital requirements ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================

* Table 3. Effect of macroprudential policies on firm's financial leverage: alternative measures
cap erase "\analysis\output\tables\regressions\alternative_leverage_table3.tex"
cap erase "\analysis\output\tables\regressions\alternative_leverage_table3.txt"
timer on 3
foreach var of local alternative_dependent{
#delimit;
reghdfe `var' `regressors' `regressors_int'
               tax_rate
              `firm_control' `country_control'			         
               if unbalance_panel == 2007,
			   absorb(multinational_year nace2)  
               vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_leverage_table3.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
title("Effect of macroprudential policies on firm's financial leverage: alternative leverage measures");
#delimit cr
}
timer off 3

//===================================================================
//====== Table 4: robutness checks                             ======
//====== Regressand: alternative leverage measures             ======
//====== Regressors: LTV, reserve and capital requirements     ======
//====== Fixed effects: country*year, multinational and sector ======
//===================================================================

* Table 4. Spillover of macroprudential policies on firm's financial leverage: alternative measures
cap erase "\analysis\output\tables\regressions\alternative_leverage_table4.tex"
cap erase "\analysis\output\tables\regressions\alternative_leverage_table4.txt"
timer on 4
foreach var of local alternative_dependent{
#delimit;
reghdfe `var' `regressors_ds'
               tax_rate_ds 
              `firm_control' `country_control'			         
               if unbalance_panel == 2007,
			   absorb(country_year multinationals nace2)  
               vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_leverage_table4.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
title("Spillover of macroprudential policies on firm's financial leverage: alternative leverage measures");
#delimit cr
}
timer off 4
