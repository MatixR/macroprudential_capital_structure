* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the regressions presented in tables 2 and 3: alternative dependent variables
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

//===============================================================
//====== Table 2: robutness checks                         ======
//====== Regressand: alternative leverage measures         ======
//====== Fixed effects: multinational*year and sector      ======
//===============================================================

* Table 2. Effect of macroprudential policies on firm's financial leverage: alternative measures
cap erase "\analysis\output\tables\regressions\alternative_table2.tex"
cap erase "\analysis\output\tables\regressions\alternative_table2.txt"
timer on 2

* Column 1. Adjusted leverage
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe adj_leverage_w `operation_related_ds'  `capital_related_ds' 
		           `operation_related_vol' `capital_related_vol'
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinationals)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related_ds'     `capital_related_ds' 
        `operation_related_vol' `capital_related_vol' 
		 tax_rate)
ctitle(Adjusted, leverage) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Long term debt
#delimit; 
reghdfe longterm_debt_w `operation_related_ds'  `capital_related_ds' 
		           `operation_related_vol' `capital_related_vol'
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinationals)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related_ds'     `capital_related_ds' 
        `operation_related_vol' `capital_related_vol' 
		 tax_rate)
ctitle(Long-term, debt) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 3. Short-term debt

#delimit; 
reghdfe loans_leverage_w `operation_related_ds'  `capital_related_ds' 
		           `operation_related_vol' `capital_related_vol'
                    tax_rate_ds             `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinationals)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\alternative_table2.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`operation_related_ds'     `capital_related_ds' 
        `operation_related_vol' `capital_related_vol' 
		 tax_rate)
ctitle(Short-term, debt) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
