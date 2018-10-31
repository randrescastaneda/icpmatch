/*====================================================================
project:       ICP matching procedure
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    28 Jul 2017 - 12:04:59
Modification Date:   
Do-file version:    01
References:          
Output:             
====================================================================*/

/*====================================================================
                        0: Program set up
====================================================================*/
version 14.2
drop _all

* Directory Paths
* global main "C:\Users\wb384996\OneDrive - WBG\Global TSD-Core\projects\GMD consumption\03_working files\data"
global main "" // directory where data has been saved.


/*====================================================================
       1: Translate items to English using Google API. 
====================================================================*/

* use "${main}\PAN_1000_TEST_v01_M item list.dta", clear
* googletrans item, replace
* rename item_en key
* save "${main}\PAN_1000_TEST_v01_M item list_translated.dta", replace


/*====================================================================
                      2: Match items to ICP division
====================================================================*/

use "${main}\PAN_1000_TEST_v01_M item list_translated.dta", clear
*-----------------2.1: check for duplicates and weird charactgers. 
replace key = ltrim(rtrim(itrim(key)))  // automatically done in icpmatch
replace key = lower(key)                // automatically done in icpmatch
duplicates drop key, force
replace key = subinstr(key, "?", "", .)


*------------------2.2:
sample 5                            // percentage of the sample to be matched.
icpmatch key ori_code, create       /// Create a new file
                       ssm(min)     /// Similarity score method
                       countr(PAN)  /// Country 
                       year(1000)   /// year
                       survey(TEST) /// survey
                       replace

/*====================================================================
                      3: Manual matching in Excel
====================================================================*/

/*====================================================================
                       4:  Test new addition of data
====================================================================*/


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:

use "c:\Users\wb384996\OneDrive - WBG\Global TSD-Core\projects\GMD consumption\03_working files\data\icpinall.dta" , clear

