* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs the benchmark regressions presented in tables 1 and 2

* Defining locals
#delimit cr
* Macroprudential variables
#delimit;				        					  			   
local operation_related "c_rr_local_y c_rr_foreign_y c_ltv_cap_y";
local operation_related_ds "c_rr_local_y_ds c_rr_foreign_y_ds c_ltv_cap_y_ds";
local operation_related_int "int_c_rr_local_y int_c_rr_foreign_y int_c_ltv_cap_y";

local capital_related "c_cap_req_y c_sscb_cons_y c_sscb_oth_y c_sscb_res_y";
local capital_related_ds "c_cap_req_y_ds c_sscb_cons_y_ds c_sscb_oth_y_ds c_sscb_res_y_ds";
local capital_related_int "int_c_cap_req_y int_c_sscb_cons_y int_c_sscb_oth_y int_c_sscb_res_y";

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w"; 
local country_control "inflation  political_risk private_credit_GDP";
#delimit cr

//=======================================================
//====== Table 1: benchmark regressions            ======
//====== Regressand: leverage                      ======
//====== Regressors: reserve requirements and LTV  ======
//=======================================================

* Table 1. Effect of macroprudential policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\leverage_table1.tex"
cap erase "\analysis\output\tables\regressions\leverage_table1.txt"
timer on 1

* Column 1. Firm and year FE - no spillover or interaction
sort  firms year
#delimit;
reghdfe leverage_w `operation_related'
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
					if unbalance_panel == 2007,
				    absorb(firms year) 
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `operation_related' tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", Yes,"Year fixed effects", Yes
,"Multinational fixed effects", No, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", No) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related' `operation_related_ds' `operation_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 2. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w `operation_related' `operation_related_ds' `operation_related_int'
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
					if unbalance_panel == 2007,
				    absorb(firms year) 
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `operation_related' `operation_related_ds' `operation_related_int'  tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", Yes,"Year fixed effects", Yes
,"Multinational fixed effects", No, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", No) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related' `operation_related_ds' `operation_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 3. Multinationals, country, year and sector FE
sort  multinationals subsidiary_ID year 
#delimit;
reghdfe leverage_w `operation_related' `operation_related_ds' `operation_related_int'
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
					if unbalance_panel == 2007,
					absorb(multinationals year nace2 ifscode)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `operation_related' `operation_related_ds' `operation_related_int'  tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", Yes
,"Multinational fixed effects", Yes, "Multinational*year fixed effects", No
,"Country fixed effects", Yes,"Country*year fixed effects", No 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related' `operation_related_ds' `operation_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr

* Column 4. Multinationals*year and sector FE
sort multinational_year subsidiary_ID
#delimit;
reghdfe leverage_w `operation_related' `operation_related_int' 
                    tax_rate
                   `firm_control' `country_control'			         
					if unbalance_panel == 2007,
					absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `operation_related' `operation_related_int'  tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", No
,"Multinational fixed effects", No, "Multinational*year fixed effects", Yes
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related' `operation_related_ds' `operation_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr


* Column 5. Country*year, multinational and sector FE
sort country_year multinationals subsidiary_ID
#delimit;
reghdfe leverage_w `operation_related_ds'
                    tax_rate_ds
                   `firm_control' 			         
					if unbalance_panel == 2007,
					absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `operation_related_ds' tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", No
,"Multinational fixed effects", Yes, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`operation_related' `operation_related_ds' `operation_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of macroprudential policies on firm's financial leverage");
#delimit cr
timer off 1
//==========================================================
//====== Table 2: benchmark regressions               ======
//====== Regressand: leverage                         ======
//====== Regressors: capital requirements and buffers ======
//==========================================================

* Table 2. Effect of bank capital related policies on firm's financial leverage

cap erase "\analysis\output\tables\regressions\leverage_table2.tex"
cap erase "\analysis\output\tables\regressions\leverage_table2.txt"
timer on 2

* Column 1. Firm and year FE - no spillover or interaction
sort  firms year
#delimit;
reghdfe leverage_w `capital_related' 
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
					absorb(firms year)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `capital_related' tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", Yes,"Year fixed effects", Yes
,"Multinational fixed effects", No, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", No) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`capital_related' `capital_related_ds' `capital_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of bank capital related policies on firm's financial leverage");
#delimit cr


* Column 2. Firm and year FE
sort  firms year
#delimit;
reghdfe leverage_w `capital_related' `capital_related_ds' `capital_related_int'
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
                    if unbalance_panel == 2007,
					absorb(firms year)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `capital_related' `capital_related_ds' `capital_related_int'  tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", Yes,"Year fixed effects", Yes
,"Multinational fixed effects", No, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", No) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`capital_related' `capital_related_ds' `capital_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of bank capital related policies on firm's financial leverage");
#delimit cr

* Column 3. Multinationals, country, year and sector FE
sort  multinationals subsidiary_ID year
#delimit;
reghdfe leverage_w `capital_related' `capital_related_ds' `capital_related_int'
                    tax_rate tax_rate_ds
                   `firm_control' `country_control'			         
   					if unbalance_panel == 2007,
					absorb(multinationals year nace2 ifscode)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `capital_related' `capital_related_ds' `capital_related_int'  tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", Yes
,"Multinational fixed effects", Yes, "Multinational*year fixed effects", No
,"Country fixed effects", Yes,"Country*year fixed effects", No 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`capital_related' `capital_related_ds' `capital_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of bank capital related policies on firm's financial leverage");
#delimit cr

* Column 4. Multinationals*year and sector FE
sort multinational_year subsidiary_ID
#delimit;
reghdfe leverage_w `capital_related' `capital_related_int'
                    tax_rate
                   `firm_control' `country_control'			          
				    if unbalance_panel == 2007,
					absorb(multinational_year nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `capital_related' `capital_related_int' tax_rate tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", No
,"Multinational fixed effects", No, "Multinational*year fixed effects", Yes
,"Country fixed effects", No,"Country*year fixed effects", No 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`capital_related' `capital_related_ds' `capital_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of bank capital related policies on firm's financial leverage");
#delimit cr

* Column 5. Country*year, multinational and sector FE
sort country_year multinationals subsidiary_ID
#delimit;
reghdfe leverage_w `capital_related_ds'
                    tax_rate_ds
                   `firm_control' 			         
					if unbalance_panel == 2007,
					absorb(country_year multinationals nace2)
                    vce(cluster firms);
local Number_group: di %15.0fc `e(N_clust)';
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `capital_related_ds' tax_rate_ds)
addtext("Number of firms","`Number_group'"
,"Firm fixed effects", No,"Year fixed effects", No
,"Multinational fixed effects", Yes, "Multinational*year fixed effects", No
,"Country fixed effects", No,"Country*year fixed effects", Yes 
,"Industry fixed effects", Yes) 
addstat("R-squared", e(r2))
label tex(frag) nocons bdec(3) sdec(3) noni nor2 adec(2)
sortvar(`capital_related' `capital_related_ds' `capital_related_int' tax_rate tax_rate_ds `firm_control' `country_control')
ctitle(" ") title("Effect of bank capital related policies on firm's financial leverage");
#delimit cr
timer off 2
timer list
