//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 12/04/2017                                                           //
// Description: this file runs all the regressions tables                     //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
if "`c(hostname)'" != "EG3523" {
global STATAPATH "S:"
}
else if "`c(hostname)'" == "EG3523" {
global STATAPATH "C:/Users/u1273941/Research/Projects/macroprudential_capital_structure"
}
cd "$STATAPATH"     
set more off

* Particular
ssc install reghdfe, replace
ssc install estout, replace
ssc install outreg2, replace
ssc install tuples, replace
 
//============================================================================//
// Tables                                                                     //
//============================================================================//

* Summary statistics
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\summary"

* Table with distribution of sample across countries and years
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\distribution_country_year"

* Table with correlation among bank regulation variables
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\correlation"

* Benchmark regressions
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\regression_benchmark"

* Robustness regressions 
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\regression_robustness"

* Extension regressions 
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\regression_extension"
