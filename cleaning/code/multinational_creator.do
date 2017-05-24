* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates multinational relationships
set more off

use C:\Users\User\work\master_thesis\cleaning\temp\working_sample, clear

* Create multinational indicator
replace guo_bvdepnr = idnr if  missing(guo_bvdepnr)
sort guo_bvdepnr idnr
egen multinational_ID = group(guo_bvdepnr)

* Create subsidiary per multinational indicator
egen multinational_subsidiary_ID = concat(guo_bvdepnr idnr)
sort multinational_ID multinational_subsidiary_ID
by multinational_ID multinational_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_ID (multinational_subsidiary_ID): gen subsidiary_ID = sum(help1)
drop help1
sort multinational_ID subsidiary_ID

* Create parent firm dummy
by multinational_ID: egen mean_subsidiary_ID = mean(subsidiary_ID)
gen owner = 1 if guo_bvdepnr == idnr
replace owner = 0 if missing(owner)
gen parent = 1 if mean_subsidiary_ID > owner & owner > 0
replace parent = 0 if missing(parent)


save C:\Users\User\work\master_thesis\cleaning\temp\working_sample2, replace









