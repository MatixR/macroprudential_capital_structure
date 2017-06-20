* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions
set more off

//=============================================
//======      Multinationals Dataset    =======
//====== Leverage as dependent variable =======
//=============================================
 
use "C:\Users\User\work\master_thesis\cleaning\output\dataset_multinationals_full", clear

* Cleaning from outliers

* Cleaning from outliers
replace leverage = . if leverage > 1 | leverage < 0
replace adj_leverage = . if adj_leverage > 1 | adj_leverage < 0
lab var adj_leverage "Adjusted leverage"
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

* Fixed effects - multinational and time
sort  multinational_ID subsidiary_ID
xtset multinational_ID

xi: xtreg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift  i.closdate_year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "C:\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
replace keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

#delimit;
xi: xtreg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w log_sales profitability_w opportunity_w gdp_growth_rate inflation political_risk 
i.closdate_year, 
fe vce(cluster multinational_ID);
#delimit cr
#delimit;
outreg2 using "C:\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w profitability_w opportunity_w gdp_growth_rate inflation political_risk log_sales) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg adj_leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift i.closdate_year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "C:\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

#delimit;
xi: xtreg adj_leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w log_sales profitability_w opportunity_w gdp_growth_rate inflation political_risk 
i.closdate_year, 
fe vce(cluster multinational_ID);
#delimit cr
#delimit;
outreg2 using "C:\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w profitability_w opportunity_w gdp_growth_rate inflation political_risk log_sales) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

