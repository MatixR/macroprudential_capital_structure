* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file merges Barth et al 2008 dataset of capital strigency to Orbis sample
set more off 

//============================
//===== Create columns  ======
//============================

import excel using "\input\barth.xls", sheet("All Average Scaled Index") clear
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

* Overall strigency column
restore
preserve
tempfile tmp2
keep if v1 == "IV.I" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v ovr_str
save `tmp2'

* Initial strigency column
restore
preserve
tempfile tmp3
keep if v1 == "IV.II" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v int_str
save `tmp3'

* Total strigency column
restore
keep if v1 == "IV.III" 
destring v3, replace
keep if v3 == 3 | v3 == 4
drop v1-v2 v4-v6
rename v3 survey
reshape long v, i(survey) j(id)
rename v cap_str

//===========================
//===== Merge Columns  ======
//===========================
merge m:1 id using `tmp1'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp2'
keep if _merge == 3
drop _merge

merge 1:1 id survey using `tmp3'
keep if _merge == 3
drop _merge

//============================
//===== Clean Database  ======
//============================
* Assign year to surveys
gen year = 2007 if survey == 3
replace year = 2011 if survey == 4 

* Drop variables not used
drop id survey

* Order and rename variables
order country year
replace country = upper(country)


* Replace n.a. to missing
foreach var of varlist *_str{
replace `var'="." if `var'=="n.a."|`var'=="n.a"| `var'=="N/A"
}
* Destring variables
foreach var of varlist *_str{
destring `var', replace
}

//==============================
//===== Merge to dataset  ======
//==============================

save "\cleaning\temp\barth.dta", replace
use "\cleaning\temp\merged_`1'.dta", clear
sort country year
merge m:1 country year using "\cleaning\temp\barth.dta"
drop if _merge == 2
drop _merge
save "\cleaning\temp\merged_`1'", replace



