* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics
set more off

//===================================
//====== Basic Summary tables =======
//===================================
 
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
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_full", clear
* Turning country variables at proper case and adding variable that tells parent country
bysort idnr: keep if _n == 1
replace country = proper(country)
preserve
tempfile tmp1
keep guo_cntry 
bysort guo_cntry: keep if _n == 1
save `tmp1'
restore
preserve
tempfile tmp2
keep country cntrycde
rename cntrycde guo_cntry
merge m:1 guo_cntry using `tmp1'
keep if _merge == 3 
drop _merge
bysort guo_cntry: keep if _n == 1
rename country guo_country
save `tmp2'
restore
merge m:1 guo_cntry using `tmp2'
replace guo_country = "Other" if missing(guo_country) 



eststo: estpost tab country parent 
eststo: estpost tab guo_country 
esttab , cell(b) unstack noobs fragment 

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
