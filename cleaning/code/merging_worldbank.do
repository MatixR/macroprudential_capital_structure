* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges World Bank controls datasets to Amadeus sample
set more off


//========================================
//====== Clean World Bank Database  ======
//========================================

foreach a in cpi credit_financial_GDP deflator gdp_growth_rate gdp_per_capita market_cap_GDP private_credit_GDP stock_traded_GDP tax_rate turnover {
insheet using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\\`a'.csv", clear

* Drop lines and collumns not used
drop in 1/2
drop v1-v4
gen id = _n

* Drop obs that are not country
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup

* Turn database in long format
reshape long v, i(id) j(year_help)

* Create year variable and rename variable of interest
gen year_aux = 1955
gen year = year_aux + year_help
drop year_aux year_help
drop if id==1
rename v `a'

save "S:\temp\Control`a'.dta", replace

}

//========================================
//===== Merge World Bank Database  =======
//========================================
* Include country variable 
insheet using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\cpi.csv", clear
keep v1
drop in 1/2
gen id = _n
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
drop if id==1
rename v1 country
#delimit;
merge 1:m id using 
"S:\temp\Controlcpi";
#delimit cr
sort id year
drop _merge

save "S:\temp\worldbank.dta", replace

* Join all indexes in one file 
foreach a in credit_financial_GDP deflator gdp_growth_rate gdp_per_capita market_cap_GDP private_credit_GDP stock_traded_GDP tax_rate turnover {
#delimit;
merge 1:1 id year using 
"S:\temp\Control`a'";
#delimit cr
sort id year
drop _merge
save "S:\temp\worldbank.dta", replace
}

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country year
drop id
save "S:\temp\worldbank.dta", replace

foreach a in cpi credit_financial_GDP deflator gdp_growth_rate gdp_per_capita market_cap_GDP private_credit_GDP stock_traded_GDP tax_rate turnover {

erase "S:\temp\Control`a'.dta"
}

//===========================================================
//===== Merge World Bank Database to Financia dataset  ======
//===========================================================

use "S:\temp\merged_MPI_`1'.dta", clear
sort country year
#delimit;
merge m:1 country year using 
"S:\temp\worldbank.dta";
#delimit cr
keep if _merge==3
drop _merge
save "S:\temp\merged_MPI_WB_`1'.dta", replace
