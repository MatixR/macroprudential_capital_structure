* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges the datasets from Orbis
set more off

//================================
//===== Sampling financials ======
//================================

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
drop _merge numberofmonths
sort id year
tempfile tmp1
save `tmp1'

//======================================
//===== Merge links to financials ======
//======================================

foreach a in 2007 2008 2009 2010 2011 2012 2013 2014 2015{
* Merge
use "\input\orbis\links_`a'", clear
merge 1:1 id year using `tmp1'
drop if _merge == 1
drop _merge
save `tmp1',replace
}

//=======================================
//===== Merge financials to sector ======
//=======================================

merge m:1 id using "\input\orbis\sector"
drop if _merge == 2
drop _merge

save "\cleaning\temp\merged_`1'", replace

