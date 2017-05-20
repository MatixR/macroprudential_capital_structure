* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates multinational relationships
use C:\Users\User\work\master_thesis\cleaning\temp\working_sample, clear

* Create parent dummy
replace guo_bvdepnr = idnr if  missing(guo_bvdepnr)
gen parent = 1 if guo_bvdepnr == idnr
replace parent = 0 if missing(parent)

* Create multinational indicator
sort guo_bvdepnr idnr
egen multinational_ID = group(guo_bvdepnr)

* Create subsidiary per multinational indicator
egen multinational_subsidiary_ID = concat(guo_bvdepnr idnr)
sort multinational_ID multinational_subsidiary_ID
by multinational_ID multinational_subsidiary_ID: gen help1 = 1 if _n == 1
replace help1 = 0 if missing(help1)
bysort multinational_ID (multinational_subsidiary_ID): gen subsidiary = sum(help1)
drop help1
sort multinational_ID subsidiary_ID

save C:\Users\User\work\master_thesis\cleaning\temp\working_sample, clear





