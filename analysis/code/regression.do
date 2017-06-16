* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions
set more off

//=============================================
//======      Multinationals Dataset    =======
//====== Leverage as dependent variable =======
//=============================================
 
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_sample10", clear

* Cleaning from outliers
replace leverage = . if leverage > 1 | leverage < 0
replace adj_leverage = . if adj_leverage > 1 | adj_leverage < 0
replace profitability = . if profitability < -100 | profitability > 100
replace risk = . if risk < -100 | risk > 100 

* Fixed effects - multinational*time 
egen multinational_year_ID = group(guo_bvdepnr closdate_year)
xtset multinational_year_ID
xtreg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift, fe robust

* Fixed effects - multinational and time
sort  multinational_ID subsidiary_ID
xtset multinational_ID
xi: xtreg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift i.closdate_year, fe robust


* miscelaneous 
test _b[_cons] = 0, coef


#delimit;
estimates table ., 
keep(MPI MPI_debt_shift tax_rate tax_rate_debt_shift) 
b star; 
#delimit cr

test _b[_cons] = 0, coef

quiet xi: reg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift i.multinational_year_ID

#delimit;
estimates table ., 
keep(leverage MPI MPI_debt_shift tax_rate tax_rate_debt_shift) 
b(fmt(2)) se(fmt(2)) p(fmt(2)) star; 
#delimit cr

