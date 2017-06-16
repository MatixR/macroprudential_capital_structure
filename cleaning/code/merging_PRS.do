* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges international country risk guide (PRS) controls datasets to Amadeus sample
set more off


//=================================
//====== Clean PRS Database  ======
//=================================

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
import excel using C:\Users\User\work\master_thesis\cleaning\input\\`a'.xlsx, sheet("Sheet1") firstrow clear

* Drop lines and collumns not used, rename variables and create ID
drop if inlist(_n,_N)
drop Country Variable
rename * v#, renumber
gen id = _n

* Turn database in long format
reshape long v, i(id) j(year)

* Create year variable and rename variable of interest
gen year_aux = 1983
gen closdate_year = year_aux + year
drop year_aux year
rename v `a'

save "C:\Users\User\work\master_thesis\cleaning\temp\Control`a'.dta", replace

}

//=================================
//===== Merge PRS Database  =======
//=================================
* Include country variable 
import excel using C:\Users\User\work\master_thesis\cleaning\input\economic_risk.xlsx, sheet("Sheet1") firstrow clear
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
C:\Users\User\work\master_thesis\cleaning\temp\Controleconomic_risk;
#delimit cr
sort id closdate_year
drop _merge

save "C:\Users\User\work\master_thesis\cleaning\temp\PRS.dta", replace

* Join all indexes in one file 
foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {
#delimit;
merge 1:1 id closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\Control`a';
#delimit cr
sort id closdate_year
drop _merge
save "C:\Users\User\work\master_thesis\cleaning\temp\PRS.dta", replace
}

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country closdate_year
drop id
save "C:\Users\User\work\master_thesis\cleaning\temp\PRS.dta", replace

foreach a in economic_risk exchange_rate_risk financial_risk law_order political_risk {

erase "C:\Users\User\work\master_thesis\cleaning\temp\Control`a'.dta"
}
//===========================================
//===== Merge PRS Database to Amadeus  ======
//===========================================

use "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_WB_`1'", clear
sort country closdate_year
#delimit;
merge m:1 country closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\PRS;
#delimit cr
keep if _merge==3
drop _merge
save "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_WB_PRS_`1'.dta", replace
