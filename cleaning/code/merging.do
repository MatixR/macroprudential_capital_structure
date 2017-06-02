* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges the datasets from Amadeus
set more off

* Sort sample file
use C:\Users\User\work\master_thesis\cleaning\temp\financials_sample, clear
sort idnr closdate_year
drop sd_isin sd_ticker consol
save C:\Users\User\work\master_thesis\cleaning\temp\financials_sample, replace

//=========================================
//===== Merging Financials with Info ======
//=========================================

* Sort and clean master file
use C:\Users\User\work\master_thesis\cleaning\input\Info_VL, clear

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"

* Drop repeated variables
drop sd_isin sd_ticker consol

* Drop repeated observations
sort idnr closdate_year 
by idnr closdate_year: gen dup = cond(_N==1,0,_n)
keep if dup==0
drop dup 

* Merge
#delimit;
merge 1:1 idnr closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\financials_sample;
#delimit cr

keep if _merge == 3
drop _merge
save C:\Users\User\work\master_thesis\cleaning\temp\financials_info_sample, replace

//=========================================================
//===== Merging Financials and Info with Ownership ========
//=========================================================


use C:\Users\User\work\master_thesis\cleaning\input\ownership_VL, clear

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"

* Drop repeated variables
drop sd_isin sd_ticker ish_tick ish_toas guo_tick guo_toas consol

* Drop repeated observations
sort idnr 
by idnr: gen dup = cond(_N==1,0,_n)
keep if dup==0

* Merge
preserve
tempfile tmp
save `tmp'
use C:\Users\User\work\master_thesis\cleaning\temp\financials_info_sample, clear
merge m:1 idnr using `tmp'
drop if _merge == 2
drop _merge
save C:\Users\User\work\master_thesis\cleaning\temp\amadeus_sample, replace
