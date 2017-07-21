* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create variables of interest
set more off

use "\cleaning\temp\merged_MPI_WB_DS_`1'.dta", clear
sort id year
egen firm_id = group(id)
order firm_id
xtset firm_id year

//=================================
//====== Dependent Variables ======
//=================================

* Create financial leverage variable
gen leverage = (ncli+culi)/toas
lab var leverage "Financial leverage"

* Create financial leverage growth
gen log_leverage = log(leverage)
bysort firm_id (year): gen leverage_g = D.log_leverage if year == year[_n-1]+1
lab var leverage_g "Leverage growth rate"
drop log_leverage

* Create adjusted financial leverage variable
gen adj_leverage = (ncli+culi-cash)/(toas-cash)
lab var adj_leverage "Adjusted financial leverage"

* Create adjusted financial leverage growth
gen log_adj_leverage = log(adj_leverage)
bysort firm_id (year): gen adj_leverage_g = D.log_adj_leverage if year == year[_n-1]+1
lab var adj_leverage_g "Adjusted leverage growth rate"
drop log_adj_leverage

* Create long term debt leverage variable
gen longterm_debt = (ltdb)/(toas)
lab var longterm_debt "Long term debt"

* Create long term debt growth
gen log_longterm_debt = log(longterm_debt)
bysort firm_id (year): gen longterm_debt_g = D.log_longterm_debt if year == year[_n-1]+1
lab var longterm_debt_g "Long term debt growth rate"
drop log_longterm_debt

* Create loans leverage variable
gen loans_leverage = (loans)/(toas)
lab var loans_leverage "Short term debt"

* Create loans growth
gen log_loans = log(loans_leverage)
bysort firm_id (year): gen loans_g = D.log_loans if year == year[_n-1]+1
lab var loans_g "Loans growth rate"
drop log_loans

* Create adjusted long term debt leverage variable
gen adj_longterm_debt = (ltdb-cash)/(toas-cash)
lab var adj_longterm_deb "Adjusted long term debt"

//=============================================
//====== Control Variables at Firm Level ======
//=============================================

* Create tangibility variable - fixed asset
gen fixed_total = fias/toas
lab var fixed_total "Tangibility"

* Create tangibility variable - tangible fixed asset
gen tangible_total = tfas/toas
lab var tangible_total "Adjusted tangibility"

* Create intangibility variable - intangible asset
gen intangible_total = ifas/toas
lab var intangible_total "Intangibility"

* Create firm size variable - sales
gen log_sales = log(sales)
lab var log_sales "Log of sales"

* Create firm size variable - fixed asset
gen log_fixedasset = log(fias)
lab var log_fixedasset "Log of fixed assets"

* Create profitability variable
gen profitability = ebitda/toas
lab var profitability "Profitability"

* Create aggregate profitability variable
bysort country_id nace year: egen total_profit = total(ebitda)
bysort country_id nace year: egen total_asset = total(toas)
gen agg_profitability = total_profit/total_asset
lab var agg_profitability "Aggregate profitability"
drop total_profit total_asset

* Create growth opportunity variable
bysort firm_id (year): gen sales_growth = D.log_sales if year == year[_n-1]+1
bysort country_id nace year: egen opportunity = median(sales_growth)
lab var opportunity "Growth opportunities"
drop sales_growth

* Create risk of firm variable
bysort firm_id (year): egen risk = sd(profitability)
lab var risk "Volatility of profits"

//================================================
//====== Control Variables at Country Level ======
//================================================

* Create change in exchange rate variable
gen logFX = log(exchrate)
bysort firm_id (year): gen delta_FX = D.logFX if year == year[_n-1]+1
lab var delta_FX "Change in exchange rate"
drop logFX

* Changing GDP per capita to thousands
gen help1 = gdp_per_capita/1000
replace gdp_per_capita = help1
drop help1
lab var gdp_per_capita "GDP per capita"

* Changing variables to GDP to percentage
foreach a in gdp_growth_rate  credit_financial_GDP private_credit_GDP stock_traded_GDP market_cap_GDP turnover {
gen help1 = `a'/100
replace `a' = help1
drop help1
}

//===============================
//====== Cleaning outliers ======
//===============================

* Dependent variables
winsor leverage, gen(leverage_w) p(0.01)
lab var leverage_w "Financial leverage"
winsor adj_leverage, gen(adj_leverage_w) p(0.01)
lab var adj_leverage_w "Adjusted financial leverage"
winsor longterm_debt, gen(longterm_debt_w) p(0.01)
lab var longterm_debt_w "Long term debt"
winsor loans_leverage, gen(loans_leverage_w) p(0.01)
lab var loans_leverage_w "Short term debt"

* Independent variables
winsor fixed_total, gen(fixed_total_w) p(0.01)
lab var fixed_total_w "Tangibility"
winsor profitability, gen(profitability_w) p(0.01)
lab var profitability_w "Profitability"
winsor tangible_total, gen(tangible_total_w) p(0.01)
lab var tangible_total_w "Adjusted tangibility"
winsor intangible_total, gen(intangible_total_w) p(0.01)
lab var intangible_total_w "Intangibility"
winsor opportunity, gen(opportunity_w) p(0.01)
lab var opportunity_w "Opportunity"
winsor agg_profitability, gen(agg_profitability_w) p(0.01)
lab var agg_profitability_w "Aggregate profitability"
winsor risk, gen(risk_w) p(0.01)
lab var risk_w "Volatility of profits"
winsor log_fixedasset, gen(log_fixedasset_w) p(0.01)
lab var log_fixedasset_w "Log of fixed assets"
winsor log_sales, gen(log_sales_w) p(0.01)
lab var log_sales_w "Log of sales"

//================================
//====== Labeling variables ======
//================================

* Rename multinational ID and debt shift groups to look nice in table
rename multinational_ID multinationals

* Macroprudential indexes
lab var BORROWER "Borrower target index"
lab var FINANCIAL "Financial target index"

lab var cum_sscb_res_y "Capital buffer - real estate"
lab var cum_sscb_cons_y "Capital buffer - consumers" 
lab var cum_sscb_oth_y "Capital buffer - others" 
lab var cum_sscb_y "Capital buffer - overall" 
lab var cum_cap_req_y "Capital requirement" 
lab var cum_concrat_y "Concentration limit"
lab var cum_ibex_y "Interbank exposure limit"
lab var cum_ltv_cap_y "LTV ratio limits" 
lab var cum_rr_foreign_y "Reserve req. on foreign currency"
lab var cum_rr_local_y "Reserve req. on local currency"

foreach var of varlist cum_*_y{
lab var l1_`var' "`: var label `var'' (-1)"
lab var l2_`var' "`: var label `var'' (-2)"
lab var l3_`var' "`: var label `var'' (-3)"
lab var l4_`var' "`: var label `var'' (-4)"
}
* Debt shift variables
lab var tax_rate_ds "Tax rate spillover"
lab var tax_rate_ds_s "Tax rate spillover to other subsidiaries" 
lab var tax_rate_ds_p "Tax rate spillover to parent" 
 
foreach var of varlist cum_*_y{
lab var `var'_ds "`: var label `var'' spillover"
lab var `var'_ds_p "`: var label `var'' spillover to parent"
lab var `var'_ds_s "`: var label `var'' spillover to other subsidiaries"
}
foreach var of varlist cum_*_ds{
lab var l1_`var' "`: var label `var'' (-1)"
lab var l2_`var' "`: var label `var'' (-2)"
lab var l3_`var' "`: var label `var'' (-3)"
lab var l4_`var' "`: var label `var'' (-4)"
}
foreach var of varlist cum_*_ds_p{
lab var l1_`var' "`: var label `var'' (-1)"
lab var l2_`var' "`: var label `var'' (-2)"
lab var l3_`var' "`: var label `var'' (-3)"
lab var l4_`var' "`: var label `var'' (-4)"
}
foreach var of varlist cum_*_ds_s{
lab var l1_`var' "`: var label `var'' (-1)"
lab var l2_`var' "`: var label `var'' (-2)"
lab var l3_`var' "`: var label `var'' (-3)"
lab var l4_`var' "`: var label `var'' (-4)"
}
* World Bank
lab var gdp_growth_rate "GDP growth rate"
lab var credit_financial_GDP "Finacial sector credit to GDP"
lab var private_credit_GDP "Private credit to GDP"
lab var stock_traded_GDP "Value of stock traded to GDP"
lab var market_cap_GDP "Market capitalization to GDP"
lab var turnover "Turnover ratio of stock traded"
lab var interest_rate "Policy rate"

* PRS
lab var economic_risk "Economic risk" 
lab var exchange_rate_risk "Exchange rate risk"
lab var financial_risk "Financial Risk"
lab var political_risk "Political Risk"
lab var law_order "Law and order"

* Other remaining labeling
lab var parent "Parent"
lab var intermediate "Intermediate"
lab var tax_rate "Tax rate"

save "\cleaning\output\dataset_`1'.dta", replace
*saveold "\\Client\C$\Users\User\work\master_thesis\analysis\input\orbis_multinationals.dta", version(13) replace


