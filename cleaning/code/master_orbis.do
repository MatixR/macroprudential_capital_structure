//----------------------------------------------------------------------------//
// Project: Bank Regulation and Capital Structure                             //
// Author: Lucas Avezum, Tilburg University                                   //
// Date: 13/11/2017                                                           //
// Description: this file runs all the cleaning files separately and return   //
//              the final datasets in the output folder                       //
//----------------------------------------------------------------------------//

//============================================================================//
// Code setup                                                                 //
//============================================================================//

* General 
if "`c(hostname)'" != "EG3523" {
global STATAPATH "S:"
}
else if "`c(hostname)'" == "EG3523" {
global STATAPATH "C:/Users/u1273941/Research/Projects/macroprudential_capital_structure"
}
cd "$STATAPATH"     
set more off

* Particular
global track_index "bank_regulation" // Set index to files to track them
global sample=100                    // Set sample size

//============================================================================//
// Convert to dta                                                             //
//============================================================================//

do "\cleaning\code\orbis_to_dta" // Convert Orbis txt files in dta 

//============================================================================//
// Sample and merge                                                           //
//============================================================================//

do "\cleaning\code\merging_orbis" /// Merge Orbis files  
   "$track_index" $sample         /// and take $sample sample out of it
   
//============================================================================//
// Merge to IBRN and interest rate                                            //
//============================================================================//

do "\cleaning\code\merging_IBRN" "$track_index" 

//============================================================================//
// Merge to World Bank Survey on Bank Regulation                              //
//============================================================================//

do "\cleaning\code\merging_barth" "$track_index" 

//============================================================================//
// Merge to World Bank controls                                               //
//============================================================================//

do "\cleaning\code\merging_worldbank" "$track_index" 

//============================================================================//
// Merge to PRS controls                                                      //
//============================================================================//

do "\cleaning\code\merging_PRS" "$track_index"

//============================================================================//
// Clean dataset                                                              //
//============================================================================//

do "\cleaning\code\variables_creator" "$track_index"

//============================================================================//
// Create spillover variables                                                 //
//============================================================================//

do "\cleaning\code\spillover_creator" "$track_index"
