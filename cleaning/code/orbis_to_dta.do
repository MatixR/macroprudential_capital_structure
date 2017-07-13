* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file opens and clean the datasets from Orbis
set more off

//============================
//===== Ownership links ======
//============================

* Cleaning entities file
import delimited S:\Entities.txt, varnames(1) clear
drop name
rename bvdidofthesubsidiaryorshareholde bvdid
bysort bvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop dup
save S:\entities, replace

set more off

foreach a in 2007 2008 2009 2010 2011 2012 2013 2014 2015{
import delimited S:\Links_`a'.txt, varnames(1) clear 
* Creating column for parent and intermediate
keep subsidiarybvdid shareholderbvdid typeofrelation
keep if typeofrelation == "GUO 50C"
bysort subsidiarybvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop typeofrelation dup
preserve
import delimited S:\Links_`a'.txt, varnames(1) clear
tempfile tmp
keep subsidiarybvdid shareholderbvdid typeofrelation
keep if typeofrelation == "ISH"
bysort subsidiarybvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop typeofrelation dup
rename shareholderbvdid id_I
save `tmp'
restore
merge 1:1 subsidiarybvdid using `tmp'
drop if _merge==2
drop _merge

* Merging subsidiary information
rename subsidiarybvdid bvdid
#delimit;
merge 1:1 bvdid using 
S:\entities;
#delimit cr
keep if _merge==3
drop _merge
rename bvdid id
rename countryisocode country_id
rename entitytype type_id

* Merging parent information
rename shareholderbvdid bvdid
#delimit;
merge m:1 bvdid using 
S:\entities;
#delimit cr
keep if _merge==3
drop _merge
rename bvdid id_P
rename countryisocode country_id_P
rename entitytype type_id_P


* Merging intermediate information
rename id_I bvdid
#delimit;
merge m:1 bvdid using 
S:\entities;
#delimit cr
drop if _merge==2
drop _merge
rename bvdid id_I
rename countryisocode country_id_I
rename entitytype type_id_I

* Generating year
gen year = `a'
save S:\links_`a', replace 
}

//=======================
//===== Financials ======
//=======================

import delimited "S:\Industry - Global financials and ratios - USD.txt", varnames(1) colrange(:62)

* Keep variables of interest
keep ïbvdidnumber consolidationcode closingdate numberofmonths exchangeratefromoriginalcurrency fixedassets intangiblefixedassets tangiblefixedassets cashcashequivalent totalassets noncurrentliabilities longtermdebt currentliabilities loans numberofemployees sales ebitda

save S:\financial, replace 

* Get year from closing date
gen year = int(closingdate/10000)
order ïbvdidnumber year

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"

drop closingdate consolidationcode

* Drop missing values
drop if missing(toas, ncli, culi)

* Drop repeated observations
sort ïbvdidnumber year numberofmonths
by ïbvdidnumber year: gen dup = cond(_N==1,1,_n)
by ïbvdidnumber year: keep if dup == _N
drop dup

rename ïbvdidnumber id

* Save full data
save S:\financials, replace 

//===============================
//===== Sector information ======
//===============================

* Import firm indexes   
import delimited "S:\input\Industry classifications.txt", varnames(1) colrange(:2) 
tempfile tmp
gen double id = _n
save `tmp'

* Import indexes 4 digit NACE rev.2
import delimited "S:\input\Industry classifications.txt", varnames(1) colrange(8:8) 
gen double id = _n

* Merge indexe
merge 1:1 id using `tmp'

* Drop and rename variables
drop nationalindustryclassificationus _merge id
drop if missing(nacerev2corecode4digits)
rename nacerev2corecode4digits nace
rename ïbvdidnumber id
save S:\input\sector, replace
