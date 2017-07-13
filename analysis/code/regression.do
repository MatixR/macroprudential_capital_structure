* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file runs regressions
set more off

//==============================================
//======        Multinationals Dataset   =======
//====== Leverage as dependent variable  =======
//==============================================
 
use "S:\output\dataset_orbis.dta", clear

* Fixed effects - multinational and time
sort  multinationals subsidiary_ID
xtset multinationals

#delimit;
xi: xtreg leverage cum_rr_local_y_avg tax_rate cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "S:\output\Tex\regression_orbis_leverage.tex", 
replace keep(cum_rr_local_y_avg tax_rate cum_rr_local_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES, Sector FE, YES) label tex(frag) nocons
ctitle("") title("Macroprudential policy effect on firm's financial leverage");

xi: xtreg leverage cum_rr_local_y_avg tax_rate cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
fixed_total_w gdp_growth_rate inflation 
political_risk 
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "S:\output\Tex\regression_orbis_leverage.tex", 
keep(cum_rr_local_y_avg tax_rate cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
fixed_total_w gdp_growth_rate inflation political_risk) 
addtext(Multinational FE, YES, Year FE, YES, Sector FE, YES) label tex(frag) nocons
ctitle("");

xi: xtreg leverage cum_ltv_cap_y_avg tax_rate cum_ltv_cap_y_avg_debt_shift tax_rate_debt_shift 
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "S:\output\Tex\regression_orbis_leverage.tex", 
keep(cum_ltv_cap_y_avg tax_rate cum_ltv_cap_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES, Sector FE, YES) label tex(frag) nocons
ctitle("");

xi: xtreg leverage cum_ltv_cap_y_avg tax_rate cum_ltv_cap_y_avg_debt_shift tax_rate_debt_shift 
fixed_total_w gdp_growth_rate inflation 
political_risk 
i.year i.nace2, 
fe vce(cluster multinationals);

outreg2 using "S:\output\Tex\regression_orbis_leverage.tex", 
keep(cum_ltv_cap_y_avg tax_rate cum_ltv_cap_y_avg_debt_shift tax_rate_debt_shift 
fixed_total_w gdp_growth_rate inflation political_risk) 
addtext(Multinational FE, YES, Year FE, YES, Sector FE, YES) label tex(frag) nocons
ctitle("");
#delimit cr


//=====================================================
//======        Multinationals Dataset          =======
//====== Leverage growth as dependent variable  =======
//=====================================================

xi: xtreg leverage_g MPI tax_rate MPI_debt_shift tax_rate_debt_shift  i.year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg leverage_g BORROWER tax_rate BORROWER_debt_shift tax_rate_debt_shift  i.year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg leverage_g rr_local_y_avg tax_rate rr_local_y_avg_debt_shift tax_rate_debt_shift i.year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(rr_local_y_avg tax_rate rr_local_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg leverage_g ltv_cap_y_avg tax_rate ltv_cap_y_avg_debt_shift tax_rate_debt_shift i.year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(rr_local_y_avg tax_rate rr_local_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr 

//===============================================================================
#delimit;
xi: xtreg leverage cum_rr_local_y_avg tax_rate cum_rr_local_y_avg_debt_shift tax_rate_debt_shift 
fixed_total_w gdp_growth_rate inflation 
political_risk i.year i.nace2, fe vce(cluster multinational_ID);


outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(rr_local_y_avg tax_rate rr_local_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg leverage cum_ltv_cap_y_avg tax_rate cum_ltv_cap_y_avg_debt_shift tax_rate_debt_shift i.year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "S:\output\Tex\regression_orbis_growth.tex", 
replace keep(rr_local_y_avg tax_rate rr_local_y_avg_debt_shift tax_rate_debt_shift) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr 

#delimit;
xi: xtreg leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w log_sales profitability_w opportunity_w gdp_growth_rate inflation political_risk 
i.year, 
fe vce(cluster multinational_ID);
#delimit cr
#delimit;
outreg2 using "S:\output\Tex\regression_orbis.tex", 
keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w profitability_w opportunity_w gdp_growth_rate inflation political_risk log_sales) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr

xi: xtreg adj_leverage MPI tax_rate MPI_debt_shift tax_rate_debt_shift i.closdate_year, fe vce(cluster multinational_ID)
#delimit;
outreg2 using "\\Client\C$\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
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
outreg2 using "\\Client\C$\Users\User\work\master_thesis\analysis\temp\regression_full.tex", 
keep(MPI tax_rate MPI_debt_shift tax_rate_debt_shift 
fixed_total_w profitability_w opportunity_w gdp_growth_rate inflation political_risk log_sales) 
addtext(Multinational FE, YES, Year FE, YES) label tex(frag) nocons;
#delimit cr




