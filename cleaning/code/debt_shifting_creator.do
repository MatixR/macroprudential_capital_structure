* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create debt shifting variables according to
* Huzinga, Laeven, Nicodeme JFE 2008 

* NOTE: we differentiate stand-alone firms to own-owners firms: the first are firms
* which we do not have information about other firms at their multinational level, 
* the second are firms that do not have parent firms
set more off
use "C:\Users\User\work\master_thesis\cleaning\temp\dataset_no_debt_shifting_`1'", clear

//========================
//====== Indicators ======
//========================

* Create multinational indicator
replace guo_bvdepnr = idnr if  missing(guo_bvdepnr)
sort guo_bvdepnr idnr
egen multinational_ID = group(guo_bvdepnr)

* Create subsidiary per multinational indicator
egen multinational_subsidiary_ID = concat(guo_bvdepnr idnr)
sort multinational_ID multinational_subsidiary_ID
by multinational_ID multinational_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_ID (multinational_subsidiary_ID): gen subsidiary_ID = sum(help1)
drop help1
sort multinational_ID subsidiary_ID

* Create parent and own-owner firm dummy
by multinational_ID: egen mean_subsidiary_ID = mean(subsidiary_ID)
gen owner = 1 if guo_bvdepnr == idnr
replace owner = 0 if missing(owner)
gen parent = 1 if mean_subsidiary_ID > owner & owner > 0
replace parent = 0 if missing(parent)

* Create intermediate indicator
replace ish_bvdepnr = idnr if  missing(ish_bvdepnr)
sort ish_bvdepnr idnr
egen intermediate_group_ID = group(ish_bvdepnr)

* Create subsidiary per intermediate indicator
egen intermediate_subsidiary_ID = concat(ish_bvdepnr idnr)
sort intermediate_group_ID intermediate_subsidiary_ID
by intermediate_group_ID intermediate_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort intermediate_group_ID (intermediate_subsidiary_ID): gen subsidiary_ID2 = sum(help1)
drop help1
sort intermediate_group_ID subsidiary_ID2

* Create intermediate firm dummy
by intermediate_group_ID: egen mean_subsidiary_ID2 = mean(subsidiary_ID2)
gen no_intermediate = 1 if ish_bvdepnr == idnr
replace no_intermediate = 0 if missing(no_intermediate)
gen intermediate = 1 if mean_subsidiary_ID2 > no_intermediate & no_intermediate > 0
replace intermediate = 0 if missing(intermediate) | parent == 1

* Labeling  and changing unit of variables
lab var MPI "Macroprudential policy index"
gen help1 = tax_rate/100
replace tax_rate = help1
drop help1
lab var tax_rate "Corporate tax rate"
lab var parent "Parent"

sort idnr closdate_year

//====================================
//====== Debt shifting variable ======
//==================================== 

* Split dataset in multinationals and stand-alone firms
//================== Stand Alone Firm =================
preserve
keep if mean_subsidiary_ID ==1

* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational 

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX tax_rate{
gen `a'_debt_shift = .
lab var `a'_debt_shift "`a' incentive to shift debt"
}
drop debt_shifting_group
save "C:\Users\User\work\master_thesis\cleaning\output\dataset_stand_alone_`1'", replace
restore

//==================== Multinationals ==================
drop if mean_subsidiary_ID ==1

* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational

* Create debt shifting variable
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX tax_rate{
gen `a'_debt_shift = .
lab var `a'_debt_shift "`a' incentive to shift debt"
quiet summ debt_shifting_group

forvalues i=1/`r(max)'{
quiet summ subsidiary if debt_shifting_group==`i'

  foreach k of num 1/`r(max)'{
by debt_shifting_group: gen help`k' = (`a'-`a'[`k'])*asset_share[`k'] if debt_shifting_group==`i'

  }
quiet egen debt_shift_help = rowtotal(help*) if debt_shifting_group==`i'
quiet replace `a'_debt_shift = debt_shift_help if debt_shifting_group==`i'
quiet drop help* debt_shift_help
}
}
save "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_`1'", replace

//==================== Merged Dataset ======================
append using "C:\Users\User\work\master_thesis\cleaning\output\dataset_stand_alone_`1'"
save "C:\Users\User\work\master_thesis\cleaning\output\dataset_full_`1'", replace
