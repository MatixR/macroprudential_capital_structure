* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions presented in tables 4 and 5: extensions
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

//==========================================================
//====== Table 4: extensions                          ======
//====== Regressand: leverage                         ======
//====== Fixed effects: multinational*year and sector ======
//==========================================================

* Table 3. Effect of macroprudential policies on firm's financial leverage: extensions
cap erase "\analysis\output\tables\regressions\extensions_table3.tex"
cap erase "\analysis\output\tables\regressions\extensions_table3.txt"
timer on 4
sort country_year multinationals subsidiary_ID

* Column 3. split debt shift

#delimit; 
reghdfe leverage_w  c_rr_local_y_ds_p c_rr_local_y_ds_s
                       c_cap_req_y_ds_p c_cap_req_y_ds_s
					   tax_rate_ds_p tax_rate_ds_s
		           `operation_related_vol' `capital_related_vol'
                                 `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinational_year)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table3.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar( lag_leverage
        `operation_related_vol' `capital_related_vol' 
		c_rr_local_y_ds_p c_rr_local_y_ds_s
                       c_cap_req_y_ds_p c_cap_req_y_ds_s
		 tax_rate_ds_p tax_rate_ds_s)
ctitle(Shifting to, parent versus, other firms) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 3. sector

#delimit; 
reghdfe leverage_w 
		           `operation_related_vol' `capital_related_vol'
                                 `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinational_year nace2)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table3.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar( lag_leverage
        `operation_related_vol' `capital_related_vol' 
		c_rr_local_y_ds_p c_rr_local_y_ds_s
                       c_cap_req_y_ds_p c_cap_req_y_ds_s
		 tax_rate_ds)
ctitle(Sector, fixed, effects) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

order firms
xtset firms year

bysort firms (year): gen lag_leverage = leverage_w[_n-1] if year == year[_n-1]+1

#delimit; 
reghdfe leverage_w  lag_leverage
		           `operation_related_vol' `capital_related_vol'
                                 `firm_control'         			         
					if unbalance_panel == 2007 & multinational ==1,
				    absorb(country_year multinational_year nace2)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\extensions_table3.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar( lag_leverage
        `operation_related_vol' `capital_related_vol' 
		c_rr_local_y_ds_p c_rr_local_y_ds_s
                       c_cap_req_y_ds_p c_cap_req_y_ds_s
		 tax_rate_ds)
ctitle(Sector, fixed, effects) title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
