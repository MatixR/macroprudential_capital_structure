* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file manipulate raw data to create variables of interest
set more off

use "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI_control_`1'.dta", clear
sort idnr closdate_year
egen firm_id = group(idnr)
order firm_id
xtset firm_id closdate_year

//=================================
//====== Dependent Variables ======
//=================================

* Create financial leverage variable
gen leverage = (ncli+culi)/toas

* Create adjusted financial leverage variable
gen adj_leverage = (ncli+culi-cash)/(toas-cash)

* Create long term debt leverage variable
gen longterm_debt = (ltdb)/(toas)

* Create adjusted long term debt leverage variable
gen adj_longterm_debt = (ltdb-cash)/(toas-cash)

//===============================
//====== Control Variables ======
//===============================

* Create tangibility variable - fixed asset
gen fixed_total = fias/toas

* Create tangibility variable - tangible fixed asset
gen tangible_total = tfas/toas

* Create firm size variable - sales
gen log_sales = log(turn)

* Create firm size variable - fixed asset
gen log_fixedasset = log(fias)

* Create profitability variable
gen profitability = ebta/toas

* Create aggregate profitability variable
sort country nace_prim_code closdate_year
by country nace_prim_code closdate_year: egen total_profit = sum(ebta)
by country nace_prim_code closdate_year: egen total_asset = sum(toas)
gen agg_profitability = total_profit/total_asset

* Create auxiliary sales growth variable
sort firm_id closdate_year
gen logturn = log(turn)
gen sales_growth = D.logturn

* Create growth opportunity variable
sort country nace_prim_code closdate_year
by country nace_prim_code closdate_year: egen opportunity = median(sales_growth)

* Create risk of firm variable
sort idnr closdate_year
by idnr: egen risk = sd(ebta)

save "C:\Users\User\work\master_thesis\cleaning\temp\dataset_no_debt_shifting_`1'.dta", replace

