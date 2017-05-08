* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges the datasets from Amadeus

 


keep if _merge == 3
drop _merge 
save C:\Users\User\work\master_thesis\cleaning\temp\fin_sample, replace


