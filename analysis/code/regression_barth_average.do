* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions for Barth et al. 2008 dataset presented in table 4
set more off
* Defining locals
* Macroprudential variable

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_a_w log_fixedasset_a_w profitability_a_w opportunity_a_w risk_w";
local country_control "inflation_a gdp_growth_rate_a private_credit_GDP_a interest_rate_a 
                       political_risk_a exchange_rate_risk_a law_order_a";
#delimit cr

//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage                      ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\barth_table4.tex"
cap erase "\analysis\output\tables\regressions\barth_table4.txt"


* Column 1. Multinationals and year FE
sort  firms year
#delimit;
reghdfe leverage_a  cap_str tax_cap_str cap_str_ds_a  
                    tax_rate_a       tax_rate_a_ds_a
                   `firm_control'   `country_control'			         
					if year == 2011 & multinational ==1,
				    absorb(multinationals year) 
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\barth_table4.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", No
	   ,"Multinational*year fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(cap_str     tax_cap_str
        vol_cap_str cap_str_ds_a  
        tax_rate_a  tax_rate_a_ds_a
       `firm_control'   `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Country*year, multinational FE
sort country_year multinationals subsidiary_ID
#delimit; 
reghdfe leverage_a  cap_str_ds_a     vol_cap_str
                    tax_rate_a_ds_a `firm_control' 			         
					if year == 2011 & multinational ==1,
				    absorb(country_year multinationals)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\barth_table4.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", Yes
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", No)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(cap_str     tax_cap_str
        vol_cap_str cap_str_ds_a  
        tax_rate_a  tax_rate_a_ds_a
       `firm_control'   `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 3. Country*year and multinational*year FE
#delimit; 
reghdfe leverage_a    vol_cap_str
                     `firm_control' 			         
					if year == 2011 & multinational ==1,
				    absorb(country_year multinational_year)
                    vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\barth_table4.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes
	   ,"Multinational*year fixed effects", Yes)
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(cap_str     tax_cap_str
        vol_cap_str cap_str_ds_a  
        tax_rate_a  tax_rate_a_ds_a
       `firm_control'   `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
