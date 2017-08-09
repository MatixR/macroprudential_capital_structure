* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions presented in tables 4 and 5: extensions
set more off
* Defining locals
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y c_rr_foreign_y c_ltv_cap_y";
local operation_related_ds "c_rr_local_y_ds c_rr_foreign_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y int_c_rr_foreign_y int_c_ltv_cap_y";
local operation_related_ds_s "c_rr_local_y_ds_s c_rr_foreign_y_ds_s c_ltv_cap_y_ds_s";
local operation_related_ds_p "c_rr_local_y_ds_p c_rr_foreign_y_ds_p c_ltv_cap_y_ds_p";

local capital_related "c_cap_req_y c_sscb_cons_y c_sscb_oth_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_cons_y_ds c_sscb_oth_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_cons_y int_c_sscb_oth_y int_c_sscb_res_y";
local capital_related_ds_s "c_cap_req_y_ds_s c_sscb_cons_y_ds_s c_sscb_oth_y_ds_s c_sscb_res_y_ds_s";
local capital_related_ds_p "c_cap_req_y_ds_p c_sscb_cons_y_ds_p c_sscb_oth_y_ds_p c_sscb_res_y_ds_p";

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w"; 
local country_control "inflation gdp_growth_rate private_credit_GDP interest_rate political_risk exchange_rate_risk law_order";
#delimit cr

//==========================================================
//====== Table 4: extensions                          ======
//====== Regressand: leverage                         ======
//====== Fixed effects: multinational*year and sector ======
//==========================================================

* Table 4. Effect of macroprudential policies on firm's financial leverage: extensions
cap erase "\analysis\output\tables\regressions\extensions_table4.tex"
cap erase "\analysis\output\tables\regressions\extensions_table4.txt"
timer on 4
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
outreg2 using "\analysis\output\tables\regressions\extensions_table4.tex", 
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
ctitle(Benchmark, model) title("Effect of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 2. No negative profit
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int' 
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007 & profitability_w>0,
				    absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table4.tex", 
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
ctitle(No negative, profits) title("Effect of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 3. Small and medium firms
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int' 
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007 & workers>250,
				    absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table4.tex", 
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
ctitle(Small and medium, firms) title("Effect of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 4. Debt shift split in parent and other subsidiaries
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int'
				   `operation_related_ds_p' `capital_related_ds_p'
				   `operation_related_ds_s' `capital_related_ds_s'
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table4.tex", 
keep(`operation_related'     `capital_related' 
     `operation_related_int' `capital_related_int'
	 `operation_related_ds_p' `capital_related_ds_p'
	 `operation_related_ds_s' `capital_related_ds_s'
      tax_rate)
addtext("Number of firms","`Number_group'"
	   ,"Industry fixed effects", Yes
       ,"Multinational*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		 tax_rate)
ctitle(Shifting to parent, versus other countries) title("Effect of macroprudential policies on firm's financial leverage: extensions");
#delimit cr
timer off 4
//===================================================================
//====== Table 5: extensions                                   ======
//====== Regressand: leverage                                  ======
//====== Fixed effects: country*year, multinational and sector ======
//===================================================================
* Table 5. Spillover of macroprudential policies on firm's financial leverage: extensions
cap erase "\analysis\output\tables\regressions\extensions_table5.tex"
cap erase "\analysis\output\tables\regressions\extensions_table5.txt"
sort country_year multinationals subsidiary_ID
timer on 5
* Column 1. Benchmark model
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table5.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Benchmark, model) title("Spillover of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 2. No negative profit
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & profitability_w>0,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table5.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(No negative, profits) title("Spillover of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 3. Small and medium firms
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & workers>250,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table5.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Small and medium, firms) title("Spillover of macroprudential policies on firm's financial leverage: extensions");
#delimit cr

* Column 4. Debt shift split in parent and other subsidiaries
#delimit; 
reghdfe leverage_w `operation_related_ds_p' `capital_related_ds_p'
                   `operation_related_ds_s' `capital_related_ds_s' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table5.tex", 
keep(`operation_related_ds'  `capital_related_ds' tax_rate_ds
     `operation_related_ds_p' `capital_related_ds_p'
	 `operation_related_ds_s' `capital_related_ds_s')
addtext("Number of firms","`Number_group'"
       ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related_ds'  `capital_related_ds' tax_rate_ds)
ctitle(Shifting to parent, versus other countries) title("Spillover of macroprudential policies on firm's financial leverage: extensions");
#delimit cr
timer off 5
