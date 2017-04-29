* This file imports raw dataset from Compustat and sample a percentage

use C:\Users\User\work\master_thesis\cleaning\input\compustat_link

sort SEDOL
preserve
tempfile tmp
bysort SEDOL: keep if _n == 1
sample 10
sort SEDOL
save `tmp'
restore
merge m:1 SEDOL using `tmp'
keep if _merge == 3
drop _merge 
save C:\Users\User\work\master_thesis\cleaning\temp\working_sample, replace
