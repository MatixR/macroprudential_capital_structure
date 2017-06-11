* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics
set more off

//=====================================
//====== Multinationals Dataset =======
//=====================================
 
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_sample10", clear

* Summary table of variables per firm
#delimit;
estpost tabstat leverage adj_leverage MPI_debt_shift tax_rate_debt_shift
fixed_total tangible_total log_sales profitability opportunity risk agg_profitability,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\summary_firm.tex",
replace cells("count(fmt(a3)) mean sd min max") label noobs nonumbers
title("Summary statistics of firm level variables");
#delimit cr

* Summary table of variables per country
bysort country closdate_year: keep if _n == 1

#delimit;
estpost tabstat MPI tax_rate inflation gdp_growth_rate gdp_per_capita
credit_financial_GDP private_credit_GDP stock_traded_GDP market_cap turnover,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\summary_country.tex",
replace cells("count(fmt(a3)) mean sd min max") label noobs nonumbers
title("Summary statistics of country level variables");
#delimit cr



 
 
 


