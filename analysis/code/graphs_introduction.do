* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This file creates graphs
cd "S:"
set more off
//=================================
//===== Clean GMPI Database  ======
//=================================

foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
import excel country id var0 var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 var12 var13 using "\input\anual_macroprudential_database.xlsx", sheet("`a'") clear

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

save "\cleaning\temp\Index`a'.dta", replace

}

//=================================
//===== Merge GMPI Database  ======
//=================================
* Include country variable 
import excel country id using "\input\anual_macroprudential_database.xlsx", sheet("MPI") clear
drop if missing(id)
sort id
by id: gen dup = cond(_N==1,0,_n)
keep if dup==0 
drop dup
#delimit;
merge 1:m id using 
"\cleaning\temp\IndexMPI";
#delimit cr
sort id year
drop _merge

save "\cleaning\temp\MPI.dta", replace

* Join all indexes in one file 
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
#delimit;
merge 1:1 id year using 
"\cleaning\temp\Index`a'.dta";
#delimit cr
sort id year
drop _merge
drop if missing(MPI)
save "\cleaning\temp\MPI.dta", replace
}


destring id, replace
order id year
drop country
rename id ifscode

* Erase auxiliary files
foreach a in MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX {
erase "\cleaning\temp\Index`a'.dta"
}

save "\cleaning\temp\MPI.dta", replace

//=================================
//===== Clean IBRN Database  ======
//=================================

import excel using "\input\IBRN.xlsx", sheet("Data") firstrow clear

* Destring variables
foreach var of varlist _all{
destring `var', replace
}
* Get intensity of use of each measure
foreach var of varlist sscb_res-rr_local{
replace `var' =  abs(`var')
}
egen mpi_intensity = rowtotal(sscb_res-rr_local)

* Drop variables not used
keep mpi_intensity year quarter country ifscode
//================================
//===== Merge GMPI to IBRN  ======
//================================
sort ifscode year
#delimit;
merge m:1 ifscode year using 
"\cleaning\temp\MPI.dta";
#delimit cr
keep if _merge == 3
keep year quarter country mpi_intensity MPI
egen time = concat(year quarter)
destring time, replace
sort time
//================================
//===== Graph  ======
//================================
#delimit;
gen oecd = 1 if country == "France"| country == "Austria" | country == "Belgium"
    | country == "Canada"| country == "Germany"| country == "Greece" | country == "Iceland"
	| country == "Ireland" | country == "Italy" | country == "Netherlands" | country == "Norway"
    | country == "Portugal" | country == "Spain" | country == "Sweden" | country == "Switzerland"
    | country == "Turkey" | country == "United Kingdom" | country == "United States" ;  			
#delimit cr
#delimit cr

#delimit;
scatter MPI time [w=mpi_intensity]  if oecd==1, 
title("Original OECD members") graphregion(color(white)) bgcolor(white)
msymbol(Oh) yscale(range(0 8))  jitter(7) xline(20070) saving(oecd, replace);

scatter MPI time [w=mpi_intensity]  if oecd!=1, 
title("Other countries") graphregion(color(white)) bgcolor(white)
msymbol(Oh)  jitter(7) xline(20070) saving(others, replace);
#delimit cr
#delimit;
 gr combine oecd.gph others.gph, 
 graphregion(color(white));
 #delimit cr
  graph export "\analysis\output\graphs\intensity_graphs.eps", as(eps) replace

