* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file opens and clean the datasets from Orbis
set more off

//============================
//===== Ownership links ======
//============================

* Cleaning entities file
import delimited "\Entities.txt", varnames(1) clear
drop name
rename bvdidofthesubsidiaryorshareholde bvdid
bysort bvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop dup
save "\input\orbis\entities", replace

foreach a in 2007 2008 2009 2010 2011 2012 2013 2014 2015{
import delimited "\Links_`a'.txt", varnames(1) clear 
* Creating column for parent and intermediate
keep subsidiarybvdid shareholderbvdid typeofrelation
keep if typeofrelation == "GUO 50C"
bysort subsidiarybvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop typeofrelation dup
preserve
import delimited "\Links_`a'.txt", varnames(1) clear
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
"\input\orbis\entities";
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
"\input\orbis\entities";
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
"\input\orbis\entities";
#delimit cr
drop if _merge==2
drop _merge
rename bvdid id_I
rename countryisocode country_id_I
rename entitytype type_id_I

* Generating year
gen year = `a'
save "\input\links_`a'", replace 
}

//=======================
//===== Financials ======
//=======================

import delimited "\Industry - Global financials and ratios - USD.txt",clear varnames(1) colrange(:62)

* Keep variables of interest
#delimit;
keep ïbvdidnumber consolidationcode closingdate numberofmonths 
exchangeratefromoriginalcurrency fixedassets intangiblefixedassets 
tangiblefixedassets cashcashequivalent totalassets noncurrentliabilities 
longtermdebt currentliabilities loans numberofemployees sales ebitda;
#delimit cr

* Get year quarter and month from closing date
gen year = int(closingdate/10000)
replace year = closingdate if year==0

gen month = int((closingdate-year*10000)/100)
replace month = 12 if month<0

gen quarter = 1 if month == 1 | month == 2 | month == 3
replace quarter = 2 if month == 4 | month == 5 | month == 6
replace quarter = 3 if month == 7 | month == 8 | month == 9
replace quarter = 4 if month == 10 | month == 11 | month == 12

order ïbvdidnumber year quarter month

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"
drop closingdate consolidationcode

* Replace duplicate if previous year is missing
sort ïbvdidnumber year month
by ïbvdidnumber: gen gap = year - year[_n-1]
by ïbvdidnumber year: gen dup = cond(_N==1,0,_n)
by ïbvdidnumber: replace year = year-1 if gap>1 & dup==1
drop dup gap

* Drop repeated observations with most missing values 
#delimit;
egen nmis = rowmiss(fixedassets intangiblefixedassets tangiblefixedassets 
cashcashequivalent totalassets noncurrentliabilities longtermdebt 
currentliabilities loans numberofemployees sales ebitda);
#delimit cr
sort ïbvdidnumber year nmis
by ïbvdidnumber year: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop dup nmis

* Drop repeated observations with least number of months 
sort ïbvdidnumber year numberofmonths
by ïbvdidnumber year: gen dup = cond(_N==1,1,_n)
by ïbvdidnumber year: keep if dup == _N
drop dup

* Rename variables
rename ïbvdidnumber id
rename exchangeratefromoriginalcurrency exchrate
rename fixedassets fias 
rename intangiblefixedassets ifas
rename tangiblefixedassets tfas 
rename cashcashequivalent cash 
rename totalassets toas
rename noncurrentliabilities ncli 
rename longtermdebt ltdb 
rename currentliabilities culi 
rename numberofemployees workers 

* Save full data
save "\input\orbis\financials", replace 

//===============================
//===== Sector information ======
//===============================

* Import firm indexes   
import delimited "\Industry classifications.txt", varnames(1) colrange(:2) 
tempfile tmp
gen double id = _n
save `tmp'

* Import indexes 4 digit NACE rev.2
import delimited "\Industry classifications.txt", varnames(1) colrange(8:8) 
gen double id = _n

* Merge indexe
merge 1:1 id using `tmp'

* Drop and rename variables
drop nationalindustryclassificationus _merge id
drop if missing(nacerev2corecode4digits)
rename nacerev2corecode4digits nace
rename ïbvdidnumber id
save "\input\orbis\sector", replace
