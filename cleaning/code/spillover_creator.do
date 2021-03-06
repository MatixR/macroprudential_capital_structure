//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file manipulates raw data to create spillover variables  //
//              according to Huzinga, Laeven, Nicodeme JFE 2008               //
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

use "cleaning/output/dataset_`1'.dta", clear

* Local
local variables "tax_rate b_ovr_rest b_ovr_cong b_int_str_cap b_cap_str b_off_sup b_pri_mon b_mor_haz b_ext_gov_ind b_dep_size b_ins_dep b_ovr_str_cap"

//============================================================================//
// Create spillover variables                                                 //
//============================================================================//

* Create auxiliary variable to debt shift
egen double debt_shifting_group = group(multinationals year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = total(toas)
gen asset_share = toas/total_asset_multinational

* Create subsidiary per multinational time indicator
bysort debt_shifting_group: gen subsidiary_time_ID = _n

* Save base file
set more off
preserve
tempfile tmp2

* Keep only looped variables
keep tax_rate b_* debt_shifting_group subsidiary_time_ID id year parent asset_share 

* Create debt shifting variable among all firms of multinational
 foreach a of local variables{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_ds = rowtotal(help*)
quiet drop help* 
}

save `tmp2'

* Keep only groups with parent firm
tempfile tmp3
bysort debt_shifting_group: egen parent_indicator = mean(parent)
keep if parent_indicator > 0

* Create debt shifting variable only with parent firm
foreach a of local variables{
bysort debt_shifting_group (parent): gen help1 = `a'[_N]*asset_share[_N]
bysort debt_shifting_group (parent): gen help2 = `a'*asset_share[_N]
quiet gen `a'_ds_p= help2-help1
quiet drop help* 
}

sort id year
merge 1:1 id year using `tmp2'
drop _merge
save `tmp3'

* Keep only subsidiaries
restore
preserve
tempfile tmp4
keep if parent == 0

* Keep only looped variables
keep tax_rate  b_* debt_shifting_group subsidiary_time_ID id year parent asset_share

* Debt shift only among subsidiaries
foreach a of local variables{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_ds_s = rowtotal(help*)
quiet drop help* 
}

sort id year
merge 1:1 id year using `tmp3'
drop _merge subsidiary_time_ID parent_indicator debt_shifting_group asset_share 
save `tmp4'

* Merge debt shift variable to remaining dataset
restore
sort id year
merge 1:1 id year using `tmp4'
keep if _merge == 3
drop _merge
sort id year

* Add zeros on missing values of debt shift split variables
foreach var of varlist *_ds{
replace `var'_s=`var' if missing(`var'_s) 
replace `var'_p=0 if missing(`var'_p)
}

//============================================================================//
// Label variables                                                            //
//============================================================================//

foreach var of local variables{
lab var `var'_ds "`: var label `var'' spillover"
lab var `var'_ds_p "`: var label `var'' spillover to parent"
lab var `var'_ds_s "`: var label `var'' spillover to other subsidiaries"
}

foreach v of varlist * {
	label variable `v' `"\hspace{0.1cm} `: variable label `v''"'
	}
	
save "cleaning/output/dataset_`1'.dta", replace
