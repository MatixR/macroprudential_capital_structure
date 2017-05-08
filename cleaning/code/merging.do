* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges the datasets from Amadeus

* Sort using file
use C:\Users\User\work\master_thesis\cleaning\temp\financials_sample, clear
sort idnr closdate_year
save C:\Users\User\work\master_thesis\cleaning\temp\financials_sample, replace

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

* Merge
#delimit;
merge 1:1 idnr closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\financials_sample;
#delimit cr

keep if _merge == 3
drop _merge 
save C:\Users\User\work\master_thesis\cleaning\temp\financials_info_sample, replace


