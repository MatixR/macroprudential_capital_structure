* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges controls datasets to Amadeus sample
set more off
  

//============================================
//===== Clean Macroprudential Database  ======
//============================================

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
import excel country id var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 using C:\Users\User\work\master_thesis\cleaning\input\anual_macroprudential_database.xlsx, sheet("`a'") clear

* Drop lines and collumns not used
drop if missing(var1)
drop country

* Drop obs that are not country
sort id
by id: gen dup = cond(_N==1,0,_n)  
keep if dup==0 
drop dup

* Turn database in long format
reshape long var, i(id) j(year)

* Create year variable and rename variable of interest
gen doismil = 2000
gen closdate_year = doismil + year
drop doismil year
rename var `a'

save "C:\Users\User\work\master_thesis\cleaning\temp\Index`a'.dta", replace

}


//============================================
//===== Merge Macroprudential Database  ======
//============================================
* Include country variable 
import excel country id using C:\Users\User\work\master_thesis\cleaning\input\anual_macroprudential_database.xlsx, sheet("MPI") clear
drop if missing(id)
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
#delimit;
merge 1:m id using 
C:\Users\User\work\master_thesis\cleaning\temp\IndexMPI;
#delimit cr
sort id closdate_year
drop _merge

save "C:\Users\User\work\master_thesis\cleaning\temp\MPI.dta", replace

* Join all indexes in one file 
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
#delimit;
merge 1:1 id closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\Index`a';
#delimit cr
sort id closdate_year
drop _merge
drop if missing(MPI)
save "C:\Users\User\work\master_thesis\cleaning\temp\MPI.dta", replace
}

* Write country variable in uppercase
gen country1 = upper(country)
drop country
rename country1 country 
order country closdate_year
save "C:\Users\User\work\master_thesis\cleaning\temp\MPI.dta", replace

* Erase auxiliary files
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
erase "C:\Users\User\work\master_thesis\cleaning\temp\Index`a'.dta"
}

//=======================================================
//===== Merge Macroprudential Database to Amadeus  ======
//=======================================================

use C:\Users\User\work\master_thesis\cleaning\temp\amadeus_sample, clear
sort country closdate_year
#delimit;
merge m:1 country closdate_year using 
C:\Users\User\work\master_thesis\cleaning\temp\MPI;
#delimit cr
keep if _merge==3
drop _merge
save "C:\Users\User\work\master_thesis\cleaning\temp\amadeus_MPI.dta", replace


