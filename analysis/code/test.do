* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions presented in tables 1 and 2
cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear
set more off
* Defining locals
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y c_cap_req_y c_ltv_cap_y c_sscb_res_y";
local operation_related_ds "c_rr_local_y_ds c_cap_req_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y int_c_cap_req_y int_c_ltv_cap_y";
local operation_related_opo "opo_c_rr_local_y opo_c_cap_req_y opo_c_ltv_cap_y";
local operation_related_tan "tan_c_rr_local_y tan_c_cap_req_y tan_c_ltv_cap_y";
local operation_related_vol "vol_c_rr_local_y vol_c_cap_req_y vol_c_ltv_cap_y vol_c_sscb_res_y";

local capital_related "c_cap_req_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_res_y";
local capital_related_opo "opo_c_cap_req_y opo_c_sscb_res_y";
local capital_related_tan "tan_c_cap_req_y tan_c_sscb_res_y";
local capital_related_vol "vol_c_cap_req_y vol_c_sscb_res_y";


* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w";
local firm_control_norisk "fixed_total_w log_fixedasset_w profitability_w opportunity_w"; 
local country_control "inflation gdp_growth_rate private_credit_GDP interest_rate political_risk exchange_rate_risk law_order";
#delimit cr

#delimit;
reghdfe leverage_w 
                
                  `operation_related' 
                   `firm_control' 			         
					if unbalance_panel == 2007,
				    absorb(multinational_year country_year)
                    vce(cluster multinationals);

 //=======================================
//====== Interaction term with tax ======
//=======================================

foreach var of varlist `operation_related'{
gen opo_`var'= `var'*opportunity_w
gen tan_`var'= `var'*fixed_total_w
gen vol_`var'= `var'*risk_w

 
}


bysort id id_P: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort id (id_P): gen subsidiary_multinatinal_ID = sum(help1)
bysort id: egen mover_indicator = mean(subsidiary_multinatinal_ID)


//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage                      ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\teste1.tex"
cap erase "\analysis\output\tables\regressions\teste1.txt"

* Column 1. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w `operation_related'      
                   `operation_related_int' 
                    tax_rate               
                   `firm_control'   `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster multinationals);					
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\teste1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", No
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", No)  
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     
        
     `operation_related_vol' 

        `operation_related_int'  
		 tax_rate               
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 1. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w `operation_related'     
                   
				   `operation_related_vol' 
                   `operation_related_int' 
                    tax_rate                
                   `firm_control'   `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster multinationals);					
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\teste1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", No
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", Yes
	   ,"Industry fixed effects", Yes
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", No)  
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'      
       
		`operation_related_vol' 
        `operation_related_int'  
		 tax_rate                
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 1. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w 
                
                  `operation_related_vol' 
                   `firm_control' 			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2 country_year)
                    vce(cluster multinationals);					
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\teste1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", No
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", Yes
	   ,"Industry fixed effects", No
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes)  
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     
       
                   `operation_related_vol' 
        `operation_related_int' 
		 tax_rate                 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* THE SPECIFICATION

* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y  c_ltv_cap_y";
local operation_related_ds "c_rr_local_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y  int_c_ltv_cap_y";
local operation_related_opo "opo_c_rr_local_y  opo_c_ltv_cap_y";
local operation_related_tan "tan_c_rr_local_y  tan_c_ltv_cap_y";

local capital_related "c_cap_req_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_res_y";
local capital_related_opo "opo_c_cap_req_y opo_c_sscb_res_y";
local capital_related_tan "tan_c_cap_req_y tan_c_sscb_res_y";

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w";
local firm_control_norisk "fixed_total_w log_fixedasset_w profitability_w opportunity_w"; 
local country_control "inflation gdp_growth_rate private_credit_GDP interest_rate political_risk exchange_rate_risk law_order";
#delimit cr
egen country_id_2 = group(country_id)


sort multinational_year subsidiary_ID
#delimit;
reghdfe leverage_w `operation_related'     `capital_related' 
                   `operation_related_int' `capital_related_int' 
                    tax_rate                
                   `firm_control'          `country_control'			         
					if unbalance_panel == 2007,
				    absorb(multinational_year nace2)
                    vce(cluster multinationals);
#delimit;
reghdfe leverage_w 
                   `operation_related_opo' `capital_related_opo'
                   `operation_related_tan' `capital_related_tan'    
                   `firm_control_norisk' 			         
					if unbalance_panel == 2007 & mover_indicator>1,
				    absorb(multinational_year country_year firms)
                    vce(cluster firms);					
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\teste1.tex", 
addtext("Number of firms","`Number_group'"
       ,"Firm fixed effects", Yes
	   ,"Year fixed effects", No
	   ,"Multinational*year fixed effects", Yes
	   ,"Industry fixed effects", No
       ,"Multinational fixed effects", No
       ,"Country*year fixed effects", Yes)  
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related'     `capital_related' 
        `operation_related_opo' `capital_related_opo'
                   `operation_related_tan' `capital_related_tan'
        `operation_related_int' `capital_related_int' 
		 tax_rate                tax_rate_ds 
		`firm_control'          `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


