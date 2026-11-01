*---------------------------------------------------------------------------------------------------
* Master do-file 
* Project: Cohort Study
* Users: Original author
*---------------------------------------------------------------------------------------------------


version 19.5     
cap log close _all
clear all
macro drop _all
set more off
set type double
set linesize 120
set maxvar 32767



* === Set globals === *
* Each user should add a line like this (from then on everything is specified relative to main_dir) 
* Sanitized: removed machine-username detection.
di "Logged in as: `user'"

if "`user'" == "removed_user" {
    
    * Standardize file paths for MacOS
    global main_dir  "."
    global data_dir  "."
   
	
}

* Display paths to verify correctness
display "Main Directory: $main_dir"
display "Data Directory: $data_dir"


* === Open Log File === *
capture log close
capture mkdir "$main_dir/output/log"
local date = subinstr(c(current_date), " ", "", .)
capture log using "$main_dir/output/log/master_`date'.log", append
if _rc != 0 {
    display "WARNING: Log file could not be opened. Check directory permissions."
}

* === Check If Directories Exist === *
* === Ensure Directories Exist (Only If Missing) === *
capture confirm file "$main_dir/output/log"
if _rc != 0 capture mkdir "$main_dir/output/log" // log file folder

capture confirm file "$main_dir/output/temp"
if _rc != 0 capture mkdir "$main_dir/output/temp" // temporary file folder

capture confirm file "$main_dir/output/fig"
if _rc != 0 capture mkdir "$main_dir/output/fig" // folder for figures

capture confirm file "$main_dir/output/tab"
if _rc != 0 capture mkdir "$main_dir/output/tab" // folder for tables



* === Set adopaths === *
* Store ado files in a specific Dropbox folder
adopath ++ "$main_dir/Do files"
cap adopath - PERSONAL  
cap adopath - PLUS
cap adopath - OLDPLACE
cap adopath - "."

*adoinstall matselrc , to($main_dir/code/ado/ado_project_specific)

adopath + "$main_dir/Do files/ado/ado_project_specific" 
adopath + "$main_dir/Do files/ado/ado_ssc"              
adopath + "$main_dir/Do files/ado/ado_gslab"            

* === Set graph schemes ===*
set scheme burd  

* === Check If Directories Exist === *
* === Ensure Directories Exist (Only If Missing) === *
capture confirm file "$main_dir/Do files"
if _rc != 0 capture mkdir "$main_dir/Do files"
* === Run the do files === *
do "$main_dir/Do files/Appending_Raw_Data.do"
do "$main_dir/Do files/Results.do"



* === List files in relevant folders === *
dir "$main_dir/Do files/"
dir "$main_dir/output/fig/"
dir "$main_dir/output/tab/"
dir "$main_dir/output/temp/"

* === Close the log file safely === *
capture log close


