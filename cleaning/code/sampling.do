* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file imports raw dataset from Amadeus and sample a percentage

use "C:\Users\User\work\master_thesis\cleaning\input\\`2'", clear
set more off

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"

* Drop missing values
drop if missing(toas, ncli, culi)

* Drop repeated observations
sort idnr closdate_year months
by idnr closdate_year: gen dup = cond(_N==1,0,_n)
drop if dup == 2
drop dup

* Sample % of data
sort idnr
preserve
tempfile tmp
bysort idnr: keep if _n == 1
sample `3'
sort idnr
save `tmp'
restore
merge m:1 idnr using `tmp'
keep if _merge == 3
drop _merge
sort idnr closdate_year
drop sd_isin sd_ticker consol
save "C:\Users\User\work\master_thesis\cleaning\temp\financials_`1'", replace
