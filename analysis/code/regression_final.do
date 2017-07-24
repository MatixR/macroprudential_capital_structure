* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions
cd "S:"
use "\cleaning\output\dataset_orbis.dta", clear
set more off 

timer clear

* Defining locals
* Macroprudential variables
#delimit;					   
local operation_related "cum_rr_local_y cum_rr_foreign_y cum_ltv_cap_y cum_concrat_y cum_ibex_y";

local capital_related "cum_cap_req_y cum_sscb_y cum_sscb_cons_y cum_sscb_oth_y cum_sscb_res_y"; 				   				   
#delimit cr

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w"; 
local country_control "inflation  political_risk private_credit_GDP";					  
#delimit cr
					  
//=================================================
//====== Dataset: all firms                  ======
//====== Regressand: leverage                ======
//====== Regressors: all cumulative indexes  ======
//====== Fixed effects: subsidiary and time  ======
//=================================================
 
sort  firm_id subsidiary_ID
xtset firm_id year

* Table 1. Macroprudential policy effect on firm's financial leverage
cap erase "\analysis\output\tables\regressions\leverage_table1.tex"
timer on 1
foreach a of local operation_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster firm_id);
predict `a'_ol, xb;
outreg2 using "\analysis\output\tables\regressions\leverage_table1.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage");
#delimit cr
}
timer off 1

* Table 2. Macroprudential policy effect on firm's financial leverage (capital related variables)
cap erase "\analysis\output\tables\regressions\leverage_table2.tex"
timer on 2
foreach a of local capital_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster firm_id);
predict `a'_ol, xb;
outreg2 using "\analysis\output\tables\regressions\leverage_table2.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage (capital related indexes)");
#delimit cr
}
timer off 2

//==================================================
//====== Dataset: all firms                   ======
//====== Regressand: leverage                 ======
//====== Regressors: by parent and subsidiary ======
//====== Fixed effects: subsidiary and time   ======
//==================================================

* Table 3. Macroprudential policy effect on firm's financial leverage: spillover from parent and others subsidiaries
cap erase "\analysis\output\tables\regressions\leverage_table3.tex"
timer on 3
foreach a of local operation_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				  tax_rate tax_rate_ds_p tax_rate_ds_s
			        `a'       `a'_ds_p `a'_ds_s  
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\leverage_table3.tex", 
keep(`firm_control' `country_control' `a' `a'_ds_p `a'_ds_s tax_rate tax_rate_ds_p tax_rate_ds_s)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage: spillover from parent and others subsidiaries");
#delimit cr
}
timer off 3

* Table 4. Macroprudential policy effect on firm's financial leverage (capital related variables): spillover from parent and others subsidiaries
cap erase "\analysis\output\tables\regressions\leverage_table4.tex"
timer on 4
foreach a of local capital_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds_p tax_rate_ds_s
			        `a'       `a'_ds_p `a'_ds_s   
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\leverage_table4.tex", 
keep(`firm_control' `country_control' `a' `a'_ds_p `a'_ds_s tax_rate tax_rate_ds_p tax_rate_ds_s)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage (capital related indexes): spillover from parent and others subsidiaries");
#delimit cr
}
timer off 4

//================================================
//====== Dataset: all firms                 ======
//====== Regressand: Long-term debt         ======
//====== Regressors: all cumulative indexes ======
//====== Fixed effects: subsidiary and time ======
//================================================

* Table 5. Macroprudential policy effect on firm's long-term debt
cap erase "\analysis\output\tables\regressions\longterm_table5.tex"
timer on 5
foreach a of local operation_related{
#delimit;
xi: xtreg longterm_debt `firm_control' `country_control'
				          tax_rate tax_rate_ds
			              `a'       `a'_ds 
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\longterm_table5.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's long-term debt");
#delimit cr
}
timer off 5

* Table 6. Macroprudential policy effect on firm's long-term debt (capital related indexes)
cap erase "\analysis\output\tables\regressions\longterm_table6.tex"
timer on 6
foreach a of local capital_related{
#delimit;
xi: xtreg longterm_debt `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\longterm_table6.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's long-term debt (capital related indexes)");
#delimit cr
}
timer off 6

//================================================
//====== Dataset: all firms                 ======
//====== Regressand: Long-term debt         ======
//====== Regressors: all cumulative indexes ======
//====== Fixed effects: subsidiary and time ======
//================================================

* Table 7. Macroprudential policy effect on firm's short-term debt
cap erase "\analysis\output\tables\regressions\shortterm_table7.tex"
timer on 7
foreach a of local operation_related{
#delimit;
xi: xtreg loans_leverage `firm_control' `country_control'
				          tax_rate tax_rate_ds
			              `a'       `a'_ds 
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\shortterm_table7.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's short-term debt");
#delimit cr
}
timer off 7

* Table 8. Macroprudential policy effect on firm's short-term debt (capital related indexes)
cap erase "\analysis\output\tables\regressions\shortterm_table8.tex"
timer on 8
foreach a of local capital_related{
#delimit;
xi: xtreg loans_leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\shortterm_table8.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's short-term debt (capital related indexes)");
#delimit cr
}
timer off 8

//=================================================
//================= TESTE =========================
//=================================================

//================================================
//====== Dataset: all firms                 ======
//====== Regressand: leverage               ======
//====== Regressors: one year lag indexes   ======
//====== Fixed effects: subsidiary and time ======
//================================================

* Table X. Macroprudential policy effect on firm's financial leverage: one year lag indexes
cap erase "\analysis\output\tables\regressions\leverage_test.tex"
timer on 11
foreach a of local operation_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        l4_`a'       l4_`a'_ds  
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\leverage_test.tex", 
keep(`firm_control' `country_control' l4_`a' l4_`a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage: one year lag indexes");
#delimit cr
}
timer off 11

//=================================================
//================= FIM DO TESTE ==================
//=================================================

//============================================================
//====== Dataset: multinationals                        ======
//====== Regressand: leverage                           ======
//====== Regressors: all cumulative indexes             ======
//====== Fixed effects: multinational*time and industry ======
//============================================================

keep if multinational == 1
sort debt_shifting_group subsidiary_ID
xtset debt_shifting_group

* Table 9. Macroprudential policy effect on firm's leverage: multinational*time fixed effects
cap erase "\analysis\output\tables\regressions\multyearFE_table9.tex"
timer on 9
foreach a of local operation_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate `a'					 
i.nace2, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\multyearFE_table9.tex", 
keep(`firm_control' `country_control' tax_rate `a')
addtext("Multinational-year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's leverage: multinational*time fixed effects");
#delimit cr
}
timer off 9

* Table 10. Macroprudential policy effect on firm's leverage (capital related indexes): multinational*time fixed effects
cap erase "\analysis\output\tables\regressions\multyearFE_table10.tex"
timer on 10
foreach a of local capital_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate `a'					 
i.nace2, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\multyearFE_table10.tex", 
keep(`firm_control' `country_control' tax_rate `a')
addtext("Multinational-year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's leverage (capital related indexes): multinational*time fixed effects");
#delimit cr
}
timer off 10

//=================================================
//================= TESTE =========================
//=================================================

//============================================================
//====== Dataset: multinationals                        ======
//====== Regressand: leverage                           ======
//====== Regressors: all cumulative indexes             ======
//====== Fixed effects: multinational*time and country  ======
//============================================================

* Table Y. Macroprudential policy effect on firm's leverage: multinational*time and country fixed effects
cap erase "\analysis\output\tables\regressions\multyearFE_test.tex"
timer on 12
foreach a of local operation_related{
#delimit;
xi: xtreg leverage `firm_control' `country_control'
				   tax_rate `a'					 
i.ifscode, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\multyearFE_test.tex", 
keep(`firm_control' `country_control' tax_rate `a')
addtext("Multinational-year and country fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's leverage: multinational*time and country fixed effects");
#delimit cr
}
timer off 12

//=================================================
//================= FIM DO TESTE ==================
//=================================================

timer list
