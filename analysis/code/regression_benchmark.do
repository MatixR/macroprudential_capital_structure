* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions presented in tables 1 and 2

* Defining locals
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y  c_ltv_cap_y";
local operation_related_ds "c_rr_local_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y  int_c_ltv_cap_y";

local capital_related "c_cap_req_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_res_y";

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w";
local firm_control_norisk "fixed_total_w log_fixedasset_w profitability_w opportunity_w"; 
local country_control "inflation gdp_growth_rate private_credit_GDP interest_rate political_risk exchange_rate_risk law_order";
#delimit cr

//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage                      ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\benchmark_table1.tex"
cap erase "\analysis\output\tables\regressions\benchmark_table1.txt"
timer on 1

* Column 1. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int'
                   `operation_related_ds'  `capital_related_ds' 
                    tax_rate                tax_rate_ds
                   `firm_control_norisk'   `country_control'			         
					if unbalance_panel == 2007,
				    absorb(firms year) 
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", Yes
	   ,"Year fixed effects", Yes
	   ,"Multinational*year fixed effects", No
	   ,"Industry fixed effects", No
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", No)  
addstat("R-squared", e(r2)) drop(risk_w)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'  
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Multinationals*year and sector FE
sort multinational_year subsidiary_ID
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int' 
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", No
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", No)
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'  
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 3. Country*year, multinational and sector FE
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007,
				    absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", No
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", No
	   ,"Industry fixed effects", Yes
       ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'  
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
