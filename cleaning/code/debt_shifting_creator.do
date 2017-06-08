* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create debt shifting variables according to
* Huzinga, Laeven, Nicodeme JFE 2008 
set more off, perm

use "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_control.dta", clear

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

* Create parent firm dummy
by multinational_ID: egen mean_subsidiary_ID = mean(subsidiary_ID)
gen owner = 1 if guo_bvdepnr == idnr
replace owner = 0 if missing(owner)
gen parent = 1 if mean_subsidiary_ID > owner & owner > 0
replace parent = 0 if missing(parent)

sort idnr closdate_year

//====================================
//====== Debt shifting variable ======
//==================================== 
use "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_control.dta", clear

set more off

* Split dataset in multinationals and stand-alone firms
********************** Stand Alone Firm ******************
preserve
keep if mean_subsidiary_ID ==1

* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational 

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
gen `a'_debt_shift = .
}
drop debt_shifting_group
save C:\Users\User\work\master_thesis\cleaning\temp\dataset_stand_alone, replace
restore

********************** Multinationals ******************
drop if mean_subsidiary_ID ==1

* Create auxiliary variable to debt shift
egen debt_shifting_group = group(multinational_ID closdate_year)

* Create asset share of each firm within multinational
sort debt_shifting_group
by debt_shifting_group: egen total_asset_multinational = sum(toas)
gen asset_share = toas/total_asset_multinational
* Create debt shifting variable

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
gen `a'_debt_shift = .
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
save C:\Users\User\work\master_thesis\cleaning\temp\dataset_multinationals, replace
