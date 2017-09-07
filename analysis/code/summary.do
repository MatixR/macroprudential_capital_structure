* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates summary statistics
cd "S:"
use "\cleaning\output\dataset_orbis100_2.dta", clear

//===================================
//====== Basic Summary tables =======
//===================================
 
set more off

keep if unbalance_panel == 2007 & multinational ==1
#delimit;
drop if missing(leverage_w,fixed_total_w, 
log_fixedasset_w, profitability_w, opportunity_w, risk_w);
#delimit cr
* Raw summary table of variables per firm
#delimit;
estpost tabstat leverage_w  c_rr_local_y c_cap_req_y tax_rate
c_rr_local_y_ds c_cap_req_y_ds tax_rate_ds 
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
