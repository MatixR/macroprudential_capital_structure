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
local all_cumulative  "cum_rr_foreign_y cum_rr_local_y
                       cum_sscb_res_y   cum_sscb_cons_y
                       cum_sscb_oth_y   cum_sscb_y
					   cum_cap_req_y    cum_concrat_y
					   cum_ibex_y       cum_ltv_cap_y";					   

local anti_cyclical   "cum_rr_foreign_y cum_rr_local_y cum_ltv_cap_y";

local bank_related    "cum_cap_req_y    cum_concrat_y cum_ibex_y"; 

local capital_related "cum_sscb_y     cum_sscb_cons_y 
                       cum_sscb_oth_y cum_sscb_res_y";					   
					   
#delimit cr

* Control variables			  
#delimit;				        					  
local firm_control "fixed_total_w log_fixedasset_w profitability_w"; 
local country_control "inflation  political_risk private_credit_GDP";					  
#delimit cr
					  
//=============================================================
//====== Dataset: all firms                              ======
//====== Regressand: leverage                            ======
//====== Regressors: Reserve requirement and LTV         ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================
 
sort  multinationals subsidiary_ID
xtset multinationals

* Table 1. Reserve requirement and LTV effect on leverage
*erase "\analysis\output\tables\regressions\leverage_RR_LTV.tex"
timer on 1
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);
predict `a'_ol, xb;
outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");

xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			              `a'_ds  
					multinational##c.`a'
i.year i.nace2, 
fe vce(cluster multinationals);
predict `a'_ol2, xb;
outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV.tex", 
keep(`firm_control' `country_control' `a'_ds tax_rate tax_rate_ds multinational##c.`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");
#delimit cr
}
timer off 1

//===============================================================================
//====== Dataset: all firms                                                ======
//====== Regressand: leverage                                              ======
//====== Regressors: Reserve requirements and LTV by parent and subsidiary ======
//====== Fixed effects: multinational, time and industry                   ======
//===============================================================================

* Table 2. Reserve requirement and LTV effect on leverage (parent and others subsidiaries)
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_split.tex"
timer on 2
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds_p tax_rate_ds_s
			        `a'       `a'_ds_p `a'_ds_s  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_split.tex", 
keep(`firm_control' `country_control' `a' `a'_ds_p `a'_ds_s tax_rate tax_rate_ds_p tax_rate_ds_s)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage by parent and others subsidiaries");
#delimit cr
}
timer off 2
//=============================================================
//====== Dataset: all firms                              ======
//====== Regressand: leverage                            ======
//====== Regressors: Bank and capital related            ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================

* Table 3. Capital requirement, interbank exposure and concentration limits effect on leverage
*erase "\analysis\output\tables\regressions\leverage_bank_related.tex"
timer on 3
foreach a of local bank_related{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_bank_related.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Capital requirement, interbank exposure and concentration limit effect on firm's financial leverage");
#delimit cr
}
timer off 3
* Table 4. Capital buffers effect on leverage
*erase "\analysis\output\tables\regressions\leverage_capital_related.tex"
timer on 4
foreach a of local capital_related{
#delimit;
xi: xtreg leverage_w `firm_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_capital_related.tex", 
keep(`firm_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Capital buffers effect on firm's financial leverage");
#delimit cr
}
timer off 4
//=============================================================
//====== Dataset: all firms                              ======
//====== Regressand: long and short term debt            ======
//====== Regressors: Reserve requirement and LTV         ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================

* Table 5. Reserve requirement and LTV effect on long-term debt
*erase "\analysis\output\tables\regressions\long_term_RR_LTV.tex"
timer on 5
foreach a of local anti_cyclical{
#delimit;
xi: xtreg longterm_debt_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\long_term_RR_LTV.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's long-term debt");
#delimit cr
}
timer off 5

* Table 6. Reserve requirement and LTV effect on short-term debt
*erase "\analysis\output\tables\regressions\short_term_RR_LTV.tex"
timer on 6
foreach a of local anti_cyclical{
#delimit;
xi: xtreg loans_leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\short_term_RR_LTV.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial short-term debt");
#delimit cr
}
timer off 6

//=============================================================
//====== Dataset: all firms                              ======
//====== Regressand: Optimal leverage adjustment         ======
//====== Regressors: Reserve requirement and LTV         ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================

* Table 7. Optimal capital adjustment
timer on 7
timer off 7

//======================================================
//====== Dataset: all firms                       ======
//====== Regressand: leverage                     ======
//====== Regressors: Reserve requirements and LTV ======
//====== Fixed effects: subsidiary and time       ======
//======================================================
 
sort  firm_id subsidiary_ID
xtset firm_id year

* Table 8. Reserve requirement and LTV effect on leverage
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_sub.tex"
timer on 8
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster firm_id);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_sub.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");
#delimit cr
}
timer off 8

//===============================================================================
//====== Dataset: all firms                                                ======
//====== Regressand: leverage                                              ======
//====== Regressors: Reserve requirements and LTV by parent and subsidiary ======
//====== Fixed effects: subsidiary and time                                ======
//===============================================================================

* Table 9. Reserve requirement and LTV effect on leverage by parent and others subsidiaries
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_split_sub.tex"
timer on 9
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds_p tax_rate_ds_s
			        `a'       `a'_ds_p `a'_ds_s  
i.year, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_split_sub.tex", 
keep(`firm_control' `country_control' `a' `a'_ds_p `a'_ds_s tax_rate tax_rate_ds_s tax_rate_ds_p)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage by parent and others subsidiaries");
#delimit cr
}
timer off 9 

//===================================================
//====== Dataset: all firms                    ======
//====== Regressand: leverage                  ======
//====== Regressors: Bank and capital related  ======
//====== Fixed effects: subsidiary and time    ======
//===================================================

* Table 10. Capital requirement, interbank exposure and concentration limits effect on leverage
*erase "\analysis\output\tables\regressions\leverage_bank_related_sub.tex"
timer on 10 
foreach a of local bank_related{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_bank_related_sub.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Capital requirement, interbank exposure and concentration limit effect on firm's financial leverage");
#delimit cr
}
timer off 10

* Table 11. Capital buffers effect on leverage
*erase "\analysis\output\tables\regressions\leverage_capital_related_sub.tex"
timer on 11 
foreach a of local capital_related{
#delimit;
xi: xtreg leverage_w `firm_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_capital_related_sub.tex", 
keep(`firm_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext("Subsidiary and year fixed effects", YES) label tex(frag) nocons
ctitle("") title("Capital buffers effect on firm's financial leverage");
#delimit cr
}
timer off 11

//=============================================================
//====== Dataset: all firms                              ======
//====== Regressand: leverage                            ======
//====== Regressors: Lags of reserve requirement and LTV ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================
 
sort  multinationals subsidiary_ID
xtset multinationals

* Table 12. One and two quarter lag of reserve requirement and LTV effect on leverage
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_lag1.tex"
timer on 12
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			              l1_`a'_ds 
					 multinational##c.l1_`a'
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_lag1.tex", 
keep(`firm_control' `country_control' l1_`a'_ds tax_rate tax_rate_ds  multinational##c.l1_`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");

xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			             l2_`a'_ds  
					multinational##c.l2_`a'
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_lag1.tex", 
keep(`firm_control' `country_control' l2_`a'_ds tax_rate tax_rate_ds multinational##c.l2_`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");
#delimit cr
}
timer off 12

* Table 13. Three and four lag of reserve requirement and LTV effect on leverage
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_lag2.tex"
timer on 13
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        l3_`a'_ds 
					multinational##c.l3_`a'
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_lag2.tex", 
keep(`firm_control' `country_control' l3_`a'_ds tax_rate tax_rate_ds multinational##c.l3_`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");

xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        l4_`a'_ds  
					multinational##c.l4_`a'
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_lag2.tex", 
keep(`firm_control' `country_control'  l4_`a'_ds tax_rate tax_rate_ds multinational##c.l4_`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage");
#delimit cr
}
timer off 13

//============================================================
//====== Dataset: all firms                             ======
//====== Regressand: leverage                           ======
//====== Regressors: Reserve requirement and LTV        ======
//====== Fixed effects: multinational*time and industry ======
//============================================================
 
sort debt_shifting_group subsidiary_ID
xtset debt_shifting_group

* Table 14. Reserve requirement and LTV effect on leverage with multinational*time FE
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_mult_yearFE.tex"
timer on 14
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate 
					 multinational##c.`a'
i.nace2, 
fe vce(cluster debt_shifting_group);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_mult_yearFE.tex", 
keep(`firm_control' `country_control' tax_rate multinational##c.`a')
addtext("Multinational, year and industry fixed effects", YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage (Multinational*year FE)");
#delimit cr
}
timer off 14
//=============================================================
//====== Dataset: Only multinationals with parents       ======
//====== Regressand: leverage                            ======
//====== Regressors: Reserve requirement and LTV         ======
//====== Fixed effects: multinational, time and industry ======
//=============================================================

keep if multinationals == 1
bysort multinationals: egen mean_parent = mean(parent)
drop if mean_parent == 0 

sort  multinationals subsidiary_ID
xtset multinationals

* Table 15. Reserve requirement and LTV effect on leverage for multinationals
*erase "\analysis\output\tables\regressions\leverage_RR_LTV_mult.tex"
timer on 15
foreach a of local anti_cyclical{
#delimit;
xi: xtreg leverage_w `firm_control' `country_control'
				   tax_rate tax_rate_ds
			        `a'       `a'_ds  
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "\analysis\output\tables\regressions\leverage_RR_LTV_mult.tex", 
keep(`firm_control' `country_control' `a' `a'_ds tax_rate tax_rate_ds)
addtext(Multinational, year and industry fixed effects, YES) label tex(frag) nocons
ctitle("") title("Reserve requirement and LTV effect on firm's financial leverage (only multinationals)");
#delimit cr
}
timer off 15 

timer list
