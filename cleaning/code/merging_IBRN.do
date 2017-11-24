//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: merges IBRN MPI quarterly index and IMF policy interest rate  //
//              datasets to Orbis sample                                      //
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
// Clean IBRN dataset                                                         //
//============================================================================//

import excel using "input/IBRN.xlsx", sheet("Data") firstrow clear

* Destring variables
foreach var of varlist _all{
destring `var', replace
}

* Drop variables not used
drop cum_* *PruC* AF

* Create index = 100 at 2007
drop if year < 2007
sort ifscode year quarter 
foreach var of varlist sscb_res-rr_local {
replace `var'=0 if year == 2007
by ifscode (year quarter): gen c_`var'=sum(`var')
}
* Create groups for moving average
gen year_1q = year 
bysort year: replace year_1q = year+1 if quarter > 1 
gen year_2q = year 
bysort year: replace year_2q = year+1 if quarter > 2
gen year_3q = year 
bysort year: replace year_3q = year+1 if quarter > 3

order year year_1q year_2q year_3q
sort ifscode year quarter

* Create year average of each index  
foreach var of varlist c_* {
bysort ifscode year_1q: egen `var'_1q = mean(`var')
bysort ifscode year_2q: egen `var'_2q = mean(`var')
bysort ifscode year_3q: egen `var'_3q = mean(`var')
bysort ifscode year: egen `var'_y = mean(`var')
replace `var'_y = `var'_1q if quarter == 1
replace `var'_y = `var'_2q if quarter == 2
replace `var'_y = `var'_3q if quarter == 3
}
* Keep only variables of interest
keep country biscode ifscode year *_y quarter
preserve

//============================================================================//
// Clean IMF interest rate dataset                                            //
//============================================================================//

insheet using "input/interest_rate.csv", clear
tempfile tmp1
* Create identifiers for peridiocity
gen year = substr(timeperiod,1,4)
destring year, replace
gen periodicity = substr(timeperiod,5,1)
gen help1 = substr(timeperiod,6,2)
destring help1, replace
gen month = help1 if periodicity == "M"
drop if missing(month)

* Calculate year average
bysort countrycode year: egen interest_rate_y = mean(interestratescentralbankpolicyra)
by countrycode year: gen dup = cond(_N==1,1,_n)
by countrycode year: keep if dup == 1
drop dup

* Rename and keep used variables
rename countrycode ifscode
keep year ifscode interest_rate_y
save `tmp1'

//============================================================================//
// Merge datasets                                                             //
//============================================================================//

restore
preserve
tempfile tmp2
* Merge European data
drop if !inlist(ifscode,122,124,132,134,136,137,138,172,174,178,181,182,184,423,936,939,941,946,961)
* Account for Slovakia joining after 2008
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
* Merge remaining countries
drop if inlist(ifscode,122,124,132,134,136,137,138,172,174,178,181,182,184,423,939,941,946,961)
* Account for Slovakia joining after 2008
gen help1 = 1 if ifscode == 936 & year>2008
drop if help1 == 1
drop help1
merge m:1 ifscode year using `tmp1'
append using `tmp3'
* Rename and keep used variables
rename biscode country_id
rename interest_rate_y interest_rate
drop  _merge
drop if missing(quarter)
replace country = upper(country)

//============================================================================//
// Merge to main dataset                                                      //
//============================================================================//

save "cleaning/temp/IBRN.dta", replace
use "cleaning/temp/merged_`1'.dta", clear
sort country_id year
merge m:1 country_id year quarter using "cleaning/temp/IBRN.dta"
keep if _merge==3
drop _merge c_*
save "cleaning/temp/merged_`1'", replace
