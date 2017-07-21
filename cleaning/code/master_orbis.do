* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the cleaning files and return the final datasets
*
* Guideline to run master file:
* 1) choose a track index to avoid saving on previous files
*
* 2) choose percentage of database to sample
*
* 3) choose macroprudential instruments to create debt shifting variable 
*
*   a) options for GMPI:
*     MPI BORROWER FINANCIAL LTV LTV_CAP DTI DP CTC LEV SIFI INTER CONC FC RR RR_REV CG TAX
*
*   b) options for IBRN: 
*     Reserve requirements - foreign loan: rr_local_y
*     Reserve requirements - foreign loan: rr_foreign_y
*     LTV ratio limit: ltv_cap_y
*     Interbank exposure limit: ibex_y
*     Concentration limit: concrat_y
*     Capital requirement: cap_req_y
*     Sector specific capital buffer: sscb_y
*     Sector specific capital buffer - residential: sscb_res_y 
*     Sector specific capital buffer - consumer: sscb_cons_y
*     Sector specific capital buffer - others: sscb_oth_y
*
*   For all cumulative:  cum_*
*   For specific lags: l#_*
*   For all variables: *_y
*   Example: l2_cum_rr_local_y is the two quarters lag cumulative 
*            index for reserve requirement 

//==========================
//====== Clean Orbis ========
//==========================
* Run only once
do "\cleaning\code\orbis_to_dta"

//=========================
//====== Arguments ========
//=========================
cd "S:"
global track_index "orbis"
global sample_percent=100
#delimit;
global MPP_vars "tax_rate *_y";
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
