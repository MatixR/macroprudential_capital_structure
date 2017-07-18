* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the cleaning files and return the final datasets

*Guideline to run master file:
* 1) choose a track index to avoid saving on previous files

* 2) choose percentage of database to sample

* 3) choose macroprudential instruments to create debt shifting variable 

*   a) options for GMPI:
*     MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX

*   b) options for IBRN:

*     changes: sscb_res_y_avg sscb_cons_y_avg sscb_oth_y_avg sscb_y_avg cap_req_y_avg 
*              concrat_y_avg ibex_y_avg ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg 

*     cumulative: cum_sscb_res_y_avg cum_sscb_cons_y_avg cum_sscb_oth_y_avg cum_sscb_y_avg 
*                 cum_cap_req_y_avg cum_concrat_y_avg cum_ibex_y_avg cum_ltv_cap_y_avg 
*                 cum_rr_foreign_y_avg cum_rr_local_y_avg

//==========================
//====== Clean Orbis ========
//==========================
* Run only once
do "\cleaning\code\orbis_to_dta"

//=========================
//====== Arguments ========
//=========================
cd "S:"
global track_index "orbis5"
global sample_percent=5
#delimit;
global MPP_vars "tax_rate sscb_res_y_avg sscb_cons_y_avg 
sscb_oth_y_avg sscb_y_avg cap_req_y_avg concrat_y_avg 
ibex_y_avg ltv_cap_y_avg rr_foreign_y_avg rr_local_y_avg
cum_sscb_res_y_avg cum_sscb_cons_y_avg cum_sscb_oth_y_avg cum_sscb_y_avg 
cum_cap_req_y_avg cum_concrat_y_avg cum_ibex_y_avg cum_ltv_cap_y_avg 
cum_rr_foreign_y_avg cum_rr_local_y_avg";
#delimit cr
//================================
//====== Sample and Merge ========
//================================

#delimit;
do "\cleaning\code\merging_orbis"
"$track_index" $sample_percent ;
#delimit cr

//========================================
//====== Merge to GMPI and IBRN ==========
//========================================

do "\cleaning\code\merging_IBRN"

#delimit;
do "\cleaning\code\merging_MPI" 
"$track_index" ;
#delimit cr

//==============================================
//====== Merge to World Bank controls ==========
//==============================================

#delimit;
do "\cleaning\code\merging_worldbank" 
"$track_index" ;
#delimit cr

//================================================
//====== Create debt shifting variables ==========
//================================================

#delimit;
do "\cleaning\code\debt_shifting_creator" 
"$track_index" "$MPP_vars" ;
#delimit cr

//=======================================
//====== Merge to PRS controls ==========
//=======================================

#delimit;
do "\cleaning\code\merging_PRS"
"$track_index" ;
#delimit cr

//=====================================================================
//====== Manipulate raw data to create variables of interest ==========
//=====================================================================

#delimit;
do "\cleaning\code\variables_creator"
"$track_index" ;
#delimit cr
