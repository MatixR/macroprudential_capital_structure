//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file merges World Bank controls to Orbis sample          //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
cd "S:"      
set more off

//============================================================================//
// Clean World Bank dataset                                                   //
//============================================================================//

foreach a in cpi gdp_growth_rate gdp_per_capita private_credit_GDP tax_rate{
insheet using "\input\\`a'.csv", clear

* Drop lines and collumns not used
drop in 1/2
drop v1-v4
gen id = _n

* Drop obs that are not country
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup

* Turn database in long format
reshape long v, i(id) j(year_help)

* Create year variable and rename variable of interest
gen year_aux = 1955
gen year = year_aux + year_help
drop year_aux year_help
drop if id==1
rename v `a'

save "\cleaning\temp\Control`a'", replace
}

//============================================================================//
// Merge World Bank variables                                                 //
//============================================================================//

* Include country variable 
insheet using "\input\cpi.csv", clear
keep v1
drop in 1/2
gen id = _n
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
drop if id==1
rename v1 country
merge 1:m id using "\cleaning\temp\Controlcpi"
sort id year
drop _merge

save "\cleaning\temp\worldbank", replace

* Join all indexes in one file 
foreach a in cpi gdp_growth_rate gdp_per_capita private_credit_GDP tax_rate {
merge 1:1 id year using "\cleaning\temp\Control`a'"
sort id year
drop _merge
save "\cleaning\temp\worldbank", replace
}
* Create inflation variable
egen country_id = group(country)
xtset country_id year
gen logcpi = log(cpi)
bysort country_id (year):gen inflation = D.logcpi if year == year[_n-1]+1
drop logcpi country_id

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country year
drop id
save "\cleaning\temp\worldbank", replace

foreach a in cpi gdp_growth_rate gdp_per_capita private_credit_GDP tax_rate {
erase "\cleaning\temp\Control`a'.dta"
}

//============================================================================//
// Merge World Bank variables to main dataset                                 //
//============================================================================//

use "\cleaning\temp\merged_`1'.dta", clear
sort country year
merge m:1 country year using "\cleaning\temp\worldbank.dta"
keep if _merge==3
drop _merge
save "\cleaning\temp\merged_`1'.dta", replace
