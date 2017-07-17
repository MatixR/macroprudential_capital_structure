* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics


//===================================
//====== Basic Summary tables =======
//===================================
 
use "S:\output\dataset_orbis.dta", clear

set more off
gen nace2 = int(nace/100)
rename multinational_ID multinationals
drop if multinational == 0

keep if type_id == "C"

bysort multinationals: egen mean_parent = mean(parent)
drop if mean_parent == 0

* Raw summary table of variables per firm
#delimit;
estpost tabstat leverage adj_leverage  
cum_ltv_cap_y_avg_debt_shift cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
intermediate parent fixed_total tangible_total intangible_total 
log_sales profitability opportunity agg_profitability risk,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "S:\output\Tex\summary_firm_orbis_dirt.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

* Cleaning from outliers
replace leverage = . if leverage > 1 | leverage < 0
replace adj_leverage = . if adj_leverage > 1 | adj_leverage < 0

winsor fixed_total, gen(fixed_total_w) p(0.001)
lab var fixed_total_w "Tangibility"

winsor profitability, gen(profitability_w) p(0.001)
lab var profitability_w "Profitability"

winsor tangible_total, gen(tangible_total_w) p(0.001)
lab var tangible_total_w "Adjusted tangibility"

winsor intangible_total, gen(intangible_total_w) p(0.001)
lab var intangible_total_w "Intangibility"

winsor opportunity, gen(opportunity_w) p(0.001)
lab var opportunity_w "Opportunity"

winsor agg_profitability, gen(agg_profitability_w) p(0.001)
lab var agg_profitability_w "Aggregate profitability"

winsor risk, gen(risk_w) p(0.01)
lab var risk_w "Volatility of profits"

winsor log_sales, gen(log_sales_w) p(0.001)
lab var log_sales_w "Log of sales"

winsor log_fixedasset, gen(log_fixedasset_w) p(0.001)
lab var log_fixedasset_w "Log of fixed assets" 

* Clean summary table of variables per firm
#delimit;
estpost tabstat leverage adj_leverage  
cum_ltv_cap_y_avg_debt_shift cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
intermediate parent fixed_total_w tangible_total_w intangible_total_w 
log_sales profitability_w opportunity_w agg_profitability_w risk_w,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "S:\output\Tex\summary_firm_orbis_clean.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr


* Summary table of variables per country
*use "S:\output\dataset_orbis.dta", clear

bysort country year: keep if _n == 1

#delimit;
estpost tabstat cum_ltv_cap_y_avg cum_rr_local_y_avg tax_rate 
inflation gdp_growth_rate gdp_per_capita
credit_financial_GDP private_credit_GDP stock_traded_GDP market_cap turnover
economic_risk exchange_rate_risk financial_risk law_order political_risk,
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "S:\output\Tex\summary_country_orbis.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers
title("Summary statistics of country level variables");
#delimit cr

tabout country using  "C:\Users\User\work\master_thesis\analysis\temp\summary_country_firm.tex"


//====================================
//====== MPI Correlation table =======
//====================================

use "C:\Users\User\work\master_thesis\cleaning\temp\MPI", clear
drop if !inlist(ifscode,122,124,132,134,136,137,138,172,174,178,181,182,184,423,936,939,941,946,961)
keep year MPI country
reshape wide MPI, i(year) j(country) string
rename MPI* *
foreach lab of varlist Austria-Spain{
label var `lab' "`lab'"
} 
 
#delimit;
corrtex Austria-Spain, file("C:\Users\User\work\master_thesis\analysis\temp\MPI_correl.tex") 
replace digits(2)  landscape title("Aggregate MPI cross-correlation table");
#delimit cr

//===================================================
//====== Number of firms per country per type =======
//===================================================

* Parent firms and subsidiary by host country collumns
use "S:\output\dataset_orbis.dta", clear
set more off
drop if multinational == 0
keep if type_id == "C"
rename multinational_ID multinationals

bysort multinationals: egen mean_parent = mean(parent)
drop if mean_parent == 0

bysort id: keep if _n == 1

estpost tab country parent 
#delimit;
esttab using "S:\output\Tex\number_firms_orbis_1.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr

* Parent firms and subsidiary by host country collumns
use "S:\output\dataset_orbis.dta", clear
set more off
drop if multinational == 0
keep if type_id == "C"
rename multinational_ID multinationals

bysort multinationals: egen mean_parent = mean(parent)
drop if mean_parent == 0

egen firm_parent_ID = group(id id_P)
bysort firm_parent_ID: keep if _n == 1
estpost tab country_id_P 

#delimit;
esttab using "S:\output\Tex\number_firms_orbis_2.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr
* Obs: final table merged by hand

* Movers
bysort id: gen dup = cond(_N==1,1,_n)
drop if dup==1
rename dup Movers
estpost tab Movers
#delimit;
esttab using "S:\output\Tex\movers.tex", 
cell(b) noobs fragment replace; 
#delimit cr
//=================================
//====== MPI Summary tables =======
//=================================
tempfile tmp
import excel ifscode var1 country using C:\Users\User\Data\IMF\ifs_code.xlsx, sheet("Sheet1") clear
drop in 1/2
drop var1
destring ifscode, replace
save `tmp'
use "C:\Users\User\work\master_thesis\cleaning\temp\IBRN", clear
drop if missing(cntrycde)
replace ifscode = 942 if ifscode == 965 
merge m:1 ifscode using `tmp' 
order year cntrycde ifscode country
keep if _merge==3
drop _merge 
lab var ltv_cap_y_avg  "Loan-to-value ratio limits"
lab var rr_foreign_y_avg "Reserve requirement on foreign currency"
lab var rr_local_y_avg "Reserve requirement on local currency"
 
 /////////// By country /////////////////////
* Table of means
#delimit;
estpost tabstat ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg,
statistics(mean) by(country);
#delimit cr

#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\mean_MPI.csv", 
cells("ltv_cap_y_avg(fmt(2)) rr_foreign_y_avg(fmt(2)) rr_local_y_avg(fmt(2))") label noobs nonumbers replace
title("Summary statistics of firm level variables");
#delimit cr

* Table of standard deviation
#delimit;
estpost tabstat ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg,
statistics(sd) by(country);
#delimit cr

#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\sd_MPI.csv", 
cells("ltv_cap_y_avg(fmt(2)) rr_foreign_y_avg(fmt(2)) rr_local_y_avg(fmt(2))") label noobs nonumbers replace
title("Summary statistics of firm level variables");
#delimit cr

* Obs: final table merged by hand
 /////////// By year /////////////////////
* Table of means
#delimit;
estpost tabstat ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg,
statistics(mean) by(year);
#delimit cr

#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\mean_MPI_year.csv", 
cells("ltv_cap_y_avg(fmt(2)) rr_foreign_y_avg(fmt(2)) rr_local_y_avg(fmt(2))") label noobs nonumbers replace;
#delimit cr

* Table of standard deviation
#delimit;
estpost tabstat ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg,
statistics(sd) by(year);
#delimit cr

#delimit;
esttab using "C:\Users\User\work\master_thesis\analysis\temp\sd_MPI_year.csv", 
cells("ltv_cap_y_avg(fmt(2)) rr_foreign_y_avg(fmt(2)) rr_local_y_avg(fmt(2))") label noobs nonumbers replace;
#delimit cr

* Obs: final table merged by hand
