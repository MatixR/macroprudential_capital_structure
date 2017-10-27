* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file runs the benchmark regressions presented in tables 1
set more off

drop if missing(inflation, gdp_growth_rate, private_credit_GDP, political_risk, exchange_rate_risk, law_order)
* Defining locals
* Macroprudential variables
#delimit;
local dependent          "leverage";	        					  			   
local independent        "cap_req";
local independent_ds     "cap_req_ds";
local independent_tax    "tax_cap_req";
local independent_vol    "vol_cap_req";
#delimit cr
* Control variables			  
#delimit;				        					  
local firm_control "risk_w fixed_total_w log_fixedasset_w profitability_w opportunity_w";
local country_control "inflation gdp_growth_rate private_credit_GDP political_risk exchange_rate_risk law_order";
#delimit cr

//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage (indexed in 2007)    ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\robustness_merged.tex"
cap erase "\analysis\output\tables\regressions\robustness_merged.txt"


* Column 1. Multinationals and year FE -  Test debt shift theory
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' 
					 tax_rate         tax_rate_ds 
                    `firm_control' `country_control' 			         
					  ,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_merged.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Multinationals and year FE - Add theory on risk and leverage
sort  firms year
#delimit;
reghdfe `dependent' `independent' `independent_tax'
                    `independent_ds' `independent_vol' 
					 tax_rate         tax_rate_ds 
                    `firm_control' `country_control'
					  ,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_merged.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 3. Country*year, multinational FE 
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe `dependent' `independent_ds' `independent_vol' 
                     tax_rate_ds 
                     `firm_control'          			         
					  ,
				      absorb(country_year multinationals) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_merged.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", No)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 4. Country*year and multinational*year FE
#delimit; 
reghdfe `dependent' `independent_vol' 
                     `firm_control'         			         
					  ,
				      absorb(country_year multinational_year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\robustness_merged.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_tax'
        `independent_ds'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
