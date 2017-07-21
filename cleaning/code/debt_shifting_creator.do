* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create debt shifting variables according to
* Huzinga, Laeven, Nicodeme JFE 2008 

* NOTE: we differentiate stand-alone firms to own-owners firms: the first are firms
* which we do not have information about other firms at their multinational level, 
* the second are firms that do not have parent firms


set more off
use "\cleaning\temp\merged_`1'", clear

//========================
//====== Indicators ======
//========================

* Create parent dummy
preserve 
tempfile tmp1
keep id_P year
sort id_P year
by id_P year: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename id_P ID
save `tmp1'
restore
preserve
keep id year
sort id year
rename id ID
tempfile tmp2
merge 1:1 ID year using `tmp1'
keep if _merge == 3
gen parent = 1 
drop _merge
rename ID id
save `tmp2'
restore
merge m:1 id year using `tmp2'
drop _merge
replace parent = 0 if missing(parent)

* Create intermediate dummy
preserve 
tempfile tmp1
keep id_I year
sort id_I year
by id_I year: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename id_I ID
save `tmp1'
restore
preserve
keep id year
sort id year
rename id ID
tempfile tmp2
merge 1:1 ID year using `tmp1'
keep if _merge == 3
gen intermediate = 1 
drop _merge
rename ID id
save `tmp2'
restore
merge m:1 id year using `tmp2'
drop _merge
replace intermediate = 0 if missing(intermediate)
replace intermediate = 0 if parent == 1

* Create multinational indicator
replace id_P = id if  missing(id_P)
sort id_P id
egen multinational_ID = group(id_P)

* Create subsidiary per multinational indicator
egen multinational_subsidiary_ID = concat(id_P id)
bysort multinational_ID multinational_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_ID (multinational_subsidiary_ID): gen subsidiary_ID = sum(help1)
drop help1 multinational_subsidiary_ID
bysort multinational_ID: egen mean_subsidiary_ID = mean(subsidiary_ID)

* Create own-owner firm dummy
gen owner = 1 if id_P == id
replace owner = 0 if missing(owner)

* Create multinational dummy
egen multinational_year_ID = group(multinational_ID year)
bysort multinational_year_ID country_id: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_year_ID (country_id): gen help2 = sum(help1)
bysort multinational_year_ID: egen help3 = mean(help2)
bysort multinational_year_ID: gen multinational = 0 if help3 == 1
replace multinational = 1 if missing(multinational)
drop multinational_year_ID help1 help2 help3

* Labeling  and changing unit of variables
gen help1 = tax_rate/100
replace tax_rate = help1
drop help1
sort id year

//====================================
//====== Debt shifting variable ======
//==================================== 

* Split dataset in multinationals and stand-alone firms
//================== Stand Alone Firm =================
preserve
tempfile tmp1
keep if multinational == 0

foreach a of varlist `2'{
gen `a'_ds = 0
gen `a'_ds_s = 0
gen `a'_ds_p = 0
}
save `tmp1'
restore

//==================== Multinationals ==================
keep if multinational == 1

* Create auxiliary variable to debt shift
egen double debt_shifting_group = group(multinational_ID year)

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
keep `2' debt_shifting_group subsidiary_time_ID asset_share id year parent

* Create debt shifting variable among all firms of multinational
 foreach a of varlist `2'{
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
foreach a of varlist `2'{
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
keep `2' debt_shifting_group subsidiary_time_ID asset_share id year parent

* Debt shift only among subsidiaries
foreach a of varlist `2'{
quiet summ subsidiary_time_ID
forvalues k = 1/`r(max)'{
bysort debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k']
}
quiet egen `a'_ds_s = rowtotal(help*)
quiet drop help* 
}

sort id year
merge 1:1 id year using `tmp3'
drop _merge subsidiary_time_ID parent_indicator debt_shifting_group
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
save "\cleaning\temp\merged_MPI_WB_DS_`1'", replace

