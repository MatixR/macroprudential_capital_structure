* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file manipulate raw data to create variables of interest
set more off

use "\cleaning\temp\merged_`1'.dta", clear

sort id year
egen double firms = group(id)

* Set panel format
order firms
xtset firms year

//========================
//====== Indicators ======
//========================

* Create index of balance panel data
bysort firms (year): egen balance_panel = count(year)
bysort firms (year): egen unbalance_panel = min(year)

* Create parent dummy
preserve 
tempfile tmp1
keep id_P year
sort id_P year
by id_P year: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename id_P ID
save `tmp1'
restore
preserve
keep id year
sort id year
rename id ID
tempfile tmp2
merge 1:1 ID year using `tmp1'
keep if _merge == 3
gen parent = 1 
drop _merge
rename ID id
save `tmp2'
restore
merge m:1 id year using `tmp2'
drop _merge
replace parent = 0 if missing(parent)

* Create intermediate dummy
preserve 
tempfile tmp1
keep id_I year
sort id_I year
by id_I year: gen dup = cond(_N==1,0,_n-1)
keep if dup == 0
drop dup
rename id_I ID
save `tmp1'
restore
preserve
keep id year
sort id year
rename id ID
tempfile tmp2
merge 1:1 ID year using `tmp1'
keep if _merge == 3
gen intermediate = 1 
drop _merge
rename ID id
save `tmp2'
restore
merge m:1 id year using `tmp2'
drop _merge
replace intermediate = 0 if missing(intermediate)
replace intermediate = 0 if parent == 1

* Create multinational indicator
replace id_P = id if  missing(id_P)
egen multinationals = group(id_P)

* Create subsidiary per multinational indicator
bysort multinationals id_P id: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinationals (id_P id): gen subsidiary_ID = sum(help1)
drop help1
bysort multinationals: egen mean_subsidiary_ID = mean(subsidiary_ID)

* Create multinational*year indicator
egen double multinational_year = group(id_P year)
egen double country_year = group(country_id year)

* Create movers indicator
bysort id id_P: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort id (id_P): gen subsidiary_multinatinal_ID = sum(help1)
bysort id: egen mover_indicator = mean(subsidiary_multinatinal_ID)
drop help1 subsidiary_multinatinal_ID

* Create own-owner firm dummy
gen owner = 1 if id_P == id
replace owner = 0 if missing(owner)

* Create multinational dummy
bysort multinational_year country_id: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_year (country_id): gen help2 = sum(help1)
bysort multinational_year: egen help3 = mean(help2)
bysort multinational_year: gen multinational = 0 if help3 == 1
replace multinational = 1 if missing(multinational)
drop help1 help2 help3

* Label and changing unit of tax variable
gen help1 = tax_rate/100
replace tax_rate = help1
drop help1

* Create average of asset per firm
bysort id: egen avg_toas = mean(toas)

//=================================
//====== Dependent Variables ======
//=================================

* Create financial leverage variable
gen leverage = (ncli+culi)/toas
replace leverage =. if leverage > 1 | leverage < 0 

* Create adjusted financial leverage variable
gen adj_leverage = (ncli+culi-cash-debtors)/(toas-cash-debtors)
replace adj_leverage =. if adj_leverage > 1 | adj_leverage < 0 

* Create long term debt leverage variable
gen longterm_debt = (ltdb)/(toas)
replace longterm_debt =. if longterm_debt > 1 | longterm_debt < 0 

* Create short term leverage variable
gen loans_leverage = (loans)/(toas)
replace loans_leverage =. if loans_leverage > 1 | loans_leverage < 0 

* Create long- short-term debt leverage variable
gen debt_leverage = (ltdb+loans)/(toas)
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
bysort country_id year multinationals: egen total_profit = total(ebitda)
bysort country_id year multinationals: egen total_asset = total(toas)
gen agg_profitability = total_profit/total_asset
lab var agg_profitability "Aggregate profitability"
drop total_profit total_asset

* Create growth opportunity variable
bysort firms (year): gen sales_growth = D.log_sales if year == year[_n-1]+1
bysort country_id nace year: egen opportunity = median(sales_growth)
lab var opportunity "Growth opportunities"
drop sales_growth

* Create risk of firm variable
bysort firms (year): egen risk = sd(profitability)
lab var risk "Volatility of profits"

//================================================
//====== Control Variables at Country Level ======
//================================================

* Changing GDP per capita to thousands
gen help1 = gdp_per_capita/1000
replace gdp_per_capita = help1
drop help1
lab var gdp_per_capita "GDP per capita"

* Changing variables to GDP to percentage
foreach var in gdp_growth_rate private_credit_GDP {
gen help1 = `var'/100
replace `var' = help1
drop help1
}
//========================================
//====== Create index = 100 at 2007 ======
//========================================
sort firms year
#delimit;
local vars1 "private_credit_GDP political_risk exchange_rate_risk law_order 
            interest_rate tax_rate gdp_per_capita
            debt_leverage leverage adj_leverage longterm_debt loans_leverage 
            fixed_total tangible_total log_fixedasset log_sales 
			profitability agg_profitability";
#delimit cr
 foreach var of local vars1{
 bysort firms (year): gen `var'_i = `var'/`var'[1]
 }
 
//=====================================
//====== Create average variable ======
//=====================================
#delimit;
local vars2 "private_credit_GDP political_risk exchange_rate_risk law_order 
            interest_rate tax_rate gdp_per_capita inflation gdp_growth_rate
            debt_leverage leverage adj_leverage longterm_debt loans_leverage 
            fixed_total tangible_total log_fixedasset log_sales 
			profitability agg_profitability opportunity";
#delimit cr
foreach var of local vars2{
 bysort firms (year): egen `var'_a = mean(`var')
 }
 
//===============================
//====== Cleaning outliers ======
//===============================
* Index variables
#delimit;
local vars3 "debt_leverage leverage adj_leverage longterm_debt loans_leverage 
             fixed_total tangible_total log_fixedasset log_sales 
			 profitability agg_profitability";
#delimit cr

foreach var of local vars3{
winsor `var'_i , gen(`var'_w) p(0.01)
}
foreach var of varlist risk opportunity{
winsor `var' , gen(`var'_w) p(0.01)
}
* Averaged variables
#delimit;
local vars4 "debt_leverage leverage adj_leverage longterm_debt loans_leverage 
             fixed_total tangible_total log_fixedasset log_sales 
			 profitability agg_profitability opportunity";
#delimit cr
foreach var of local vars4{
winsor `var'_a , gen(`var'_a_w) p(0.01)
}

//=======================================
//====== Interaction term with tax ======
//=======================================

foreach var of varlist c_rr_local_y  c_cap_req_y cap_str ovr_str int_str{
gen tax_`var'= `var'*tax_rate_i 
gen vol_`var'= `var'*risk_w
gen taxvol_`var'= `var'*risk_w*tax_rate_i
}
foreach var of varlist cap_str ovr_str int_str{
gen tax_`var'_a= `var'*tax_rate_a 
gen taxvol_`var'_a= `var'*risk_w*tax_rate_a
}

//=============================
//====== Label variables ======
//=============================

* Dependent variables
lab var leverage "Financial leverage"
lab var adj_leverage "Adjusted financial leverage"
lab var longterm_debt "Long term debt"
lab var loans_leverage "Short term debt"
lab var debt_leverage "Debt leverage"

lab var leverage_w "Financial leverage"
lab var adj_leverage_w "Adjusted financial leverage"
lab var longterm_debt_w "Long term debt"
lab var loans_leverage_w "Short term debt"
lab var debt_leverage_w "Debt leverage"

lab var leverage_a_w "Financial leverage"
lab var adj_leverage_a_w "Adjusted financial leverage"
lab var longterm_debt_a_w "Long term debt"
lab var loans_leverage_a_w "Short term debt"
lab var debt_leverage_a_w "Debt leverage"

* Independent variables
lab var fixed_total "Tangibility"
lab var profitability "Profitability"
lab var tangible_total "Adjusted tangibility"
lab var opportunity "Opportunity"
lab var agg_profitability "Aggregate profitability"
lab var risk "Risk"
lab var log_fixedasset "Log of fixed assets"
lab var log_sales "Log of sales"

lab var fixed_total_w "Tangibility"
lab var profitability_w "Profitability"
lab var tangible_total_w "Adjusted tangibility"
lab var opportunity_w "Opportunity"
lab var agg_profitability_w "Aggregate profitability"
lab var risk_w "Risk"
lab var log_fixedasset_w "Log of fixed assets"
lab var log_sales_w "Log of sales"

lab var fixed_total_a_w "Tangibility"
lab var profitability_a_w "Profitability"
lab var tangible_total_a_w "Adjusted tangibility"
lab var opportunity_a_w "Opportunity"
lab var agg_profitability_a_w "Aggregate profitability"
lab var log_fixedasset_a_w "Log of fixed assets"
lab var log_sales_a_w "Log of sales"

* Macroprudential indexes
* IBRN
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
* Barth et al 2008
lab var cap_str "Overall capital strigency"
lab var ovr_str "Initial capital stringency"
lab var int_str "Capital regulatory index"

* Tax macroprudential interaction variables
foreach var of varlist c_rr_local_y  c_cap_req_y cap_str ovr_str int_str{
lab var tax_`var' "`: var label `var''*tax"
lab var vol_`var' "`: var label `var''*risk"
lab var taxvol_`var' "`: var label `var''*risk*tax"
}
foreach var of varlist cap_str ovr_str int_str{
lab var tax_`var'_a "`: var label `var''*tax"
lab var taxvol_`var'_a "`: var label `var''*risk*tax"
}
* World Bank
lab var gdp_per_capita "GDP per capita"
lab var private_credit_GDP "Private credit to GDP"
lab var interest_rate "Policy rate"
lab var tax_rate "Tax rate"

lab var gdp_growth_rate "GDP growth rate"
lab var inflation "Inflation rate"
lab var gdp_per_capita_i "GDP per capita"
lab var private_credit_GDP_i "Private credit to GDP"
lab var interest_rate_i "Policy rate"
lab var tax_rate_i "Tax rate"

lab var gdp_growth_rate_a "GDP growth rate"
lab var inflation_a "Inflation rate"
lab var gdp_per_capita_a "GDP per capita"
lab var private_credit_GDP_a "Private credit to GDP"
lab var interest_rate_a "Policy rate"
lab var tax_rate_a "Tax rate"

* PRS
lab var exchange_rate_risk "Exchange rate risk"
lab var political_risk "Political Risk"
lab var law_order "Law and order"

lab var exchange_rate_risk_i "Exchange rate risk"
lab var political_risk_i "Political Risk"
lab var law_order_i "Law and order"

lab var exchange_rate_risk_a "Exchange rate risk"
lab var political_risk_a "Political Risk"
lab var law_order_a "Law and order"

* Other remaining labeling
lab var parent "Parent"
lab var intermediate "Intermediate"

//==========================
//====== Save dataset ======
//==========================

save "\cleaning\output\dataset_`1'.dta", replace
