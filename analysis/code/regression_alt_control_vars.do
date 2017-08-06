* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the third set of robustness checks presented in tables 5 and 6: alternative controls

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
local alternative_controls_firm "opportunity_w risk_w"
local alternative_controls_country "gdp_growth_rate gdp_per_capita interest_rate market_cap_GDP exchange_rate_risk law_order"

//===============================================================
//====== Table 5: alternative firm control variables       ======
//====== Regressand: leverage                              ======
//====== Regressors: LTV, reserve and capital requirements ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================
   
* Table 5. Effect of macroprudential policies on firm's financial leverage: alternative control variables
cap erase "\analysis\output\tables\regressions\alternative_controls_table5.tex"
cap erase "\analysis\output\tables\regressions\alternative_controls_table5.txt"
timer on 5

* Column 1. Benchmark regression
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table5.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Benchmark, model) title("Effect of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 2. Alternative tangibility
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                    log_fixedasset_w profitability_w `country_control' 
					tangible_total_w 			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table5.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate tangible_total_w)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Alternative, tangibility) title("Effect of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 3. Log of sales
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate 
                    fixed_total_w profitability_w `country_control' 
					log_sales_w 			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table5.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate log_sales_w)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Log of sales) title("Effect of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 4. Aggregate profitability
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                    fixed_total_w log_fixedasset_w `country_control' 
					agg_profitability_w			         
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table5.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate agg_profitability_w)
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(Aggregate, profitability) title("Effect of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Columns 5,6. Opportunity and volatility 
foreach var of local alternative_controls_firm{
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'	
				   `var'
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table5.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate `var')
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(`: var label `var'') title("Effect of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr
}
timer off 5
					  
//===================================================================
//====== Table 6: alternative firm control variables           ======
//====== Regressand: leverage                                  ======
//====== Regressors: LTV, reserve and capital requirements     ======
//====== Fixed effects: country*year, multinational and sector ======
//===================================================================
   
* Table 6. Spillover of macroprudential policies on firm's financial leverage: alternative leverage measures

cap erase "\analysis\output\tables\regressions\alternative_controls_table6.tex"
cap erase "\analysis\output\tables\regressions\alternative_controls_table6.txt"
timer on 6

* Column 1. Benchmark regression
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
			        absorb(country_year multinationals nace2) 
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table6.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Benchmark, model) title("Spillover of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 2. Alternative tangibility
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                    log_fixedasset_w profitability_w `country_control' 
					tangible_total_w 			         
                    if unbalance_panel == 2007,
			        absorb(country_year multinationals nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table6.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds tangible_total_w)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Alternative, tangibility) title("Spillover of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 3. Log of sales
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds
                    fixed_total_w profitability_w `country_control' 
					log_sales_w 			         
                    if unbalance_panel == 2007,
			        absorb(country_year multinationals nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table6.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds log_sales_w)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Log of sales) title("Spillover of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Column 4. Aggregate profitability
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds 
                    fixed_total_w log_fixedasset_w `country_control' 
					agg_profitability_w			         
                    if unbalance_panel == 2007,
			        absorb(country_year multinationals nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table6.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds agg_profitability_w)
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(Aggregate, profitability) title("Spillover of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr

* Columns 5,6. Opportunity and volatility 
foreach var of local alternative_controls_firm{
#delimit;
reghdfe leverage_w `regressors_ds'
                    tax_rate_ds 
                   `firm_control' `country_control'	
				   `var'
                    if unbalance_panel == 2007,
			        absorb(country_year multinationals nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table6.tex", 
keep(`firm_control' `country_control' `regressors_ds' tax_rate_ds `var')
addtext("Number of firms","`Number_group'"
,"Multinational fixed effects", Yes
,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors_ds' tax_rate_ds `firm_control' `country_control')
ctitle(`: var label `var'') title("Spillover of macroprudential policies on firm's financial leverage: alternative control variables");
#delimit cr
}
timer off 6

//===============================================================
//====== Table 7: alternative country control variables    ======
//====== Regressand: leverage                              ======
//====== Regressors: LTV, reserve and capital requirements ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================
   
* Table 7. Effect of macroprudential policies on firm's financial leverage: additional country controls variables
cap erase "\analysis\output\tables\regressions\alternative_controls_table7.tex"
cap erase "\analysis\output\tables\regressions\alternative_controls_table7.txt"
timer on 7
* GDP growth, GDP per capita, interest rate, exchange rate risk, market capitalization, law and order
foreach var of local alternative_controls_country{
#delimit;
reghdfe leverage_w `regressors' `regressors_int'
                    tax_rate
                   `firm_control' `country_control'	
				   `var'
                    if unbalance_panel == 2007,
			        absorb(multinational_year nace2)  
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_controls_table7.tex", 
keep(`firm_control' `country_control' `regressors' `regressors_int' tax_rate `var')
addtext("Number of firms","`Number_group'"
,"Multinational*year fixed effects", Yes 
,"Industry fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`regressors' `regressors_int' tax_rate `firm_control' `country_control')
ctitle(`: var label `var'') title("Effect of macroprudential policies on firm's financial leverage: additional country control variables");
#delimit cr
}
timer off 7
