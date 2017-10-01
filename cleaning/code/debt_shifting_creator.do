* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file manipulate raw data to create debt shifting variables according to
* Huzinga, Laeven, Nicodeme JFE 2008 

* NOTE: we differentiate stand-alone firms to own-owners firms: the first are firms
* which we do not have information about other firms at their multinational level, 
* the second are firms that do not have parent firms

set more off
use "\cleaning\output\dataset_`1'.dta", clear

//====================================
//====== Debt shifting variable ======
//==================================== 

* Split dataset in multinationals and stand-alone firms
//================== Stand Alone Firm =================
sort id year
preserve
tempfile tmp1
keep if multinational == 0

foreach a of varlist tax_rate_i c_rr_local_y  c_cap_req_y cap_str ovr_str int_str{
gen `a'_ds = 0
gen `a'_ds_s = 0
gen `a'_ds_p = 0
}

foreach a of varlist tax_rate_a cap_str ovr_str int_str{
gen `a'_ds_a = 0
gen `a'_ds_s_a = 0
gen `a'_ds_p_a = 0
}
save `tmp1'
restore

//==================== Multinationals ==================
keep if multinational == 1

* Create auxiliary variable to debt shift
egen double debt_shifting_group = group(multinationals year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = total(toas)
gen asset_share = toas/total_asset_multinational

* Create average asset share of each firm within multinational
by debt_shifting_group: egen avg_total_asset_multinational = total(avg_toas)
gen avg_asset_share = avg_toas/avg_total_asset_multinational

* Create subsidiary per multinational time indicator
bysort debt_shifting_group: gen subsidiary_time_ID = _n

* Save base file
set more off
preserve
tempfile tmp2

* Keep only looped variables
keep tax_rate_i tax_rate_a c_rr_local_y c_cap_req_y cap_str ovr_str int_str debt_shifting_group subsidiary_time_ID asset_share avg_asset_share id year parent

* Create debt shifting variable among all firms of multinational
 foreach a of varlist tax_rate_i c_rr_local_y c_cap_req_y *_str{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_ds = rowtotal(help*)
quiet drop help* 
}

* Create average debt shifting variable among all firms of multinational for Barth data
foreach a of varlist tax_rate_a *_str{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*avg_asset_share[`k']
}
quiet egen `a'_ds_a = rowtotal(help*)
quiet drop help* 
}

save `tmp2'

* Keep only groups with parent firm
tempfile tmp3
bysort debt_shifting_group: egen parent_indicator = mean(parent)
keep if parent_indicator > 0

* Create debt shifting variable only with parent firm
foreach a of varlist tax_rate_i c_rr_local_y  c_cap_req_y *_str{
bysort debt_shifting_group (parent): gen help1 = `a'[_N]*asset_share[_N]
bysort debt_shifting_group (parent): gen help2 = `a'*asset_share[_N]
quiet gen `a'_ds_p= help2-help1
quiet drop help* 
}

* Create average debt shifting variable only with parent firm for Barth data
foreach a of varlist tax_rate_a *_str{
bysort debt_shifting_group (parent): gen help1 = `a'[_N]*avg_asset_share[_N]
bysort debt_shifting_group (parent): gen help2 = `a'*avg_asset_share[_N]
quiet gen `a'_ds_p_a= help2-help1
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
keep tax_rate_i tax_rate_a c_rr_local_y  c_cap_req_y cap_str ovr_str int_str debt_shifting_group subsidiary_time_ID asset_share avg_asset_share id year parent

* Debt shift only among subsidiaries
foreach a of varlist tax_rate_i c_rr_local_y  c_cap_req_y *_str{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_ds_s = rowtotal(help*)
quiet drop help* 
}

* Average debt shift only among subsidiaries for Barth datas
foreach a of varlist tax_rate_a *_str{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*avg_asset_share[`k']
}
quiet egen `a'_ds_s_a = rowtotal(help*)
quiet drop help* 
}

sort id year
merge 1:1 id year using `tmp3'
drop _merge subsidiary_time_ID parent_indicator debt_shifting_group asset_share avg_asset_share
save `tmp4'

* Merge debt shift variable to remaining dataset
restore
sort id year
merge 1:1 id year using `tmp4'
keep if _merge == 3
drop _merge
sort id year

//==================== Merged Dataset ======================
append using `tmp1'

foreach var of varlist *_ds{
replace `var'_s=`var' if missing(`var'_s) 
replace `var'_p=0 if missing(`var'_p)
}
foreach var of varlist *_str_ds{
replace `var'_s_a=`var' if missing(`var'_s_a) 
replace `var'_p_a=0 if missing(`var'_p_a)
}
replace tax_rate_a_ds_s_a = tax_rate_a_ds_a if missing(tax_rate_a_ds_s_a) 
replace tax_rate_a_ds_p_a=0 if missing(tax_rate_a_ds_p_a) 
//=============================
//====== Label variables ======
//============================= 
 
foreach var of varlist tax_rate_i c_rr_local_y  c_cap_req_y cap_str ovr_str int_str{
lab var `var'_ds "`: var label `var'' spillover"
lab var `var'_ds_p "`: var label `var'' spillover to parent"
lab var `var'_ds_s "`: var label `var'' spillover to other subsidiaries"
}
foreach var of varlist tax_rate_a cap_str ovr_str int_str{
lab var `var'_ds_a "`: var label `var'' spillover"
lab var `var'_ds_p_a "`: var label `var'' spillover to parent"
lab var `var'_ds_s_a "`: var label `var'' spillover to other subsidiaries"
}

save "\cleaning\output\dataset_`1'.dta", replace

