* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file merges both macroprudential datasets to Amadeus sample
set more off
  

//=================================
//===== Clean GMPI Database  ======
//=================================

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
import excel country id var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\anual_macroprudential_database.xlsx", sheet("`a'") clear

* Drop lines and collumns not used
drop if missing(var1)
drop country

* Drop obs that are not country
sort id
by id: gen dup = cond(_N==1,0,_n)  
keep if dup==0 
drop dup

* Turn database in long format
reshape long var, i(id) j(year_help)

* Create year variable and rename variable of interest
gen doismil = 2000
gen year = doismil + year_help
drop doismil year_help
rename var `a'

save "S:\temp\Index`a'.dta", replace

}


//=================================
//===== Merge GMPI Database  ======
//=================================
* Include country variable 
import excel country id using "\\Client\C$\Users\User\work\master_thesis\cleaning\input\anual_macroprudential_database.xlsx", sheet("MPI") clear
drop if missing(id)
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
#delimit;
merge 1:m id using 
"S:\temp\IndexMPI";
#delimit cr
sort id year
drop _merge

save "S:\temp\MPI.dta", replace

* Join all indexes in one file 
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
#delimit;
merge 1:1 id year using 
"S:\temp\Index`a'.dta";
#delimit cr
sort id year
drop _merge
drop if missing(MPI)
save "S:\temp\MPI.dta", replace
}


destring id, replace
order id year
drop country
rename id ifscode

* Erase auxiliary files
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
erase "S:\temp\Index`a'.dta"
}

save "S:\temp\MPI.dta", replace

//================================
//===== Merge GMPI to IBRN  ======
//================================
tempfile tmp
sort ifscode year
#delimit;
merge 1:1 ifscode year using 
"S:\temp\IBRN.dta";
#delimit cr
drop _merge
drop if missing(country_id)
sort country_id year
save `tmp'

//==================================================================
//===== Merge Macroprudential Database to Financials dataset  ======
//==================================================================

use "S:\temp\merged_`1'", clear
sort country_id year
merge m:1 country_id year using `tmp'
keep if _merge==3
drop _merge
save "S:\temp\merged_MPI_`1'.dta", replace


