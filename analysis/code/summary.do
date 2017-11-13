* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics
cd "S:"
use "\cleaning\output\dataset_orbis.dta", clear

//===================================
//====== Basic Summary tables =======
//===================================
 
set more off
* Summary table of variables for IBRN data analysis
keep if unbalance_panel == 2007 & multinational ==1 
#delimit;
drop if missing(leverage_i_w,fixed_total_i_w, 
log_fixedasset_i_w, profitability_i_w, opportunity_w, risk_w);
drop if missing(inflation, gdp_growth_rate, private_credit_GDP_i, 
political_risk_i, exchange_rate_risk_i, law_order_i);
#delimit cr
#delimit;
estpost tabstat leverage_i_w 
c_rr_local_y c_cap_req_y tax_rate_i
c_rr_local_y_ds c_cap_req_y_ds tax_rate_i_ds 
fixed_total_i_w log_fixedasset_i_w profitability_i_w opportunity_w risk_w
inflation gdp_growth_rate private_credit_GDP_i interest_rate_i
political_risk_i exchange_rate_risk_i law_order_i,
statistics(count mean sd min p50 max) columns(statistics); 
#delimit cr
#delimit;
esttab using "\analysis\output\tables\summary\summary_firms_index07.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

set more off
* Summary table of variables for IBRN data analysis base year 2008
use "\cleaning\output\dataset_orbis.dta", clear
keep if multinational ==1 & year != 2008
#delimit;
drop if missing(leverage_i2_w,fixed_total_i2_w, 
log_fixedasset_i2_w, profitability_i2_w, opportunity_w, risk_w);
drop if missing(inflation_i2, gdp_growth_rate_i2, private_credit_GDP_i2, 
political_risk_i2, exchange_rate_risk_i2, law_order_i2);
#delimit cr
#delimit;
estpost tabstat leverage_i2_w 
c_rr_local_y_i2 c_cap_req_y_i2 tax_rate_i2
c_rr_local_y_i2_ds c_cap_req_y_i2_ds tax_rate_i2_ds 
fixed_total_i2_w log_fixedasset_i2_w profitability_i2_w opportunity_w risk_w
inflation gdp_growth_rate private_credit_GDP_i2 interest_rate_i2
political_risk_i2 exchange_rate_risk_i2 law_order_i2,
statistics(count mean sd min p50 max) columns(statistics); 
#delimit cr
#delimit;
esttab using "\analysis\output\tables\summary\summary_firms_index08.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

* Summary table of average variables for Barth data analysis
use "\cleaning\output\dataset_orbis_barth.dta", clear
set more off
#delimit;
drop if missing(leverage,fixed_total_w,
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
drop if missing(inflation, gdp_growth_rate, private_credit_GDP, 
political_risk, exchange_rate_risk, law_order);
#delimit cr
#delimit;
estpost tabstat leverage  
b_ovr_rest b_lim_for b_frac_den  
b_int_str b_off_sup tax_rate
b_ovr_rest_ds b_lim_for_ds b_frac_den_ds 
b_int_str_ds b_off_sup_ds tax_rate_ds
fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w
inflation gdp_growth_rate private_credit_GDP interest_rate
political_risk exchange_rate_risk law_order, 
statistics(count mean sd min p50 max) columns(statistics); 
#delimit cr
#delimit;
esttab using "\analysis\output\tables\summary\summary_firms_barth.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

* Summary table of variables for Barth data analysis 
use "\cleaning\output\dataset_orbis.dta", clear
set more off
keep if multinational ==1 
keep if year == 2011 | year == 2007
#delimit;
drop if missing(leverage,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr
#delimit;
estpost tabstat leverage adj_leverage debt_leverage longterm_debt loans_leverage 
 cap_str ovr_str int_str tax_rate
cap_str_ds ovr_str_ds int_str_ds tax_rate_i_ds
fixed_total_w log_fixedasset_w profitability_w opportunity_w risk_w
inflation gdp_growth_rate private_credit_GDP interest_rate
political_risk exchange_rate_risk law_order, 
statistics(count mean sd min max) columns(statistics); 
#delimit cr
#delimit;
esttab using "\analysis\output\tables\summary\summary_firms.tex",
replace cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") label noobs nonumbers 
title("Summary statistics of firm level variables");
#delimit cr

//===================================================
//====== Number of firms per country per type =======
//===================================================

* Parent firms and subsidiary by host country collumns
bysort id: keep if _n == 1

estpost tab country parent 
#delimit;
esttab using "\analysis\output\tables\summary\number_firms_orbis_1.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr

* Parent firms and subsidiary by host country collumns
use "\cleaning\output\dataset_orbis100_2.dta", clear
keep if unbalance_panel == 2007 & multinational ==1
#delimit;
drop if missing(leverage_w,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr

egen firm_parent_ID = group(id id_P)
bysort firm_parent_ID: keep if _n == 1
estpost tab country_id_P 

#delimit;
esttab using "\analysis\output\tables\summary\number_firms_orbis_2.csv", 
cell(b) unstack noobs fragment replace; 
#delimit cr
* Obs: final table merged by hand

* Movers
bysort id: gen dup = cond(_N==1,1,_n)
drop if dup==1
rename dup Movers
estpost tab Movers
#delimit;
esttab using "\analysis\output\tables\summary\movers.tex", 
cell(b) noobs fragment replace; 
#delimit cr
