* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file imports raw dataset from Amadeus and sample a percentage

use C:\Users\User\work\master_thesis\cleaning\input\financials_VL, clear
set more off

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"

* Drop missing values
drop if missing(fias, tfas, cash, toas, ncli, ltdb, culi, turn, ebta)

* Drop repeated observations
sort idnr closdate_year 
by idnr closdate_year: gen dup = cond(_N==1,0,_n)
keep if dup==0

* Sample % of data
sort idnr
preserve
tempfile tmp
bysort idnr: keep if _n == 1
sample 10
sort idnr
save `tmp'
restore
merge m:1 idnr using `tmp'
keep if _merge == 3
drop _merge dup
save C:\Users\User\work\master_thesis\cleaning\temp\financials_sample, replace
