* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges both macroprudential datasets to generate introduction graph
set more off
  

//=================================
//===== Clean GMPI Database  ======
//=================================

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
import excel country id var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 using "\input\anual_macroprudential_database.xlsx", sheet("`a'") clear

* Drop lines and collumns not used
drop if missing(var1)
drop country

* Drop obs that are not country
sort id
by id: gen dup = cond(_N==1,0,_n)  
keep if dup==0 
drop dup

* Turn database in long format
reshape long var, i(id) j(year_help)

* Create year variable and rename variable of interest
gen doismil = 2000
gen year = doismil + year_help
drop doismil year_help
rename var `a'

save "\cleaning\temp\Index`a'.dta", replace

}

//=================================
//===== Merge GMPI Database  ======
//=================================
* Include country variable 
import excel country id using "\input\anual_macroprudential_database.xlsx", sheet("MPI") clear
drop if missing(id)
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
#delimit;
merge 1:m id using 
"\cleaning\temp\IndexMPI";
#delimit cr
sort id year
drop _merge

save "\cleaning\temp\MPI.dta", replace

//=================================
//===== Clean IBRN Database  ======
//=================================

* Join all indexes in one file 
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
#delimit;
merge 1:1 id year using 
"\cleaning\temp\Index`a'.dta";
#delimit cr
sort id year
drop _merge
drop if missing(MPI)
save "\cleaning\temp\MPI.dta", replace
}


destring id, replace
order id year
drop country
rename id ifscode

* Erase auxiliary files
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
erase "\cleaning\temp\Index`a'.dta"
}

save "\cleaning\temp\MPI.dta", replace

import excel using "\input\IBRN.xlsx", sheet("Data") firstrow clear

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

//==============================================
//===== Clean IMF Interest Rate Database  ======
//==============================================

insheet using "\input\interest_rate.csv", clear
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

//==============================
//===== Merge datasets =========
//==============================

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
//================================
//===== Merge GMPI to IBRN  ======
//================================
tempfile tmp
sort ifscode year
#delimit;
merge 1:m ifscode year using 
"\cleaning\temp\IBRN.dta";
#delimit cr
drop _merge
drop if missing(country_id)
sort country_id year
save `tmp'




