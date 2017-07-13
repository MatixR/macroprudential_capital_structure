* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges international country risk guide (PRS) controls datasets to Amadeus sample
set more off


//=================================
//====== Clean PRS Database  ======
//=================================

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
import excel using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\\`a'.xlsx", sheet("Sheet1") firstrow clear

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

save "S:\temp\Control`a'.dta", replace

}

//=================================
//===== Merge PRS Database  =======
//=================================
* Include country variable 
import excel using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\economic_risk.xlsx", sheet("Sheet1") firstrow clear
keep Country
drop if inlist(_n,_N)
gen id = _n
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
rename Country country
#delimit;
merge 1:m id using 
"S:\temp\Controleconomic_risk";
#delimit cr
sort id year
drop _merge

save "S:\temp\PRS.dta", replace

* Join all indexes in one file 
foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
#delimit;
merge 1:1 id year using 
"S:\temp\Control`a'";
#delimit cr
sort id year
drop _merge
save "S:\temp\PRS.dta", replace
}

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country year
drop id
save "S:\temp\PRS.dta", replace

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {

erase "S:\temp\Control`a'.dta"
}
//===========================================
//===== Merge PRS Database to Amadeus  ======
//===========================================

use "S:\temp\merged_MPI_WB_DS_`1'", clear
sort country year
#delimit;
merge m:1 country year using 
"S:\temp\PRS";
#delimit cr
keep if _merge==3
drop _merge
save "S:\temp\merged_MPI_WB_DS_PRS_`1'.dta", replace
