* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges IBRN MPI quarterly index and IMF policy interest rate datasets to Amadeus sample
set more off 

//=================================
//===== Clean IBRN Database  ======
//=================================

import excel using "\input\IBRN.xlsx", sheet("Data") firstrow clear

foreach var of varlist _all{
* Destring variables
destring `var', replace
}
* Creating groups for moving average
gen year_1q = year 
bysort year: replace year_1q = year+1 if quarter > 1 
gen year_2q = year 
bysort year: replace year_2q = year+1 if quarter > 2
gen year_3q = year 
bysort year: replace year_3q = year+1 if quarter > 3

order year year_1q year_2q year_3q
sort ifscode year quarter
foreach var of varlist sscb_res-cum_PruC2{
* Create year average of each index  
bysort ifscode year_1q: egen `var'_1q = mean(`var')
bysort ifscode year_2q: egen `var'_2q = mean(`var')
bysort ifscode year_3q: egen `var'_3q = mean(`var')
bysort ifscode year: egen `var'_y_avg = mean(`var')
replace `var'_y_avg = `var'_1q if quarter == 1
replace `var'_y_avg = `var'_2q if quarter == 2
replace `var'_y_avg = `var'_3q if quarter == 3
}

keep country biscode ifscode year *_y_avg quarter

preserve

//==============================================
//===== Clean IMF Interest Rate Database  ======
//==============================================

insheet using "\input\interest_rate.csv", clear
tempfile tmp1
* Calculating year average
gen year = substr(timeperiod,1,4)
destring year, replace

gen periodicity = substr(timeperiod,5,1)

gen help1 = substr(timeperiod,6,2)
destring help1, replace

gen month = help1 if periodicity == "M"
drop if missing(month)

bysort countrycode year: egen interest_rate_y_avg = mean(interestratescentralbankpolicyra)
by countrycode year: gen dup = cond(_N==1,1,_n)
by countrycode year: keep if dup == 1
drop dup

rename countrycode ifscode
keep year ifscode interest_rate_y_avg
save `tmp1'

//==============================
//===== Merge datasets =========
//==============================
restore
preserve
tempfile tmp2
drop if !inlist(ifscode,122,124,132,134,136,137,138,172,174,178,181,182,184,423,936,939,941,946,961)
gen help1 = 1 if ifscode == 936 & year<=2008
drop if help1 == 1
drop help1
save `tmp2'
use `tmp1'
tempfile tmp3
keep if ifscode == 163
drop ifscode
merge 1:m year using `tmp2'
drop _merge
save `tmp3'
restore
drop if inlist(ifscode,122,124,132,134,136,137,138,172,174,178,181,182,184,423,939,941,946,961)
gen help1 = 1 if ifscode == 936 & year>2008
drop if help1 == 1
drop help1
merge m:1 ifscode year using `tmp1'
append using `tmp3'

rename biscode country_id
drop  _merge
replace country = upper(country)

sort ifscode year

save "\cleaning\temp\IBRN.dta", replace


