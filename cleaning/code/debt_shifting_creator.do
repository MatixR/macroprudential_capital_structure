* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create debt shifting variables according to
* Huzinga, Laeven, Nicodeme JFE 2008 

* NOTE: we differentiate stand-alone firms to own-owners firms: the first are firms
* which we do not have information about other firms at their multinational level, 
* the second are firms that do not have parent firms


set more off
//use "\\Client\C$\Users\User\work\master_thesis\cleaning\temp\dataset_no_debt_shifting_`1'", clear
use "C:\Users\User\work\master_thesis\cleaning\temp\dataset_WB_`1'", clear
//use "C:\Users\User\work\master_thesis\cleaning\temp\dataset_no_debt_shifting_sample10", clear

//========================
//====== Indicators ======
//========================

* Create parent dummy
preserve 
tempfile tmp1
keep guo_bvdepnr
sort guo_bvdepnr
by guo_bvdepnr: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename guo_bvdepnr ID
save `tmp1'
restore
preserve
keep idnr
sort idnr 
by idnr: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename idnr ID
tempfile tmp2
merge 1:1 ID using `tmp1'
keep if _merge == 3
gen parent = 1 
drop _merge
rename ID idnr
save `tmp2'
restore
merge m:1 idnr using `tmp2'
drop _merge
replace parent = 0 if missing(parent)

* Create intermediate dummy
preserve 
tempfile tmp1
keep ish_bvdepnr
sort ish_bvdepnr
by ish_bvdepnr: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename ish_bvdepnr ID
save `tmp1'
restore
preserve
keep idnr
sort idnr 
by idnr: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename idnr ID
tempfile tmp2
merge 1:1 ID using `tmp1'
keep if _merge == 3
gen intermediate = 1 
drop _merge
rename ID idnr
save `tmp2'
restore
merge m:1 idnr using `tmp2'
drop _merge
replace intermediate = 0 if missing(intermediate)
replace intermediate = 0 if parent == 1

* Create multinational indicator
replace guo_bvdepnr = idnr if  missing(guo_bvdepnr)
sort guo_bvdepnr idnr
egen multinational_ID = group(guo_bvdepnr)

* Create subsidiary per multinational indicator
egen multinational_subsidiary_ID = concat(guo_bvdepnr idnr)
bysort multinational_ID multinational_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_ID (multinational_subsidiary_ID): gen subsidiary_ID = sum(help1)
drop help1 multinational_subsidiary_ID
bysort multinational_ID: egen mean_subsidiary_ID = mean(subsidiary_ID)

* Create own-owner firm dummy
gen owner = 1 if guo_bvdepnr == idnr
replace owner = 0 if missing(owner)

* Create multinational dummy
egen multinational_year_ID = group(multinational_ID closdate_year)
bysort multinational_year_ID country: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_year_ID (country): gen help2 = sum(help1)
bysort multinational_year_ID: egen help3 = mean(help2)
bysort multinational_year_ID: gen multinational = 0 if help3 == 1
replace multinational = 1 if missing(multinational)
drop multinational_year_ID help1 help2 help3

* Labeling  and changing unit of variables
lab var MPI "Macroprudential policy index"
gen help1 = tax_rate/100
replace tax_rate = help1
drop help1
lab var tax_rate "Corporate tax rate"
lab var parent "Parent"
lab var intermediate "Intermediate"

sort idnr closdate_year

//====================================
//====== Debt shifting variable ======
//==================================== 

* Split dataset in multinationals and stand-alone firms
//================== Stand Alone Firm =================
preserve
tempfile tmp1
keep if multinational == 0

* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational 

foreach a in `2'{
gen `a'_debt_shift = .
lab var `a'_debt_shift "`a' incentive to shift debt"
}
drop debt_shifting_group total_asset_multinational 
save `tmp1'
restore

//==================== Multinationals ==================
keep if multinational == 1
preserve
tempfile tmp2
* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational

* Create subsidiary per multinational time indicator
bysort debt_shifting_group: gen subsidiary_time_ID = _n

* Keeping only looped variables
keep `2' debt_shifting_group subsidiary_time_ID asset_share idnr closdate_year

* Create debt shifting variable 
timer on 1
foreach a in `2'{
quiet summ subsidiary_time_ID

forvalues k = 1/`r(max)'{
by debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_debt_shift = rowtotal(help*)
lab var `a'_debt_shift "`a' incentive to shift debt"
quiet drop help* 
}
timer off 1

* Merge debt shift variable to remaining dataset
drop debt_shifting_group subsidiary_time_ID
sort idnr closdate_year
save `tmp2'
restore
sort idnr closdate_year
merge 1:1 idnr closdate_year using `tmp2'
keep if _merge == 3
drop _merge
sort idnr closdate_year

//==================== Merged Dataset ======================
append using `tmp1'
save "C:\Users\User\work\master_thesis\cleaning\temp\dataset_debt_shift_`1'", replace

