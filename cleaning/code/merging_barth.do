//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file merges the World Bank Survey on Bank Regulation to  //
//              the Orbis sample                                              //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
if "`c(hostname)'" != "EG3523" {
global STATAPATH "S:"
}
else if "`c(hostname)'" == "EG3523" {
global STATAPATH "C:/Users/u1273941/Research/Projects/macroprudential_capital_structure"
}
cd "$STATAPATH"       
set more off

//============================================================================//
// Create columns                                                             //
//============================================================================//

import excel using "input/barth.xls", sheet("All Average Scaled Index") clear
rename * v#, renumber
preserve

* Country column

tempfile tmp
keep if v1 == "Number"
gen help1 = _n
drop v1-v6
reshape long v, i(help1) j(id)
drop help1
rename v country
save `tmp'

*#delimit;
*local var1 "I.IV II.IV III.I III.III IV.I IV.II IV.III
 *           V.I VII.VI VIII.IV IX.I IX.II IX.III IX.IV";
*#delimit cr
*foreach var of local var1{
*restore
*preserve
*keep if v1 == "`var'"
*gen help1 = _n
*drop v1-v6
*reshape long v, i(help1) j(id)
*drop help1
*rename v `var'
*merge m:1 id using "\cleaning\temp\barth.dta"
*keep if _merge == 3
*drop _merge
*save "\cleaning\temp\barth.dta", replace
*}

* Bank activity regulatory
restore
preserve
tempfile tmp1
keep if v1 == "I.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_sec_act_ba
save `tmp1'

restore
preserve
tempfile tmp2
keep if v1 == "I.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ins_act_ba
save `tmp2'

restore
preserve
tempfile tmp3
keep if v1 == "I.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_real_est_act_ba
save `tmp3'

restore
preserve
tempfile tmp4
keep if v1 == "I.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_rest
save `tmp4'

* Financial conglomerate
restore
preserve
tempfile tmp5
keep if v1 == "II.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_bank_owns_fc
save `tmp5'

restore
preserve
tempfile tmp6
keep if v1 == "II.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_firm_owns_fc
save `tmp6'

restore
preserve
tempfile tmp7
keep if v1 == "II.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_financial_owns_fc
save `tmp7'

restore
preserve
tempfile tmp8
keep if v1 == "II.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_cong
save `tmp8'

* Competition regulatory
restore
preserve
tempfile tmp9
keep if v1 == "III.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_lim_for
save `tmp9'

restore
preserve
tempfile tmp10
keep if v1 == "III.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_entry_req
save `tmp10'

restore
preserve
tempfile tmp11
keep if v1 == "III.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_frac_den
save `tmp11'

restore
preserve
tempfile tmp12
keep if v1 == "III.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_dom_den
save `tmp12'

restore
preserve
tempfile tmp13
keep if v1 == "III.V" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_for_den
save `tmp13'

* Capital regulatory
restore
preserve
tempfile tmp14
keep if v1 == "IV.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_str_cap
save `tmp14'

restore
preserve
tempfile tmp15
keep if v1 == "IV.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_int_str_cap
save `tmp15'

restore
preserve
tempfile tmp16
keep if v1 == "IV.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_cap_str
save `tmp16'

* Official supervisory power
restore
preserve
tempfile tmp17
keep if v1 == "V.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_off_sup
save `tmp17'

* Private monitoring 
restore
preserve
tempfile tmp18
keep if v1 == "VII.VI" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_pri_mon
save `tmp18'

* Deposit insurance scheme 
restore
preserve
tempfile tmp19
keep if v1 == "VIII.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_dep_size
save `tmp19'

restore
preserve
tempfile tmp20
keep if v1 == "VIII.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ins_dep
save `tmp20'

restore
preserve
tempfile tmp21
keep if v1 == "VIII.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_mor_haz
save `tmp21'

* Market structure indicators 
restore
preserve
tempfile tmp22
keep if v1 == "IX.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_conc_dep
save `tmp22'

restore
preserve
tempfile tmp23
keep if v1 == "IX.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_conc_ass
save `tmp23'

restore
preserve
tempfile tmp24
keep if v1 == "IX.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_for_sha
save `tmp24'

restore
preserve
tempfile tmp25
keep if v1 == "IX.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_gov_sha
save `tmp25'

* External governance
 
restore
preserve
tempfile tmp26
keep if v1 == "X.I" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ext_aud_gov
save `tmp26'

restore
preserve
tempfile tmp27
keep if v1 == "X.II" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_fin_trans_gov
save `tmp27'

restore
preserve
tempfile tmp28
keep if v1 == "X.III" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_acc_prac_gov
save `tmp28'

restore
preserve
tempfile tmp29
keep if v1 == "X.IV" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ext_rat_gov
save `tmp29'

restore
keep if v1 == "X.V" 
destring v3, replace
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ext_gov_ind

//============================================================================//
// Merge columns                                                              //
//============================================================================//

merge m:1 id using `tmp'
keep if _merge == 3
drop _merge

merge m:1 id survey using `tmp1'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp2'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp3'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp4'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp5'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp6'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp7'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp8'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp9'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp10'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp11'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp12'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp13'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp14'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp15'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp16'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp17'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp18'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp19'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp20'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp21'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp22'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp23'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp24'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp25'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp26'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp27'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp28'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp29'
keep if _merge == 3
drop _merge

//============================================================================//
// Clean dataset                                                              //
//============================================================================//

* Assign year to surveys
gen year = 1999 if survey == 1
replace year = 2002 if survey == 2 
replace year = 2006 if survey == 3 
replace year = 2011 if survey == 4 

* Order and rename variables
order country year
replace country = upper(country)

* Replace n.a. to missing
foreach var of varlist b_*{
replace `var'="." if `var'=="n.a."|`var'=="n.a"| `var'=="N/A"
}
* Destring variables
foreach var of varlist b_*{
destring `var', replace
}
* Create missing years
sort id year
xtset id year
tsfill, full
by id (year): replace country = country[_N]
 
 * interpolate indeces
 foreach var of varlist b_*{
by id: ipolate `var' year, gen(ipolated_`var')
replace `var' = ipolated_`var'
drop ipolated_`var'
}
* Drop variables not used
drop id survey

//============================================================================//
// Merge to main dataset                                                      //
//============================================================================//

save "cleaning/temp/barth.dta", replace
use "cleaning/temp/merged_`1'.dta", clear
sort country year
merge m:1 country year using "cleaning/temp/barth.dta"
drop if _merge == 2
drop _merge
save "cleaning/temp/merged_`1'", replace
