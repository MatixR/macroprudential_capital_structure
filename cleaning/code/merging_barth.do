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

tempfile tmp1
keep if v1 == "Number"
gen help1 = _n
drop v1-v6
reshape long v, i(help1) j(id)
drop help1
rename v country
save `tmp1'

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

* Overall restriction on banking activity
restore
preserve
tempfile tmp2
keep if v1 == "I.IV" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_rest
save `tmp2'

* Overall financial conglomerate
restore
preserve
tempfile tmp3
keep if v1 == "II.IV" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_cong
save `tmp3'

* Limitation on foreign banks
restore
preserve
tempfile tmp4
keep if v1 == "III.I" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_lim_for
save `tmp4'

* Fraction of application denied
restore
preserve
tempfile tmp5
keep if v1 == "III.III" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_frac_den
save `tmp5'

* Overall strigency column
restore
preserve
tempfile tmp6
keep if v1 == "IV.I" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_ovr_str
save `tmp6'

* Initial strigency column
restore
preserve
tempfile tmp7
keep if v1 == "IV.II" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_int_str
save `tmp7'

* Total strigency column
restore
preserve
tempfile tmp8
keep if v1 == "IV.III" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_cap_str
save `tmp8'

* Official supervisory power
restore
preserve
tempfile tmp9
keep if v1 == "V.I" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_off_sup
save `tmp9'

* Private monitoring 
restore
preserve
tempfile tmp10
keep if v1 == "VII.VI" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_pri_mon
save `tmp10'

* Moral Hazard 
restore
preserve
tempfile tmp11
keep if v1 == "VIII.IV" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_mor_haz
save `tmp11'

* Bank concentration deposit 
restore
preserve
tempfile tmp12
keep if v1 == "IX.I" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_conc_dep
save `tmp12'

* Bank concentration asset 
restore
preserve
tempfile tmp13
keep if v1 == "IX.II" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_conc_ass
save `tmp13'

* Foreign share 
restore
preserve
tempfile tmp14
keep if v1 == "IX.III" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_for_sha
save `tmp14'

* Government share 
restore
keep if v1 == "IX.IV" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v b_gov_sha

//============================================================================//
// Merge columns                                                              //
//============================================================================//

merge m:1 id using `tmp1'
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

//============================================================================//
// Clean dataset                                                              //
//============================================================================//

* Assign year to surveys
gen year = 2007 if survey == 3
replace year = 2011 if survey == 4 

* Drop variables not used
drop id survey

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
