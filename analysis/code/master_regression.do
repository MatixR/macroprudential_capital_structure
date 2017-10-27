* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the regression 

//=========================
//====== Arguments ========
//=========================
ssc install reghdfe
ssc install outreg2
cd "S:"
* Table 1
use "\cleaning\output\dataset_orbis.dta", clear
do "\analysis\code\regression_benchmark"

* Table 2
use "\cleaning\output\dataset_orbis.dta", clear
do "\analysis\code\robustness_other_year_base"

* Table 3
use "\cleaning\output\dataset_orbis.dta", clear
do "\analysis\code\regression_barth"

* Table 2 and 3
use "\cleaning\output\dataset_orbis.dta", clear
do "\analysis\code\regression_merged_data"




timer list
