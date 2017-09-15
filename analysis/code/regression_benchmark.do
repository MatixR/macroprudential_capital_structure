* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions presented in tables 1 and 2
set more off
* Defining locals
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y";
local operation_related_ds "c_rr_local_y_ds";
local operation_related_int "int_c_rr_local_y";
local operation_related_vol "vol_c_rr_local_y";

local capital_related "c_cap_req_y";
local capital_related_ds "c_cap_req_y_ds";
local capital_related_int "int_c_cap_req_y";
local capital_related_vol "vol_c_cap_req_y";

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

* Column 1. Multinationals and year FE
sort  firms year
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int'
                   `operation_related_ds'  `capital_related_ds' 
                    tax_rate                tax_rate_ds
                   `firm_control'   `country_control'			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(multinationals year) 
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'
		`operation_related_vol' `capital_related_vol'
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Country*year, multinational FE
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe leverage_w `operation_related_ds'  `capital_related_ds' 
		           `operation_related_vol' `capital_related_vol'
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinationals)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", No)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'  
	    `operation_related_vol' `capital_related_vol'
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 3. Country*year and multinational*year FE
#delimit; 
reghdfe leverage_w `operation_related_vol' `capital_related_vol'
                   `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinational_year)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related'     `capital_related' 
        `operation_related_int' `capital_related_int' 
		`operation_related_ds'  `capital_related_ds'  
	    `operation_related_vol' `capital_related_vol'
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
