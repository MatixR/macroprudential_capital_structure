* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions for Barth et al. 2008 dataset presented in table 4
set more off

drop if missing(inflation, gdp_growth_rate, private_credit_GDP, political_risk, exchange_rate_risk, law_order)
* Defining locals
* Macroprudential variables
#delimit;
local dependent       "leverage";	        					  			   
local independent     "b_ovr_rest  
                       b_lim_for b_frac_den  
					   b_int_str b_off_sup";
local independent_ds  "b_ovr_rest_ds  
                       b_lim_for_ds b_frac_den_ds 
					   b_int_str_ds b_off_sup_ds ";
local independent_tax "tax_b_ovr_rest 
                       tax_b_lim_for tax_b_frac_den 
					   tax_b_int_str tax_b_off_sup";
local independent_vol    "";
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

cap erase "\analysis\output\tables\regressions\benchmark_table1_barth.tex"
cap erase "\analysis\output\tables\regressions\benchmark_table1_barth.txt"


* Column 1. Multinationals and year FE -  Test debt shift theory
sort  firms year
#delimit;
reghdfe `dependent' `independent'  `independent_ds' 
					 tax_rate         tax_rate_ds 
                    `firm_control' `country_control' 			         
					 ,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1_barth.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
	   ,"Multinational*year fixed effects", No
	   ,"Industry fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_ds'
        `independent_tax'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 1. Multinationals and year FE -  Test debt shift theory
sort  firms year
#delimit;
reghdfe `dependent' `independent'  `independent_ds' `independent_tax' 
					 tax_rate         tax_rate_ds 
                    `firm_control' `country_control' 			         
					 ,
				      absorb(multinationals year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1_barth.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", Yes
	   ,"Multinational fixed effects", Yes
	   ,"Multinational*year fixed effects", No
	   ,"Industry fixed effects", No) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_ds'
        `independent_tax'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 2. Country and multinational*year FE
#delimit; 
reghdfe `dependent' `independent'    
					 tax_rate          
                    `firm_control' `country_control'
					  ,
				      absorb(multinational_year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1_barth.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
	   ,"Multinational*year fixed effects", Yes) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_ds'
        `independent_tax'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Country and multinational*year FE
#delimit; 
reghdfe `dependent' `independent' 
                    `independent_tax'  
					 tax_rate        
                    `firm_control' `country_control'
					  ,
				      absorb(multinational_year) keepsingletons
                      vce(cluster multinationals);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\benchmark_table1_barth.tex", 
addtext("Number of multinationals","`Number_group'"
	   ,"Year fixed effects", No
	   ,"Multinational fixed effects", No
	   ,"Multinational*year fixed effects", Yes) 
label tex(frag) nocons bdec(3) sdec(3) noni nor2 
sortvar(`independent'     `independent_ds'
        `independent_tax'  `independent_vol' 
		 tax_rate         tax_rate_ds 
		`firm_control'     `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
