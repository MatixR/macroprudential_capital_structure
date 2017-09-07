* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create variables of interest
set more off

use "\cleaning\temp\merged_MPI_WB_DS_`1'.dta", clear
*use "\cleaning\temp\merged_MPI_WB_DS_orbis100_2.dta", clear

sort id year
egen firm_id = group(id)

//===========================
//====== Preliminaries ======
//===========================
* Drop observations with negative values in balance sheet
drop if cash<0 | ncli<0 | culi<0 | fias<0 | tfas<0 | ltdb<0 | loans<0 | sales<0 

* Create index of balance panel data
bysort firm_id (year): egen balance_panel = count(year)
bysort firm_id (year): egen unbalance_panel = min(year)

* Observation weights (number of firms in country)
sort country_id id 
egen tag = tag(country_id id)
bysort country_id: egen n_firm_country = total(tag)

* Drop firm in countrys with less than 25 firms
drop if n_firm_country<25

* Set panel format
order firm_id
xtset firm_id year

//=================================
//====== Dependent Variables ======
//=================================

* Create financial leverage variable
gen leverage = (ncli+culi)/toas
lab var leverage "Financial leverage"
replace leverage =. if leverage > 1 | leverage < 0 

* Create financial leverage growth
gen log_leverage = log(leverage)
bysort firm_id (year): gen leverage_g = D.log_leverage if year == year[_n-1]+1
lab var leverage_g "Leverage growth rate"
drop log_leverage

* Create liabilities growth
gen log_liability = log(ncli+culi)
bysort firm_id (year): gen liability_g = D.log_liability if year == year[_n-1]+1
lab var leverage_g "Liabilities growth rate"
drop log_liability

* Create adjusted financial leverage variable
gen adj_leverage = (ncli+culi-cash)/(toas-cash)
lab var adj_leverage "Adjusted financial leverage"
replace adj_leverage =. if adj_leverage > 1 | adj_leverage < 0 

* Create adjusted financial leverage growth
gen log_adj_leverage = log(adj_leverage)
bysort firm_id (year): gen adj_leverage_g = D.log_adj_leverage if year == year[_n-1]+1
lab var adj_leverage_g "Adjusted leverage growth rate"
drop log_adj_leverage

* Create long term debt leverage variable
gen longterm_debt = (ltdb)/(toas)
lab var longterm_debt "Long-term debt"
replace longterm_debt =. if longterm_debt > 1 | longterm_debt < 0 

* Create long term debt growth
gen log_longterm_debt = log(longterm_debt)
bysort firm_id (year): gen longterm_debt_g = D.log_longterm_debt if year == year[_n-1]+1
lab var longterm_debt_g "Long-term debt growth rate"
drop log_longterm_debt

* Create loans leverage variable
gen loans_leverage = (loans)/(toas)
lab var loans_leverage "Short-term debt"
replace loans_leverage =. if loans_leverage > 1 | loans_leverage < 0 

* Create loans growth
gen log_loans = log(loans_leverage)
bysort firm_id (year): gen loans_g = D.log_loans if year == year[_n-1]+1
lab var loans_g "Short-term growth rate"
drop log_loans

* Create long- short-term debt leverage variable
gen debt_leverage = (ltdb+loans)/(toas)
lab var debt_leverage "Long- short-term leverage"
replace debt_leverage =. if debt_leverage > 1 | debt_leverage < 0 

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
bysort country_id year multinational_ID: egen total_profit = total(ebitda)
bysort country_id year multinational_ID: egen total_asset = total(toas)
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
foreach var in gdp_growth_rate  credit_financial_GDP private_credit_GDP stock_traded_GDP market_cap_GDP turnover {
gen help1 = `var'/100
replace `var' = help1
drop help1
}
//========================================
//====== Create index = 100 at 2007 ======
//========================================
sort firm_id year
#delimit;
local vars "private_credit_GDP market_cap_GDP political_risk exchange_rate_risk law_order 
            interest_rate tax_rate gdp_per_capita
            debt_leverage leverage adj_leverage longterm_debt loans_leverage 
            fixed_total tangible_total log_fixedasset log_sales 
			profitability agg_profitability";
#delimit cr
 foreach var of local vars{
 bysort firm_id (year): gen `var'_i = `var'/`var'[1]
replace `var'=`var'_i 
drop `var'_i
 }

//===============================
//====== Cleaning outliers ======
//===============================

* Dependent variables
winsor leverage, gen(leverage_w) p(0.01)
lab var leverage_w "Financial leverage"
winsor leverage_g, gen(leverage_g_w) p(0.01)
lab var leverage_g_w "Financial leverage growth rate"
winsor liability_g, gen(liability_g_w) p(0.01)
lab var liability_g_w "Liability growth rate"
winsor adj_leverage, gen(adj_leverage_w) p(0.01)
lab var adj_leverage_w "Adjusted financial leverage"
winsor longterm_debt, gen(longterm_debt_w) p(0.05)
lab var longterm_debt_w "Long term debt"
winsor loans_leverage, gen(loans_leverage_w) p(0.05)
lab var loans_leverage_w "Short term debt"
winsor debt_leverage, gen(debt_leverage_w) p(0.05)
lab var debt_leverage_w "Debt leverage"

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
lab var risk_w "Risk"
winsor log_fixedasset, gen(log_fixedasset_w) p(0.01)
lab var log_fixedasset_w "Log of fixed assets"
winsor log_sales, gen(log_sales_w) p(0.01)
lab var log_sales_w "Log of sales"

 //=======================================
//====== Interaction term with tax ======
//=======================================

foreach var of varlist `2'{
gen int_`var'= `var'*tax_rate 
gen vol_`var'= `var'*risk_w
}

//=============================
//====== Label variables ======
//=============================

* Rename multinational ID and debt shift groups to look nice in table
rename multinational_ID multinationals
rename firm_id firms
* Macroprudential indexes
lab var BORROWER "Borrower target index"
lab var FINANCIAL "Financial target index"

lab var sscb_res_y "Capital buffer - real estate"
lab var sscb_cons_y "Capital buffer - consumers" 
lab var sscb_oth_y "Capital buffer - others" 
lab var sscb_y "Capital buffer - overall" 
lab var cap_req_y "Capital requirement" 
lab var concrat_y "Concentration limit"
lab var ibex_y "Interbank exposure limit"
lab var ltv_cap_y "LTV ratio limits" 
lab var rr_foreign_y "Reserve req. on foreign currency"
lab var rr_local_y "Reserve req. on local currency"

lab var c_sscb_res_y "Capital buffer - real estate"
lab var c_sscb_cons_y "Capital buffer - consumers" 
lab var c_sscb_oth_y "Capital buffer - others" 
lab var c_sscb_y "Capital buffer - overall" 
lab var c_cap_req_y "Capital requirement" 
lab var c_concrat_y "Concentration limit"
lab var c_ibex_y "Interbank exposure limit"
lab var c_ltv_cap_y "LTV ratio limits" 
lab var c_rr_foreign_y "Reserve req. on foreign currency"
lab var c_rr_local_y "Reserve req. on local currency"

foreach var of varlist c_*_y{
lab var l4_`var' "`: var label `var'' (-4)"
}

foreach var of varlist *_y{
cap lab var t_`var' "`: var label `var'' (tightening)"
cap lab var l_`var' "`: var label `var'' (loosening)"
}

* Debt shift variables
lab var tax_rate_ds "Tax rate spillover"
lab var tax_rate_ds_s "Tax rate spillover to other subsidiaries" 
lab var tax_rate_ds_p "Tax rate spillover to parent" 
 
foreach var of varlist c_*_y{
lab var `var'_ds "`: var label `var'' spillover"
lab var `var'_ds_p "`: var label `var'' spillover to parent"
lab var `var'_ds_s "`: var label `var'' spillover to other subsidiaries"
}
foreach var of varlist c_*_ds{
lab var l4_`var' "`: var label `var'' (-4)"
}
foreach var of varlist c_*_ds_p{
lab var l4_`var' "`: var label `var'' (-4)"
}
foreach var of varlist c_*_ds_s{
lab var l4_`var' "`: var label `var'' (-4)"
}

* Tax macroprudential interaction variables
foreach var of varlist c_*_y{
lab var int_`var' "`: var label `var''*tax"
lab var vol_`var' "`: var label `var''*risk"
}
* World Bank
lab var gdp_growth_rate "GDP growth rate"
lab var credit_financial_GDP "Finacial sector credit to GDP"
lab var private_credit_GDP "Private credit to GDP"
lab var stock_traded_GDP "Value of stock traded to GDP"
lab var market_cap_GDP "Market capitalization"
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

//=====================================
//====== Drop variables not used ======
//=====================================

drop MPI-TAX 
drop *l4_* t_* l_* *_t_* *_l_* *_l4_*
drop if year == 2007

//========================================
//====== Create fixed effect groups ======
//========================================

egen double multinational_year = group(id_P year)
egen double country_year = group(country_id year)

bysort id id_P: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort id (id_P): gen subsidiary_multinatinal_ID = sum(help1)
bysort id: egen mover_indicator = mean(subsidiary_multinatinal_ID)
drop help1 subsidiary_multinatinal_ID

foreach var of varlist *_ds{
replace `var'_s=`var' if missing(`var'_s) 
replace `var'_p=0 if missing(`var'_p)
}

save "\cleaning\output\dataset_`1'.dta", replace
*saveold "\\Client\C$\Users\User\work\master_thesis\analysis\input\orbis_multinationals.dta", version(13) replace



