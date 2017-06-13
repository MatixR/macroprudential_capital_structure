* Master Thesis Tilburg 2017
* Author: Lucas Avezum 

* This code runs all the cleaning files and return the three final datasets:
* stand alone firms, multinationals and full sample in the ouput folder

*Guideline do |file| ||

//=========================
//====== Arguments ========
//=========================
global track_index "sample10"
global info_file "info_VL"
global financial_file "financials_VL"
global sample_percent=10

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

//========================================
//====== Merging Amadeus to MPI ==========
//========================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\merging_MPI 
"$track_index" ;
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

//================================================
//====== Create debt shifting variables ==========
//================================================

#delimit;
do C:\Users\User\work\master_thesis\cleaning\code\debt_shifting_creator 
"$track_index" ;
#delimit cr
