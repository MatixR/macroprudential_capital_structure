//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 24/11/2017                                                           //
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
 
//============================================================================//
// Tables                                                                     //
//============================================================================//

* Summary statistics
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\summary"

* Benchmark regression
use "\cleaning\output\dataset_bank_regulation.dta", clear
do "\analysis\code\regression_benchmark"

