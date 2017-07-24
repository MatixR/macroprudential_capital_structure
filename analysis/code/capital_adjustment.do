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
//====== Regressand: capital adjustment      ======
//====== Regressors: all cumulative indexes  ======
//====== Fixed effects: subsidiary and time  ======
//=================================================
 
sort  firm_id subsidiary_ID
xtset firm_id year
tabulate year, generate(d)

* Table 11. Capital structure partial adjustment
cap erase "\analysis\output\tables\regressions\capital_adj_table1.tex"
timer on 1
foreach a of local operation_related{
#delimit;
xtabond leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
d2-d8,  vce(robust);

outreg2 using "\analysis\output\tables\regressions\capital_adj_table1.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy and optimal capital adjustment");
#delimit cr
}
timer off 1

* Table 12. Capital structure partial adjustment (capital related variables)
cap erase "\analysis\output\tables\regressions\capital_adj_table2.tex"
timer on 2
foreach a of local capital_related{
#delimit;
xtabond leverage `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
d2-d8,  vce(robust);

outreg2 using "\analysis\output\tables\regressions\capital_adj_table2.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy and optimal capital adjustment (capital related indexes)");
#delimit cr
}
timer off 2

//============================================================
//====== Dataset: multinationals                        ======
//====== Regressand: capital adjustment                 ======
//====== Regressors: all cumulative indexes             ======
//====== Fixed effects: multinational*time and country  ======
//============================================================

keep if multinational == 1
bysort firm_id (year): gen l1_leverage = leverage[_n-1] 
sort debt_shifting_group subsidiary_ID
xtset debt_shifting_group


* Table 13. Macroprudential policy and Capital structure partial adjustment: multinational*time fixed effects
cap erase "\analysis\output\tables\regressions\capital_adj_multyearFE1.tex"
timer on 3
foreach a of local operation_related{
#delimit;
xi: xtreg leverage l1_leverage `firm_control' `country_control'
				   tax_rate `a'					 
i.nace2, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\capital_adj_multyearFE1.tex", 
keep(`firm_control' `country_control' tax_rate `a')
addtext("Multinational-year and country fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy and Capital structure partial adjustment: multinational*time fixed effects");
#delimit cr
}
timer off 3

* Table 14. Macroprudential policy and Capital structure partial adjustment (capital related variables): multinational*time fixed effects
cap erase "\analysis\output\tables\regressions\capital_adj_multyearFE2.tex"
timer on 4
foreach a of local capital_related{
#delimit;
xi: xtreg leverage l1_leverage `firm_control' `country_control'
				   tax_rate `a'					 
i.nace2, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\capital_adj_multyearFE2.tex", 
keep(`firm_control' `country_control' tax_rate `a')
addtext("Multinational-year and country fixed effects", YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy and Capital structure partial adjustment (capital related variables): multinational*time fixed effects");
#delimit cr
}
timer off 4
timer list
