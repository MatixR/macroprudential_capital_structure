* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the cleaning files and return the final datasets

*Guideline to run master file:
* 1) choose a track index to avoid saving on previous files

* 2) choose percentage of database to sample

* 3) choose firm level data set

*   a) Amadeus large and very large firms:
*     info file       -> info_VL 
*     financials file -> financials_VL 

* 3) choose macroprudential instruments to create debt shifting variable 

*   a) options for GMPI:
*     MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX

*   b) options for IBRN:

*     changes: sscb_res_y_avg sscb_cons_y_avg sscb_oth_y_avg sscb_y_avg cap_req_y_avg 
*              concrat_y_avg ibex_y_avg ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg 

*     cumulative: cum_sscb_res_y_avg cum_sscb_cons_y_avg cum_sscb_oth_y_avg cum_sscb_y_avg 
*                 cum_cap_req_y_avg cum_concrat_y_avg cum_ibex_y_avg cum_ltv_cap_y_avg 
*                 cum_rr_foreign_y_avg cum_rr_local_y_avg

//=========================
//====== Arguments ========
//=========================
global track_index "sample10"
global sample_percent=10
global info_file "info_VL"
global financial_file "financials_VL"
global MPP_vars "MPI BORROWER FINALCIAL tax_rate ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg cum_ltv_cap_y_avg cum_rr_foreign_y_avg cum_rr_local_y_avg"

//======================
//====== Sample ========
//======================
#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\sampling 
"$track_index" "$financial_file" $sample_percent ;
#delimit cr

//========================================
//====== Merging Amadeus datasets ========
//========================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\merging 
"$track_index" "$info_file" ;
#delimit cr

//==================================================
//====== Merging Amadeus to GMPI and IBRN ==========
//==================================================

do C:\Users\User\work\master_thesis\cleaning\code\merging_IBRN

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\merging_MPI 
"$track_index" ;
#delimit cr

//================================================
//====== Create debt shifting variables ==========
//================================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\debt_shifting_creator 
"$track_index" "$MPP_vars" ;
#delimit cr

//================================================================
//====== Merging Amadeus and MPI to World Bank controls ==========
//================================================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\merging_worldbank 
"$track_index" ;
#delimit cr

//=========================================================
//====== Merging Amadeus and MPI to PRS controls ==========
//=========================================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\merging_PRS
"$track_index" ;
#delimit cr

//=====================================================================
//====== Manipulate raw data to create variables of interest ==========
//=====================================================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\variables_creator 
"$track_index" ;
#delimit cr


