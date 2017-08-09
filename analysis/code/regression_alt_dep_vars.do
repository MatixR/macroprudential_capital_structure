* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the regressions presented in tables 2 and 3: alternative dependent variables
set more off
* Defining locals
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y c_ltv_cap_y";
local operation_related_ds "c_rr_local_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y int_c_ltv_cap_y";

local capital_related "c_cap_req_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_res_y";

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w"; 
local country_control "inflation gdp_growth_rate private_credit_GDP interest_rate political_risk exchange_rate_risk law_order";
#delimit cr

//===============================================================
//====== Table 2: robutness checks                         ======
//====== Regressand: alternative leverage measures         ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================

* Table 2. Effect of macroprudential policies on firm's financial leverage: alternative measures
cap erase "\analysis\output\tables\regressions\alternative_table2.tex"
cap erase "\analysis\output\tables\regressions\alternative_table2.txt"
timer on 2
sort multinational_year subsidiary_ID
* Column 1. Benchmark regression
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int' 
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int' 
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Financial, leverage) title("Effect of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 2. Adjusted leverage
#delimit;
reghdfe adj_leverage_w `operation_related'     `capital_related' 
                       `operation_related_int' `capital_related_int' 
                        tax_rate                
                       `firm_control'          `country_control'			         
					    if unbalance_panel == 2007,
				        absorb(multinational_year nace2)
                        vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int' 
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Adjusted, leverage) title("Effect of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 3. Debt leverage
#delimit;
reghdfe debt_leverage_w `operation_related'     `capital_related' 
                        `operation_related_int' `capital_related_int' 
                         tax_rate                
                        `firm_control'          `country_control'			         
					     if unbalance_panel == 2007,
				         absorb(multinational_year nace2)
                         vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int' 
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Debt, leverage) title("Effect of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 4. Long term debt
#delimit;
reghdfe longterm_debt_w `operation_related'     `capital_related' 
                        `operation_related_int' `capital_related_int' 
                         tax_rate                
                        `firm_control'          `country_control'			         
					     if unbalance_panel == 2007,
				         absorb(multinational_year nace2)
                         vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int' 
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Long-term, debt) title("Effect of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 5. Short-term debt
#delimit;
reghdfe loans_leverage_w `operation_related'     `capital_related' 
                         `operation_related_int' `capital_related_int' 
                          tax_rate                
                         `firm_control'          `country_control'			         
					      if unbalance_panel == 2007,
				          absorb(multinational_year nace2)
                          vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int' 
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Short-term, debt) title("Effect of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr
timer off 2
//===================================================================
//====== Table 3: robutness checks                             ======
//====== Regressand: alternative leverage measures             ======
//====== Fixed effects: country*year, multinational and sector ======
//===================================================================
* Table 3. Spillover of macroprudential policies on firm's financial leverage: alternative measures
cap erase "\analysis\output\tables\regressions\alternative_table3.tex"
cap erase "\analysis\output\tables\regressions\alternative_table3.txt"
sort country_year multinationals subsidiary_ID
timer on 3
* Column 1. Benchmark model
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table3.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Financial, leverage) title("Spillover of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 2. Adjusted leverage
#delimit; 
reghdfe adj_leverage_w `operation_related_ds'  `capital_related_ds' 
                        tax_rate_ds             `firm_control'         			         
					    if unbalance_panel == 2007,
				        absorb(country_year multinationals nace2)
                        vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table3.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Adjusted, leverage) title("Spillover of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 3. Debt leverage
#delimit; 
reghdfe debt_leverage_w `operation_related_ds'  `capital_related_ds' 
                         tax_rate_ds             `firm_control'         			         
					     if unbalance_panel == 2007,
				         absorb(country_year multinationals nace2)
                         vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table3.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Debt, leverage) title("Spillover of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 4. Long-term debt
#delimit; 
reghdfe longterm_debt_w `operation_related_ds'  `capital_related_ds' 
                         tax_rate_ds             `firm_control'         			         
					     if unbalance_panel == 2007,
				         absorb(country_year multinationals nace2)
                         vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table3.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Long-term, debt) title("Spillover of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr

* Column 5. Shor-term debt
#delimit; 
reghdfe loans_leverage_w `operation_related_ds'  `capital_related_ds' 
                          tax_rate_ds             `firm_control'         			         
					      if unbalance_panel == 2007,
				          absorb(country_year multinationals nace2)
                          vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table3.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Short-term, debt) title("Spillover of macroprudential policies on firm's financial leverage: alternative measures");
#delimit cr
timer off 3
