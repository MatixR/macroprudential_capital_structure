* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file runs the robustness checks presented in tables 2
set more off

drop if missing(inflation, gdp_growth_rate, private_credit_GDP_i, political_risk_i, exchange_rate_risk_i, law_order_i)
* Defining locals
* Macroprudential variables
#delimit;
local dependent          "leverage_i_w";	        					  			   
local independent        "c_cap_req_y c_rr_local_y";
local independent_ds     "c_cap_req_y_ds c_rr_local_y_ds";
local independent_tax    "tax_c_cap_req_y tax_c_rr_local_y";
local independent_vol    "vol_c_cap_req_y vol_c_rr_local_y";
local independent_taxvol "taxvol_c_rr_local_y taxvol_c_cap_req_y";
#delimit cr
* Control variables			  
#delimit;				        					  
local firm_control "risk_w fixed_total_i_w log_fixedasset_i_w profitability_i_w opportunity_w ";
local country_control "inflation gdp_growth_rate private_credit_GDP_i political_risk_i exchange_rate_risk_i law_order_i";
#delimit cr

//=======================================================
//====== Table 2: Robustness  regressions          ======
//====== Regressand: leverage (indexed in 2007)    ======
//====== Check: industry fixed-effects             ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\robustness_table2.tex"
cap erase "\analysis\output\tables\regressions\robustness_table2.txt"


* Column 1. Multinationals and year FE -  Test debt shift theory
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' 
					 tax_rate_i         tax_rate_i_ds 
                    `firm_control' `country_control' 			         
					  if unbalance_panel == 2007 & multinational ==1 & year != 2007,
				      absorb(multinationals nace2 year) keepsingletons
                      vce(cluster nace2#countries);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table2.tex", 
addtext("Industry*country clusters","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i         tax_rate_i_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Multinationals and year FE - Add theory on risk and leverage
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' `independent_vol' 
					 tax_rate_i         tax_rate_i_ds 
                    `firm_control' `country_control'
					  if unbalance_panel == 2007 & multinational ==1 & year != 2007,
				      absorb(multinationals nace2 year) keepsingletons
                      vce(cluster nace2#countries);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table2.tex", 
addtext("Industry*country clusters","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i         tax_rate_i_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 3. Country*year, multinational FE 
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe `dependent' `independent_ds' `independent_vol' 
                     tax_rate_i_ds 
                     `firm_control'          			         
					  if unbalance_panel == 2007 & multinational ==1 & year != 2007,
				      absorb(country_year nace2 multinationals) keepsingletons
                      vce(cluster nace2#countries);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table2.tex", 
addtext("Industry*country clusters","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", No)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i         tax_rate_i_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 4. Country*year and multinational*year FE
#delimit; 
reghdfe `dependent' `independent_vol' 
                     `firm_control'         			         
					  if unbalance_panel == 2007 & multinational ==1 & year != 2007,
				      absorb(country_year nace2 multinational_year) keepsingletons
                      vce(cluster nace2#countries);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_table2.tex", 
addtext("Industry*country clusters","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
	   ,"Industry fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate_i         tax_rate_i_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


