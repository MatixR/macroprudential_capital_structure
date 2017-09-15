* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the regression 

//=========================
//====== Arguments ========
//=========================
cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear
timer clear

* Table 1
do "\analysis\code\regression_benchmark"

* Tables 2 and 3
do "\analysis\code\regression_alt_dep_vars"

* Tables 4 and 5
do "\analysis\code\regression_extensions"

timer list
