*	initial_analysis_V2 -> Changed Balanced Panel Creation Method 
*
*	last modified: William Wu, 10/7/2022

clear
set more 1

ssc inst distinct

cd D:\Code\STATA\Safegraph\SG_Data\spend_patterns

local file_list : dir "`c(pwd)'" files "spend_y*.dta"
di `"`file_list'"'

tempfile tmp
save `tmp', replace empty

* Combining all the files we have between 2020 and 2022
forv y = 2020 / 2022 {
	local m_max = 12*(`y' < 2022) + 3*(`y'== 2022)
	forv m = 1 / `m_max' {
		qui: use spend_y`y'_m`m', clear			
		gen year = `y'
		gen month = `m'
		append using `tmp'
		save `tmp', replace	
	}
}

save "dta_combined.dta", replace

* 16,010,817 observations
use "dta_combined.dta", clear

drop opened_on closed_on

egen id = group(placekey)
gen int date = ym(year, month)
* number of unique placekeys
distinct placekey naics_code
* 1,173,018 unique placekeys
* 387 unique naics_codes

xtset id date
* Unbalanced Panel
xtdescribe
* 349,542 unique ids track across all 28 waves or 9,787,176 lines
* 490,592 unique ids track across only y2022m4 or 490,592 lines
* 68,928 unique ids are missing one to two months(April-May) at the start of 2020 or (1,792,128-1,861,056 lines)
drop brands year month

* Balanced Panel
reshape wide raw_total_spend raw_num_transactions raw_num_customers, i(placekey) j(date)
reshape long raw_total_spend raw_num_transactions raw_num_customers, i(placekey) j(date)
format date %tm
xtdescribe
save balanced_view, replace


