* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the third set of robustness checks presented in tables 5 and 6: alternative controls

* Defining locals
* Macroprudential variables				        					  			   
local regressors "c_cap_req_y c_ltv_cap_y c_rr_local_y"
local regressors_ds "c_cap_req_y_ds c_ltv_cap_y_ds c_rr_local_y_ds"
local regressors_int "int_c_cap_req_y int_c_ltv_cap_y int_c_rr_local_y"
local regressors_ds_p "c_cap_req_y_ds_p c_ltv_cap_y_ds_p c_rr_local_y_ds_p"
local regressors_ds_s "c_cap_req_y_ds_s c_ltv_cap_y_ds_s c_rr_local_y_ds_s"
* Dependent variables
local alternative_dependent "leverage_w adj_leverage_w debt_leverage_w longterm_debt_w loans_leverage_w"			        				  
* Control variables			  
local firm_control "fixed_total_w log_fixedasset_w profitability_w"
local country_control "inflation  political_risk private_credit_GDP"

//===============================================================
//====== Table 8: alternative samples and models           ======
//====== Regressand: leverage                              ======
//====== Regressors: LTV, reserve and capital requirements ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================
   
* Table 8. Effect of macroprudential policies on firm's financial leverage: robustness checks
cap erase "\analysis\output\tables\regressions\robustness_checks_table8.tex"
cap erase "\analysis\output\tables\regressions\robustness_checks_table8.txt"
timer on 8

* Column 1. Benchmark regression
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table8.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Benchmark, model) title("Effect of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 2. No negative profitability
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007 & profitability_w>0,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table8.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(No negative, profits) title("Effect of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 3. Small and medium firms by workers
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007 & workers>250,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table8.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Small and medium, firms) title("Effect of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 4. Balance panel
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'			         
                    if balance_panel == 8,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table8.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Balanced, panel) title("Effect of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 5. Debt shift split in parent and other subsidiaries
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                   `regressors_ds_p' `regressors_ds_s'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table8.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate `regressors_ds_p' `regressors_ds_s')
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Shifting to parent, versus other countries) title("Effect of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr
timer off 8
//===================================================================
//====== Table 9: alternative samples and models               ======
//====== Regressand: leverage                                  ======
//====== Regressors: LTV, reserve and capital requirements     ======
//====== Fixed effects: country*year, multinational and sector ======
//===================================================================
   
* Table 9. Spillover of macroprudential policies on firm's financial leverage: robustness checks
cap erase "\analysis\output\tables\regressions\robustness_checks_table9.tex"
cap erase "\analysis\output\tables\regressions\robustness_checks_table9.txt"
timer on 9

* Column 1. Benchmark regression
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table9.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Benchmark, model) title("Spillover of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 2. No negative profitability
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007 & profitability_w>0,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table9.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(No negative, profits) title("Spillover of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 3. Small and medium firms by workers
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007 & workers>250,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table9.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Small and medium, firms) title("Spillover of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 4. Balance panel
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                   `firm_control' `country_control'			         
                    if balance_panel == 8,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table9.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Balanced, panel) title("Spillover of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr

* Column 5. Debt shift split in parent and other subsidiaries
#delimit;
reghdfe leverage_w `regressors_ds_p' `regressors_ds_s'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_checks_table9.tex", 
keep(`firm_control' `country_control' `regressors_ds_p' `regressors_ds_s' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Shifting to parent, versus other countries) title("Spillover of macroprudential policies on firm's financial leverage: robustness checks");
#delimit cr
timer off 9
