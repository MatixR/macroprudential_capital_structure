//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file merges PRS controls to Orbis sample                 //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
cd "S:"      
set more off

//============================================================================//
// Clean PRS dataset                                                          //
//============================================================================//

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
import excel using "\input\\`a'.xlsx", sheet("Sheet1") firstrow clear

* Drop lines and collumns not used, rename variables and create ID
drop if inlist(_n,_N)
drop Country Variable
rename * v#, renumber
gen id = _n

* Turn database in long format
reshape long v, i(id) j(year_help)

* Create year variable and rename variable of interest
gen year_aux = 1983
gen year = year_aux + year_help
drop year_aux year_help
rename v `a'

save "\cleaning\temp\Control`a'.dta", replace
}

//============================================================================//
// Merge PRS variables                                                        //
//============================================================================//

* Include country variable 
import excel using "\input\economic_risk.xlsx", sheet("Sheet1") firstrow clear
keep Country
drop if inlist(_n,_N)
gen id = _n
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
rename Country country
merge 1:m id using "\cleaning\temp\Controleconomic_risk"
sort id year
drop _merge

save "\cleaning\temp\PRS.dta", replace

* Join all indexes in one file 
foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
merge 1:1 id year using "\cleaning\temp\Control`a'"
sort id year
drop _merge
save "\cleaning\temp\PRS.dta", replace
}

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country year
drop id
save "\cleaning\temp\PRS.dta", replace

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
erase "\cleaning\temp\Control`a'.dta"
}

* Inverting indexes
gen political_risk_i = 100-political_risk
drop political_risk
rename political_risk_i political_risk

gen economic_risk_i = 50-economic_risk
drop economic_risk
rename economic_risk_i economic_risk

gen financial_risk_i = 50-financial_risk
drop financial_risk
rename financial_risk_i financial_risk

gen exchange_rate_risk_i = 10-exchange_rate_risk
drop exchange_rate_risk
rename exchange_rate_risk_i exchange_rate_risk

//============================================================================//
// Merge PRS variables to main dataset                                        //
//============================================================================//

use "\cleaning\temp\merged_`1'.dta", clear
sort country year
merge m:1 country year using "\cleaning\temp\PRS"
keep if _merge==3
drop _merge
save "\cleaning\temp\merged_`1'.dta", replace
