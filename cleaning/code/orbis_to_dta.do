//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file opens and converts the raw datasets from Orbis from //
//              txt to dta format                                             //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
cd "S:"      
set more off

//============================================================================//
// Ownership links                                                            //
//============================================================================//

* Open entities file
import delimited "\input\orbis\txt_files\Entities.txt", varnames(1) clear

* Drop unsed variable
drop name

* Rename identifier
rename bvdidofthesubsidiaryorshareholde bvdid

* Remove duplicates
bysort bvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop dup

* Save entities data
save "\input\orbis\entities", replace

* Open links files and merge with entities
foreach a in 2013 2014 2015{
import delimited "\input\orbis\txt_files\Links_`a'.txt", varnames(1) clear 

* Create column for parent firms
keep subsidiarybvdid shareholderbvdid typeofrelation
keep if typeofrelation == "GUO 50C"
bysort subsidiarybvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop typeofrelation dup
preserve

* Create column for intermediate firms
import delimited "\input\orbis\txt_files\Links_`a'.txt", varnames(1) clear
tempfile tmp
keep subsidiarybvdid shareholderbvdid typeofrelation
keep if typeofrelation == "ISH"
bysort subsidiarybvdid: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop typeofrelation dup
rename shareholderbvdid id_I
save `tmp'
restore

* Merge intermediate and parent firms columns
merge 1:1 subsidiarybvdid using `tmp'
drop if _merge==2
drop _merge

* Merge subsidiary information
rename subsidiarybvdid bvdid
merge 1:1 bvdid using "\input\orbis\entities"
keep if _merge==3
drop _merge
rename bvdid id
rename countryisocode country_id
rename entitytype type_id

* Merge parent information
rename shareholderbvdid bvdid
merge m:1 bvdid using "\input\orbis\entities"
keep if _merge==3
drop _merge
rename bvdid id_P
rename countryisocode country_id_P
rename entitytype type_id_P

* Merge intermediate information
rename id_I bvdid
merge m:1 bvdid using "\input\orbis\entities"
drop if _merge==2
drop _merge
rename bvdid id_I
rename countryisocode country_id_I
rename entitytype type_id_I

* Generate year
gen year = `a'

* Save links data
save "\input\orbis\links_`a'", replace 
}

//============================================================================//
// Financial information                                                      //
//============================================================================//

import delimited "\input\orbis\txt_files\Industry - Global financials and ratios - USD.txt",///
       clear varnames(1) colrange(:62)

* Keep variables of interest
keep ïbvdidnumber consolidationcode closingdate numberofmonths fixedassets ///
     intangiblefixedassets tangiblefixedassets cashcashequivalent          ///
	 totalassets noncurrentliabilities longtermdebt currentliabilities     ///
	 loans numberofemployees sales ebitda debtors

* Rename variables
rename ïbvdidnumber id
rename fixedassets fias 
rename intangiblefixedassets ifas
rename tangiblefixedassets tfas 
rename cashcashequivalent cash 
rename totalassets toas
rename noncurrentliabilities ncli 
rename longtermdebt ltdb 
rename currentliabilities culi 
rename numberofemployees workers

* Get year from closing date
gen year = int(closingdate/10000)
replace year = closingdate if year==0

* Get quarter from closing date
gen month = int((closingdate-year*10000)/100)
replace month = 12 if month<0

* Get month from closing date
gen quarter = 1 if month == 1 | month == 2 | month == 3
replace quarter = 2 if month == 4 | month == 5 | month == 6
replace quarter = 3 if month == 7 | month == 8 | month == 9
replace quarter = 4 if month == 10 | month == 11 | month == 12

* Order variables
order id year quarter month

* Keep only uncosolidated information
keep if consol == "U1" | consol == "U2"
drop closingdate consolidationcode

* Replace duplicate if previous year is missing
sort id year month
by id: gen gap = year - year[_n-1]
by id year: gen dup = cond(_N==1,0,_n)
by id: replace year = year-1 if gap>1 & dup==1
drop dup gap

* Drop duplicate observations with most missing values 
egen nmis = rowmiss(fias ifas tfas cash toas ncli ltdb culi loans workers ///
                    sales ebitda debtors)
sort id year nmis
by id year: gen dup = cond(_N==1,1,_n)
keep if dup == 1
drop dup nmis

* Drop duplicate observations with least number of months 
sort id year numberofmonths
by id year: gen dup = cond(_N==1,1,_n)
by id year: keep if dup == _N
drop dup numberofmonths

* Save financial data
save "\input\orbis\financials", replace 

//============================================================================//
// Sector information                                                         //
//============================================================================//

* Import firm indexes   
import delimited "\input\orbis\txt_files\Industry classifications.txt", ///
       varnames(1) colrange(:2) clear
tempfile tmp
gen double id = _n
save `tmp'

* Import indexes 4 digit NACE rev.2
import delimited "\input\orbis\txt_files\Industry classifications.txt", ///
       varnames(1) colrange(8:8) clear
gen double id = _n

* Merge variables
merge 1:1 id using `tmp'

* Drop unused variables
drop nationalindustryclassificationus _merge id
drop if missing(nacerev2corecode4digits)

* Rename variables
rename nacerev2corecode4digits nace
rename ïbvdidnumber id

* Sector two digitis
gen nace2 = int(nace/100)

* Save industry file
save "\input\orbis\sector", replace

//============================================================================//
// Listed/Unlisted information                                                //
//============================================================================//

* Import firm indexes   
import delimited "\input\orbis\txt_files\Legal info.txt", ///
       varnames(1) colrange(:1) clear
gen double id = _n
tempfile tmp1
save `tmp1'

* Import listed information 
import delimited "\input\orbis\txt_files\Legal info.txt", ///
       varnames(1) colrange(14:18) clear
drop delistedcomment mainexchange
gen double id = _n

* Merge variables
merge 1:1 id using `tmp1'
drop id _merge

* Rename variables
rename ïbvdidnumber id
rename listeddelistedunlisted listed
rename delisteddate delisted_date
rename ipodate ipo_date

* Get year from IPO date
tostring ipo_date, generate(ipo_date_str)
gen ipo_year = substr(ipo_date_str, 1,4)
destring ipo_year, replace
drop ipo_date_str ipo_date

* Get year from delisted date
tostring delisted_date, generate(delisted_date_str)
gen delisted_year = substr(delisted_date_str, 1,4)
destring delisted_year, replace
drop delisted_date_str delisted_date

* Save listed file
save "\input\orbis\listed", replace

