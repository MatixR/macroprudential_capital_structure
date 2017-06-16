* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create variables of interest
set more off

use "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_WB_PRS_`1'.dta", clear
sort idnr closdate_year
egen firm_id = group(idnr)
order firm_id
xtset firm_id closdate_year

//=================================
//====== Dependent Variables ======
//=================================

* Create financial leverage variable
gen leverage = (ncli+culi)/toas
lab var leverage "Financial leverage"

* Create adjusted financial leverage variable
gen adj_leverage = (ncli+culi-cash)/(toas-cash)
lab var adj_leverage "Adjusted financial leverage"

* Create long term debt leverage variable
gen longterm_debt = (ltdb)/(toas)
lab var longterm_debt "Long term debt"

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

* Create firm size variable - sales
gen log_sales = log(turn)
lab var log_sales "Log of sales"

* Create firm size variable - fixed asset
gen log_fixedasset = log(fias)
lab var log_fixedasset "Log of fixed assets"

* Create profitability variable
gen profitability = ebta/toas
lab var profitability "Profitability"

* Create aggregate profitability variable
sort country nace_prim_code closdate_year
by country nace_prim_code closdate_year: egen total_profit = sum(ebta)
by country nace_prim_code closdate_year: egen total_asset = sum(toas)
gen agg_profitability = total_profit/total_asset
lab var agg_profitability "Aggregate profitability"

* Create auxiliary sales growth variable
sort firm_id closdate_year
gen logturn = log(turn)
gen sales_growth = D.logturn

* Create growth opportunity variable
sort country nace_prim_code closdate_year
by country nace_prim_code closdate_year: egen opportunity = median(sales_growth)
lab var opportunity "Growth opportunities"

* Create risk of firm variable
sort idnr closdate_year
by idnr: egen risk = sd(profitability)
lab var risk "Volatility of profits"

//================================================
//====== Control Variables at Country Level ======
//================================================

* Create inflation variable
sort firm_id closdate_year
gen logcpi = log(cpi)
gen inflation = D.logcpi
lab var inflation "Inflation"

* Create change in exchange rate variable
sort firm_id closdate_year
gen logFX = log(exchrate2)
gen delta_FX = D.logFX
lab var delta_FX "Change in exchange rate"

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

* Labeling remaning controls
* World Bank
lab var gdp_growth_rate "GDP growth rate"
lab var credit_financial_GDP "Finacial sector credit to GDP"
lab var private_credit_GDP "Private credit to GDP"
lab var stock_traded_GDP "Value of stock traded to GDP"
lab var market_cap_GDP "Market capitalization to GDP"
lab var turnover "Turnover ratio of stock traded"
* PRS
lab var economic_risk "Economic risk" 
lab var exchange_rate_risk "Exchange rate risk"
lab var financial_risk "Financial Risk"
lab var political_risk "Political Risk"
lab var law_order "Law and order"


save "C:\Users\User\work\master_thesis\cleaning\temp\dataset_no_debt_shifting_`1'.dta", replace

