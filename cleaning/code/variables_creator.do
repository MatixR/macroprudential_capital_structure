//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file manipulate raw data to create variables of interest //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
if "`c(hostname)'" != "EG3523" {
global STATAPATH "S:"
}
else if "`c(hostname)'" == "EG3523" {
global STATAPATH "C:/Users/u1273941/Research/Projects/macroprudential_capital_structure"
}
cd "$STATAPATH"          
set more off

* Particular
ssc install winsor            // install winsor package
use "cleaning/temp/merged_`1'.dta", clear
sort id year
egen double firms = group(id) // Create numeric ID
order firms
xtset firms year              // Set panel format

//============================================================================//
// Create indicators                                                          //
//============================================================================//

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

* Create fixed-effects indicators
egen double multinational_year = group(id_P year)
egen double country_year = group(country_id year)
egen double countries = group(country_id)

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

* Keep only multinationals
keep if multinational == 1

* Change unit of tax variable
gen help1 = tax_rate/100
replace tax_rate = help1
drop help1

* Create average of asset per firm
bysort id: egen avg_toas = mean(toas)

* Replace barth variable from 2011 survey in years 2008, 2009 and 2010
gen tag = 1 if year == 2008 | year == 2009 | year == 2010
foreach var of varlist b_*{
bysort id: egen avg_`var' = mean(`var') if year != 2007
replace `var' = avg_`var' if tag==1
drop avg_`var'
}
drop tag

//============================================================================//
// Create dependent variables                                                 //
//============================================================================//

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

//============================================================================//
// Create control variables at firm level                                     //
//============================================================================//

* Create tangibility variable - fixed asset
gen fixed_total = fias/toas

* Create tangibility variable - tangible fixed asset
gen tangible_total = tfas/toas

* Create intangibility variable - intangible asset
gen intangible_total = ifas/toas

* Create firm size variable - sales
gen log_sales = log(sales)

* Create firm size variable - fixed asset
gen log_fixedasset = log(fias)

* Create profitability variable
gen profitability = ebitda/toas

* Create aggregate profitability variable
bysort country_id year multinationals: egen total_profit = total(ebitda)
bysort country_id year multinationals: egen total_asset = total(toas)
gen agg_profitability = total_profit/total_asset
drop total_profit total_asset

* Create growth opportunity variable
bysort firms (year): gen sales_growth = D.log_sales if year == year[_n-1]+1
bysort firms (year): replace sales_growth = log_sales[1]-log_sales[2] if year == 2007
bysort country_id nace year: egen opportunity = median(sales_growth)
drop sales_growth

* Create risk of firm variable
bysort firms (year): egen risk = sd(profitability)

//============================================================================//
// Create control variables at country level                                  //
//============================================================================//

* Change GDP per capita to thousands
gen help1 = gdp_per_capita/1000
replace gdp_per_capita = help1
drop help1
lab var gdp_per_capita "GDP per capita"

* Change variables to GDP to percentage
foreach var in gdp_growth_rate private_credit_GDP {
gen help1 = `var'/100
replace `var' = help1
drop help1
}

//============================================================================//
// Clean outliers                                                             //
//============================================================================//

#delimit;
local vars "debt_leverage leverage adj_leverage longterm_debt loans_leverage 
            fixed_total tangible_total log_fixedasset log_sales 
			profitability agg_profitability risk opportunity";
#delimit cr
foreach var of local vars{
winsor `var', gen(`var'_w) p(0.01)
}

//============================================================================//
// Label variables                                                            //
//============================================================================//

* Dependent variables
lab var leverage       "Financial leverage"
lab var adj_leverage   "Adjusted financial leverage"
lab var longterm_debt  "Long term debt"
lab var loans_leverage "Short term debt"
lab var debt_leverage  "Debt leverage"

* Independent variables
lab var fixed_total_w       "Tangibility"
lab var profitability_w     "Profitability"
lab var tangible_total_w    "Adjusted tangibility"
lab var opportunity_w       "Opportunity"
lab var agg_profitability_w "Aggregate profitability"
lab var risk_w              "Risk"
lab var log_fixedasset_w    "Log of fixed assets"
lab var log_sales_w         "Log of sales"

* Bank Regulation Survey
lab var b_ovr_rest "Restrictions on banking activities"
lab var b_ovr_cong "Financial conglomerates restrictiveness"
lab var b_lim_for  "Limitations on foreign bank"
lab var b_frac_den "Entry applications denied"
lab var b_cap_str  "Capital regulatory index"
lab var b_ovr_str  "Overall capital strigency"
lab var b_int_str  "Initial capital stringency"
lab var b_off_sup  "Official supervisory power"
lab var b_pri_mon  "Private Monitoring"
lab var b_mor_haz  "Moral hazard"
lab var b_conc_dep "Bank concentration in deposits"
lab var b_conc_ass "Bank concentration in assets"
lab var b_for_sha  "Foreign-owned banks"
lab var b_gov_sha  "Government-owned banks"

* World Bank
lab var gdp_per_capita     "GDP per capita"
lab var private_credit_GDP "Private credit to GDP"
lab var interest_rate      "Policy rate"
lab var tax_rate           "Tax rate"
lab var gdp_growth_rate    "GDP growth rate"
lab var inflation          "Inflation rate"

* PRS
lab var exchange_rate_risk "Exchange rate risk"
lab var political_risk     "Political Risk"
lab var law_order          "Law and order"

* Other remaining labeling
lab var parent       "Parent"
lab var intermediate "Intermediate"

//============================================================================//
// Save dataset                                                               //
//============================================================================//

save "cleaning/output/dataset_`1'.dta", replace
