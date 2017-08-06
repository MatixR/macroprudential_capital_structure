* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the regression 

//=========================
//====== Arguments ========
//=========================
cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear
set more off 
timer clear

* Tables 1 and 2
do "\analysis\code\regression_benchmark"

* Tables 3 and 4
do "\analysis\code\regression_alt_dep_vars"

* Tables 5, 6 and 7
do "\analysis\code\regression_alt_control_vars"

* Tables 8 and 9
do "\analysis\code\regression_robust_checks"

timer list
