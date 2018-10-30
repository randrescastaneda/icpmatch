/*====================================================================
project:       Load Stop Words and place in MATA
Author:        Andres Castaneda
----------------------------------------------------------------------
Creation Date:    15 Jan 2018 - 08:01:51
====================================================================*/

/*====================================================================
0: Program set up
====================================================================*/

program define icpmatch_sw

syntax [anything(name=list)]

qui {
	preserve
	
	if ("`list'" == "") local list "minimal"
	if !inlist("`list'", "xlarge", "large", "medium", "terrier", "minimal") {
		noi disp in red `"list of stop words must be one among "xlarge", "large", "medium", "terrier", "minimal" "'
		error 
	}
	
	sysuse icpmatch_SW, clear
	drop if `list' == ""
	mata: PSW = st_sdata(.,"`list'")
	
	restore
}

end
exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><



