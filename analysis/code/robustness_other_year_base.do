* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file runs the robustness check with different year base presented in tables 3
set more off
drop if missing(inflation_i2, gdp_growth_rate_i2, private_credit_GDP_i2, political_risk_i2, exchange_rate_risk_i2, law_order_i2)

* Defining locals
* Macroprudential variables
#delimit;
local dependent          "leverage_i2_w";	        					  			   
local independent        "c_cap_req_y_i2 c_rr_local_y_i2";
local independent_ds     "c_cap_req_y_i2_ds c_rr_local_y_i2_ds";
local independent_tax    "tax_c_cap_req_y_i2 tax_c_rr_local_y_i2";
local independent_vol    "vol_c_cap_req_y_i2 vol_c_rr_local_y_i2";
local independent_taxvol "taxvol_c_rr_local_y taxvol_c_cap_req_y";
#delimit cr
* Control variables			  
#delimit;				        					  
local firm_control "risk_w fixed_total_i2_w log_fixedasset_i2_w profitability_i2_w opportunity_w";
local country_control "inflation_i2 gdp_growth_rate_i2 private_credit_GDP_i2 political_risk_i2 exchange_rate_risk_i2 law_order_i2";
#delimit cr

//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage (indexed in 2008)    ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\robustness_table3_yearbase.tex"
cap erase "\analysis\output\tables\regressions\robustness_table3_yearbase.txt"


* Column 1. Multinationals and year FE -  Test debt shift theory
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' 
					 tax_rate_i2         tax_rate_i2_ds 
                    `firm_control' `country_control' 			         
					  if  multinational ==1 & year != 2008,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table3_yearbase.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i2         tax_rate_i2_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Multinationals and year FE - Add theory on risk and leverage
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' `independent_vol' 
					 tax_rate_i2         tax_rate_i2_ds 
                    `firm_control' `country_control'
					  if  multinational ==1 & year != 2008,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table3_yearbase.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i2         tax_rate_i2_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 3. Country*year, multinational FE 
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe `dependent' `independent_ds' `independent_vol' 
                     tax_rate_i2_ds 
                     `firm_control'          			         
					  if  multinational ==1 & year != 2008,
				      absorb(country_year multinationals) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table3_yearbase.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", No)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i2         tax_rate_i2_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 4. Country*year and multinational*year FE
#delimit; 
reghdfe `dependent' `independent_vol' 
                     `firm_control'         			         
					  if  multinational ==1 & year != 2008,
				      absorb(country_year multinational_year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table3_yearbase.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i2         tax_rate_i2_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
