* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics
set more off

//=====================================
//====== Multinationals Dataset =======
//=====================================
 
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_full", clear

* Summary table of variables per firm
#delimit;
estpost tabstat leverage adj_leverage MPI_debt_shift tax_rate_debt_shift intermediate parent
fixed_total tangible_total log_sales profitability opportunity risk agg_profitability,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\summary_firm_full_dirt.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

* Cleaning from outliers
replace leverage = . if leverage > 1 | leverage < 0
replace adj_leverage = . if adj_leverage > 1 | adj_leverage < 0
winsor fixed_total, gen(fixed_total_w) p(0.01)
lab var fixed_total_w "Tangibility"
winsor profitability, gen(profitability_w) p(0.01)
lab var profitability_w "Profitability"
winsor tangible_total, gen(tangible_total_w) p(0.01)
lab var tangible_total_w "Adjusted tangibility"
winsor opportunity, gen(opportunity_w) p(0.01)
lab var opportunity_w "Opportunity"
winsor agg_profitability, gen(agg_profitability_w) p(0.01)
lab var agg_profitability_w "Aggregate profitability"
winsor risk, gen(risk_w) p(0.01)
lab var risk_w "Volatility of profits"
 

* Summary table of variables per firm
#delimit;
estpost tabstat leverage adj_leverage MPI_debt_shift tax_rate_debt_shift intermediate parent
fixed_total_w tangible_total_w log_sales profitability_w opportunity_w risk_w agg_profitability_w,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\summary_firm_full_clean.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

tabout country using  "C:\Users\User\work\master_thesis\analysis\temp\summary_country_firm.txt", replace sum style(tex)

* Summary table of variables per country
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_full", clear

bysort country closdate_year: keep if _n == 1

#delimit;
estpost tabstat MPI tax_rate inflation gdp_growth_rate gdp_per_capita
credit_financial_GDP private_credit_GDP stock_traded_GDP market_cap turnover
economic_risk exchange_rate_risk financial_risk law_order political_risk,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\summary_country.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers
title("Summary statistics of country level variables");
#delimit cr

tabout country using  "C:\Users\User\work\master_thesis\analysis\temp\summary_country_firm.tex"
