* Project: Macroprudential Policies and Capital Structure (Master Thesis Tilburg 2017)
* Author: Lucas Avezum 

* This file merges the datasets from Orbis
set more off

//==============================
//===== Sample financials ======
//==============================

use "\input\orbis\financials", clear
set seed 12345
* Sample % of data
sort id
preserve
tempfile tmp
bysort id: keep if _n == 1
sample `2'
sort id
save `tmp'
restore
merge m:1 id using `tmp'
keep if _merge == 3
drop _merge 
sort id year
tempfile tmp1
save `tmp1'

//=================================
//===== Merge links to sampe ======
//=================================

foreach a in 2007 2008 2009 2010 2011 2012 2013 2014 2015{
* Merge
use "\input\orbis\links_`a'", clear
merge 1:1 id year using `tmp1'
drop if _merge == 1
drop _merge
save `tmp1',replace
}

//==========================================
//===== Merge industry data to sample ======
//==========================================

merge m:1 id using "\input\orbis\sector"
drop if _merge == 2
drop _merge

//==================================================
//===== Merge information on listed to sample ======
//==================================================

merge m:1 id using "\input\orbis\listed"
drop if _merge == 2
drop _merge

* Create listed information in time accounting for IPO and delisted dates
replace listed = "Unlisted" if ipo_year>year & !missing(ipo_year)
replace listed = "Listed" if delisted_year>year & !missing(delisted_year)

//===================================
//===== First cleaning of data ======
//===================================

* Drop listed information dates
drop ipo_date ipo_year delisted_year delisted_date 

* Remove financials and utilities firms
keep if type_id == "C"
drop if inlist(nace2,35,36,37,38,39)

* Remove non-positive and missing total asset
drop if missing(toas)
drop if toas == 0
drop if toas < 0

save "\cleaning\temp\merged_`1'", replace

