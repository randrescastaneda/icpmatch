/*====================================================================
project:       ICP matching
Author:        Andres Castaneda 
Dependencies:  The World Bank
----------------------------------------------------------------------
Creation Date:    19 Apr 2017 - 11:41:43
Modification Date:   
Do-file version:    01
References:          
Output:             dta file
====================================================================*/

/*====================================================================
0: Program set up
====================================================================*/
program define icpmatch ,  // rclass
version 14
syntax varlist(min=1 max=2), [                            ///
SIMilmethod(string) INcat(numlist) EXcat(numlist)         ///
SIMThreshold(real 0.5) NGRAM(integer 3) NMATCH(integer 3) ///
COUntry(string) Year(numlist max=1) survey(string)        ///
step(integer 20) SSMethod(string) create replace  unify   ///
STOPWords STOPThreshold(real 2)  tsclient                 ///
ORIGvar(varname)                                          ///
]

preserve 
qui {
	
	/*====================================================================
	0. Consistency files
	====================================================================*/
	*------------ * Necessary programs
	cap which dirlist
	if (_rc) ssc install dirlist
	
	*------------ * Directory Paths
	if ("`c(username)'" == "wb384996" & "`tsclient'" == "tsclient") {
		if ("`c(hostname)'" == "PC4422276") {
			local mainpath "c:\Users\wb384996\OneDrive - WBG\Global TSD-Core\projects\GMD consumption\03_working files"
			
		}
		if ("`c(hostname)'" == "dpg-stata642") {
			local mainpath "\\tsclient\C\Users\wb384996\OneDrive - WBG\Global TSD-Core\projects\GMD consumption\03_working files"
		}
	}  // TO CHANGE
	* else local mainpath "\\wbntst01.worldbank.org\TeamDisk\GPWG\datalib\GMD consumption\03_working files"
	else local mainpath "z:\public\Stats_Team\Global Collaboration\GMD consumption\03_working files"
	
	
	local placefile "\`country'_\`survey'_\`year'"
	local matched       "`mainpath'\data\icpmatch\matchicp_`placefile'.dta"
	local unmatched     "`mainpath'\data\icpmatch\unmatchicp_`placefile'"
	local manualmatched "`mainpath'\data\icpmatch\manualmatchicp_`placefile'.xlsx"
	local unified       "`mainpath'\data\icpmatch\unified_`placefile'.dta"
	
	local date: disp %tdD-m-CY date("`c(current_date)'", "DMY")
	
	
	*------------ Filename consistency 
	
	if ("`create'" != "" | "`replace'" != "" | "`unify'" != "") {
		***------ Info not provided
		if ("`country'" == "") {
			noi disp as text  "Country:" _request(_country)
		}
		if ("`year'" == "") {
			noi disp as text  "Year:" _request(_year)
		}
		if ("`survey'" == "") {
			noi disp as text  "Survey:" _request(_survey)
		}	
		if ("`country'" == "" | "`year'" == "" | "`survey'" == "") {
			noi disp as err "you must provide country, year, and survey acronym"
			error
		}
		
		** Ensure survey acronym
		if wordcount("`survey'") != 1 {
			noi disp as err "make sure survey() is an acronym, not the actual name. It must have one sing word"
		}
		else {
			local survey = upper("`survey'")
		}
		** Ensure country code
		if length("`country'") != 3 {
			noi disp as err "Country code must follow iso-3 standard"
			error
		}
		else {
			local country = upper("`country'")
		}
		
		** ensure year is numeric
		cap confirm number `year'
		if (length("`year'") != 4 |  _rc != 0) {
			noi disp as err "year must be a four-digit number"
			error 
		}
		
		*****************
		** confirm existance of files when replace or create are selected
		*****************
		if ("`create'" != "" | "`replace'" != "") {
			cap confirm new file "`unmatched'.xlsx"
			if (_rc) {
				if ("`replace'" == "") {
					noi disp as text "file " as res "unmatchicp_`country'_`survey'_`year'.xlsx " ///
					as text "already exists." _c
					noi disp as text  "Please type now {ul:replace} to confirm overwriting. " ///
					"Otherwise, press enter" _request(_replace)
				}
				if  ("`replace'" != "replace") {
					noi disp as err "replace option not or miss specified."
					error
				}
			}  // end of _rc for not existance of unmatching file
		}  // end replace and create condition
		
		*****************
		** when unify is selected 
		*****************
		if ("`unify'" == "unify") {
			cap confirm file "`manualmatched'"
			local manmatchfile = _rc
			
			cap confirm file "`matched'"
			local matchfile = _rc
			
			cap confirm file "`unmatched'.dta"
			local unmatchfile = _rc
			
			if (`manmatchfile' != 0 & `unmatchfile' != 0) {
				if (`matchfile' == 0) {
					noi disp as res "file matchicp_`country'_`survey'_`year'.dta will be used as ICP anchor"
					copy "`matched'" "`unified'"
				}
				else {
					noi disp as err "No file found to create unifed anchor for `country'_`survey'_`year'"
					error
				}
			}
			
			else if (`manmatchfile' != 0 & `unmatchfile' == 0) {
				noi disp as err "you need to create the manual matching file for `country'_`survey'_`year'" ///
				_n "go " `"{stata `" shell "`mainpath'\global files\ICP manual matching tool.xlsm" "': here }"'
				error
			}
			
			else if (`manmatchfile' == 0 & `unmatchfile' != 0) {
				noi disp as err "inconcistency error. manual matching file found but no unmatch file found."
				error
			}
			
			else {
				des using "`matched'", varlist
				local idvar  : word 1 of `r(varlist)' 
				local txtvar : word 2 of `r(varlist)'
				import excel using "`manualmatched'", describe						
				if regexm("`r(range_1)'", "([0-9]+$)") local lastrow = regexs(1)
				
				import excel using "`manualmatched'", ///
				cellrange(A1:C`lastrow') firstrow case(lower)								
			}
			
		} 
		
	}  // end of if ("`create'" != "" | "`replace'" != "" | "`unify'" != "")
	
	
	/*====================================================================
	0.2 Consistency statements
	====================================================================*/
	
	
	** SIMilmethod
	if ("`similmethod'" == "")  local similmethod "ngram_circ, `ngram'"
	if ("`ssmethod'" == "") local ssmethod "jaccard"
	if !inlist("`ssmethod'", "jaccard", "simple", "min", "keybase") {
		noi disp as err "similarity score must be jaccard, simple, or min"
		error
	}
	
	****** varlist
	** txtvar
	local txtvar: word 1 of `varlist'
	replace `txtvar' = ltrim(rtrim(itrim(`txtvar')))
	replace `txtvar' = lower(`txtvar')
	
	** idvar
	if (wordcount("`vartlist'") == 1) {
		tempvar idvar
		gen `idvar' = _n
	}
	else local idvar: word 2 of `varlist'
	
	***** matching variables 
	**keyhole
	cap confirm new var keyhole
	if (_rc == 0) clonevar keyhole = `txtvar'
	else {
		noi disp as err "the name 'keyhole' is restricted to icpmatch. Please, rename it"
		error _rc
	}
	
	**similscore
	cap confirm new var similscore
	if (_rc) {
		noi disp as err "the name 'similscore' is restricted to icpmatch. Please, rename it"
		error _rc
	}
	
	*** making sure data has unique values
	duplicates report `txtvar'		
	if (r(unique_value) != r(N)) {
		noi disp "unique values: "  r(unique_value)
		noi disp "N            : "  r(N)
		noi disp as err "`txtvar' does not have unique observations."
		error 
	}
	
	* Original Language variable
	if ("`origvar'" == "") {
		clonevar origvar = `txtvar'
		local origvar origvar
	}
	tempfile userfile
	save `userfile', replace
	// Use manual matching that has been created for this particular country and year.
	// This is not the most effcient way because the program should get all the 
	// information provided by the rest of the users but we need to find a system
	// in which somebody verifies that the information exported by the harmonizer
	// is valid. Also, the program should at least use the manual matching files for
	// the same country. However, this solution is temporal. 
	
	if ("`manmatchfile'" == "0") {
		import excel using "`manualmatched'", ///
		firstrow case(lower) clear
		destring icpcode, replace 
		tempfile mglobal
		save `mglobal'
		
		// use "`mainpath'/data/icpinall.dta", clear
		sysuse icpmatch_icpdataset, clear
		merge 1:1 source addition nobs using `mglobal', update replace nogen
	}
	// else use "`mainpath'/data/icpinall.dta", clear
	sysuse icpmatch_icpdataset, clear
	tempfile icpinall
	save `icpinall', replace
	
	/*====================================================================
	1: Exact matchings
	====================================================================*/
	
	*-----------------1.1: ID variable and data treatment
	use `userfile', clear
	merge 1:1 keyhole using `icpinall', keepusing(icpcode) keep(1 3)
	tempfile icpmerge
	save `icpmerge', replace
	
	** keep matched obs
	keep if _merge == 3
	count
	if r(N) != 0 {
		keep `idvar' `txtvar' `origvar'  keyhole icpcode 
		gen similscore = 1 
		tempfile perfectmatch
		save `perfectmatch', replace
		local pmatch = 1
	}
	else local pmatch = 0
	
	
	if ("`create'" != "" | "`replace'" != "") {
		if (`pmatch' == 0 ) drop _all
		else {
			order `idvar' `txtvar'  icpcode 
			save "`matched'.dta", `replace'
		}
	}
	
	*------------1.2: Display of perfect matchint
	
	/*====================================================================
	2: Imperfect matching
	====================================================================*/
	
	*--------------2.1:calculation of matching
	** Load ICP data and put it in MATA
	// use "`mainpath'/data/icpinall.dta", clear
	sysuse icpmatch_icpdataset, clear
	mata: Keyholecol = st_sdata(., "keyhole"); IdKeyholecol = st_data(.,  "icpcode")
	
	** Load master data
	use `icpmerge', clear 
	keep if _merge == 1
	keep `idvar' `txtvar' `origvar'
	mata: st_sview(Keycol  =.,., "`txtvar'"); st_view(IdKeycol =.,.,  "`idvar'"); ///
	st_sview(Origvar  =.,., "`origvar'") // Key column ID
	
	icpmatch_sw
	noi mata: _icpmatch(Keycol, Keyholecol, IdKeycol, IdKeyholecol, Origvar, PSW) 
	duplicates drop 
	
	bysort `txtvar': egen rankscore = rank(similscore), field
	sort `txtvar' rankscore
	tempvar seq
	bysort `txtvar': egen `seq' = seq()
	drop if `seq' > `nmatch'
	icpmatch_labels icpcode
	
	/*====================================================================
	3: Display results
	====================================================================*/		
	if (`pmatch' == 1) append using `perfectmatch'
	tempfile fullmatch
	sort `txtvar' rankscore
	compress
	save `fullmatch'
	/*====================================================================
	4: append and export results to Excel
	====================================================================*/
	if ("`create'" != "" | "`replace'" != "") {			
		keep `idvar' `origvar' `txtvar' icpcode similscore rankscore
		keep if rankscore != .  // we don't want the perfect matched items		
		
		rename icpcode icp
		gen icpcode = icp
		
		duplicates drop key icpcode icp, force // eliminate duplicate matching
		sort `idvar' `txtvar' rankscore
		order `idvar' `origvar' `txtvar' icpcode icp similscore rankscore
		
		save "`unmatched'.dta", `replace'
		cap export excel using "`unmatched'.xlsx", sheet("raw") ///
		firstrow(variables) `replace'
		if (_rc == 603) {
			noi disp in red "Caution: " in y " file `unmatched'.xlsx could not be saved." 
			noi disp "Make sure the file is closed and " _c
			noi disp `"{stata `" export excel using "`unmatched'.xlsx", sheet("raw") firstrow(variables) `replace' "': click here }"' "to try again"
		}
		if (_rc > 0 & _rc != 603) {
			noi disp in red "Caution: " in y " file `unmatched'.xlsx could not be saved." 
			error
		}
		** Open manual matching tool
		noi disp as text "ICP matching for `country' `survey' `year' has been concluded."
		noi disp as text "To start manual matching process, please click " ///
		`"{stata `" winexec "`mainpath'\global files\ICP manual matching tool.xlsm" "': here }"'
		
	}
	
} // end of qui

restore 
use `fullmatch', clear
order `idvar' `origvar' `txtvar' icpcode icp similscore rankscore
end

*><<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>*
*==============================================
*  Other programs
*==============================================



*==============================================
*     MATA
*==============================================

mata:
mata drop _icpmatch*()
mata set mataoptimize on
mata set matafavor speed


void  _icpmatch(string colvector Keycol, 
string colvector Keyholecol, 
real colvector IdKeycol, 
real colvector IdKeyholecol, 
string colvector Origvar, 
string vector PSW) {   // 
	
	timer_clear()
	timer_on(5)
	// Ngram                    // Number of grams
	// threshold                // Threshold of similscore
	// Nmatch                   // No. of matching keys and keyholes
	
	// Load master data 
	origvarm   = st_local("origvar")   // original var name
	idm        = st_local("idvar")   // original var name
	txtm       = st_local("txtvar")  // original var name
	Stwords    = st_local("stopwords")
	stopthrld  = strtoreal(st_local("stopthreshold"))
	
	//----------------------------------------
	// Stop Words
	//----------------------------------------
	
	timer_on(6)
	StopWords = _stopwords(Keycol, stopthrld, PSW)
	
	
	// -----------------------------
	// 1. remove PSW from DSW and items data
	
	for (i = 1; i<= rows(PSW); i++) {
		Keycol     = subinword(Keycol,     PSW[i], "") 
		Keyholecol = subinword(Keyholecol, PSW[i], "") 
	}
	Keycol     = stritrim(Keycol    )
	Keyholecol = stritrim(Keyholecol)	
	
	// Eliminate missings
	_sort(StopWords,1)
	info = panelsetup(StopWords, 1)
	o = info[2,1],. \ info[rows(info),1], .   // rows with information
	StopWords = StopWords[| o |]
	
	
	// -----------------------------
	// 2. Identify items with data SW
	
	DSWSreg =  "(^" :+ StopWords :+ ")|( " :+ StopWords :+ " )|(" :+ StopWords :+ "$)"
	a = rowsum(regexm(Keycol,DSWSreg'))
	KeyhasSW = (a:>0) :* 1
	o = order(KeyhasSW,1)
	info = panelsetup(KeyhasSW[o],1)
	pp = info[2, 1],. \ info[2, 2], .
	
	KeycolSW   = Keycol[o[|pp|]]    // only items with SW
	IdKeycolSW = IdKeycol[o[|pp|]]  // ID of items only with SW
	OrigvarSW  = Origvar[o[|pp|]]   // Original lang name
	
	
	
	a = rowsum(regexm(Keyholecol,DSWSreg'))
	KeyholehasSW = (a:>0) :* 1
	o = order(KeyholehasSW,1)
	info = panelsetup(KeyholehasSW[o],1)
	pp = info[2, 1],. \ info[2, 2], .
	
	KeyholecolSW   = Keyholecol[o[|pp|]] // only items with SW
	IdKeyholecolSW = IdKeyholecol[o[|pp|]] // only items with SW
	
	
	// -----------------------------
	// 3. Remove data SW from items 
	for (i = 1; i<= rows(StopWords); i++) {
		KeycolNoSW     = subinword(Keycol, StopWords[i], "") 
		KeyholecolNoSW = subinword(Keyholecol, StopWords[i], "") 
	}
	KeycolNoSW     = stritrim(KeycolNoSW)
	KeyholecolNoSW = stritrim(KeyholecolNoSW)	
	
	
	// -----------------------------
	// 4. create pointers to items and keyholes w/out SWs 
	
	pointer matrix Pinputs
	Pinputs = J(5, 2, NULL)
	
	Pinputs[1,1]  = &(KeycolNoSW)
	Pinputs[2,1]  = &(KeyholecolNoSW)
	Pinputs[3,1]  = &(IdKeycol)
	Pinputs[4,1]  = &(IdKeyholecol)
	Pinputs[5,1]  = &(Origvar)
	Pinputs[1,2]  = &(KeycolSW)
	Pinputs[2,2]  = &(KeyholecolSW)
	Pinputs[3,2]  = &(IdKeycolSW)	
	Pinputs[4,2]  = &(IdKeyholecolSW)
	Pinputs[5,2]  = &(OrigvarSW)
	
	// -----------------------------
	// 5. Run main calculations
	Presults = _mainicpcalc(Pinputs)
	// (*Presults[1,1])
	// (*Presults[1,2])
	// (*Presults[2,1])
	// (*Presults[2,2])
	
	Results = (*Presults[1,1])\(*Presults[1,2])
	TXTvars = (*Presults[2,1])\(*Presults[2,2])
	
	
	timer_off(6)
	
	numvars = idm, "similscore", "icpcode"
	strvars = origvarm, txtm, "keyhole"
	
	st_dropvar(.)
	st_addobs(rows(Results))
	nv = st_addvar("double", numvars)
	sv = st_addvar("str2045", strvars)
	
	st_store(., nv, Results)
	st_sstore(., sv, TXTvars)
}



pointer matrix _mainicpcalc(pointer matrix Pinputs) {
	
	Nmatch      = strtoreal(st_local("nmatch")) 
	threshold   = strtoreal(st_local("simthreshold")) 
	Ngram       = strtoreal(st_local("ngram")) 
	
	pointer matrix Presholder
	Presholder = J(2, 2, NULL)          // Results holder 
	
	for (j = 1; j <= 2; j++) {
		
		Keycol       = (*Pinputs[1,j]) // Keycol under treatment
		Keyholecol   = (*Pinputs[2,j]) // Keyholecol under treatment
		IdKeycol     = (*Pinputs[3,j]) // Original ID
		IdKeyholecol = (*Pinputs[4,j]) // Keyholecol ID
		Origvar      = (*Pinputs[5,j]) // Original Language variable
		
		rowskey     = rows(Keycol)
		rowskeyhole = rows(Keyholecol)
		
		// create pointers
		pointer(string matrix) rowvector PK
		PK = J(1, rowskey, NULL)       //  pointer K
		
		pointer(string matrix) rowvector PKH
		PKH = J(1, rowskeyhole, NULL)  //  pointer KH
		
		
		// start loops
		printf("\t{res}First stage, ")
		timer_on(1)
		for (kobs = 1; kobs <= rowskey; kobs++) {  // each obs of key column 
			timer_on(2)
			fset = substr(Keycol[kobs, 1] ,1, Ngram)  // first set of grams
			Key = Keycol[kobs, 1]+" "+fset       // circular n-grams algorithm
			
			// create matrix with Key grams
			keylen = strlen(Key)+1 
			for (i=1; i<=keylen; i++) {
				if (i==1) PK[kobs] = &(substr(Key,i, Ngram))
				else      (*PK[kobs]) = (*PK[kobs]) \ substr(Key,i, Ngram)
			}
			timer_off(2)
		}
		printf("Done!\n")	
		
		printf("\t{res}Second stage, ")
		for (khobs = 1; khobs<= rowskeyhole; khobs++) {
			timer_on(3)
			fset = substr(Keyholecol[khobs, 1] ,1, Ngram)  // first set of grams
			Keyhole = Keyholecol[khobs, 1]+" "+fset       // circular n-grams algorithm
			
			// create matrix with Keyhole grams
			keyholelen = strlen(Keyhole)+1 
			for (i=1; i<=keyholelen; i++) {
				if (i==1) PKH[khobs] = &(substr(Keyhole,i, Ngram)) 
				else      (*PKH[khobs]) = (*PKH[khobs]) \ substr(Keyhole,i, Ngram)
			}
			timer_off(3)
		}	
		printf("Done!\n")
		
		if (j == 1) stage = "Third"
		if (j == 2) stage = "Fourth"
		
		
		printf("{res}\n\t%s stage stats: \n", stage)
		printf("{txt}Number of Keys {col 30}{res}%15.0gc\n", rowskey)
		printf("{txt}Number of Keyholes {col 30}{res}%15.0gc\n", rowskeyhole)
		printf("{txt}No. of iterations {col 30}{res}%15.0gc\n", rowskeyhole*rowskey)
		
		Scores = _icpscores(rowskey, rowskeyhole, PK, PKH)
		
		
		timer_off(1)
		timer_off(5)
		
		printf("\t{res}100%%...{txt}Done!\n")
		// timer("(1) overall timing - (2) Keys - (3) keyholes - (4) Matching", (1..5))
		
		// Apply threshold and convert to missing those discarded obs
		Scores = 0 * (Scores:<=threshold) + (Scores:>threshold) :* Scores
		_editvalue(Scores, 0,.)
		
		Imax =.  // Item with max value
		Wmax = . // [m,n] m indicates the first minimum of v start at i[m], n times
		
		// Create matrices with results
		for (kobs = 1; kobs <= rows(Keycol); kobs++) {
			maxindex(Scores[kobs,.], Nmatch, Imax, Wmax )   
			if (kobs == 1) {
				Results = J(rows(Imax), 1, IdKeycol[kobs,1]), 
				Scores[kobs, Imax]' , IdKeyholecol[Imax,1]
				
				TXTvars = J(rows(Imax), 1, Origvar[kobs,1]), 
				J(rows(Imax), 1, Keycol[kobs,1]), 
				Keyholecol[Imax,1]
				
			}
			else {
				Results = Results \ (J(rows(Imax), 1, IdKeycol[kobs,1]), 
				Scores[kobs, Imax]' , IdKeyholecol[Imax,1] )
				
				TXTvars = TXTvars \ J(rows(Imax), 1, Origvar[kobs,1]), 
				J(rows(Imax), 1, Keycol[kobs,1]), 
				Keyholecol[Imax,1]
			}  
		}
		if (j== 1) {
			RES1 = Results
			TXT1 = TXTvars
			Presholder[1,j] = &(RES1)
			Presholder[2,j] = &(TXT1)
		}
		else {
			Presholder[1,j] = &(Results)
			Presholder[2,j] = &(TXTvars)
		}
	}
	
	return(Presholder)
	
}  // end of function mainicpcalc


function _icpscores(numeric scalar rowskey, 
numeric scalar rowskeyhole, 
pointer PK, 
pointer PKH) {
	
	// parameters
	ssmethod   = st_local("ssmethod")
	step       = strtoreal(st_local("step")) 
	stepcut    = step
	
	Niter   = rowskey*rowskeyhole   // Number of iterations
	iter    = 0
	Scores  = J(rowskey, rowskeyhole, .)  // Scores  matrix
	
	
	for (kobs = 1; kobs <= rowskey; kobs++) {  // each obs of key column 
		for (khobs = 1; khobs<= rowskeyhole; khobs++) {
			
			timer_on(4)
			Matched = strmatch((*PK[kobs]), (*PKH[khobs])')  // matrix of matching grams
			Matchkey = rowsum(Matched)  // Colvector of matched grams of Key
			_editvalue(Matchkey, 0,.)   // convert zeros to missing
			
			// calculate simil score
			Numerator = colnonmissing(Matchkey)
			Denom1    = rows((*PK[kobs]))
			Denom2    = rows((*PKH[khobs]))
			
			if      (ssmethod == "jaccard") simscore  = Numerator/sqrt(Denom1*Denom2) 
			else if (ssmethod == "simple")  simscore  = 2*Numerator/(Denom1+Denom2) 
			else if (ssmethod == "min")     simscore  = Numerator/min((Denom1,Denom2))
			else                            simscore  = Numerator/Denom1
			
			if (simscore >1 & ssmethod == "min") simscore = 0.999999
			Scores[kobs, khobs] = simscore // Store in score matrix
			
			timer_off(4)
			
			// display progress and time comments
			if (kobs == 2 & khobs ==1) {  // aprox computing time
				time = ceil(Niter*(timer_value(4)[1,1]/timer_value(4)[1,2])/60)
				_timecomments(time)
			} // time comments
			
			++iter
			counter=(iter/Niter)*100
			if (counter>stepcut) {
				printf("\t{res}%3.0f%%\n",  round(counter))
				stepcut = stepcut + step
			}
		} // end of  Keyhole loop
	} //  end of key loop	
	
	
	return(Scores)
}

function _stopwords(string vector Keys, 
real scalar stopthrld, 
string vector PSW) {
	
	for(i = 1; i <= rows(Keys); i++) {
		Token = tokens(Keys[i,1])'
		if (i == 1) Tokens = Token
		else        Tokens = Tokens \ Token
	}
	
	Tokens = sort(Tokens, 1)
	
	info   = panelsetup(Tokens, 1)
	freq   = info[.,2] :- info[.,1] :+ 1
	grams  = Tokens[info[.,1]]
	
	// remove Public SW from data SW
	for (i = 1; i<= rows(PSW); i++) {
		grams  = subinword(grams,  PSW[i], "") 
	}	
	grams  = stritrim(grams)
	
	o = order(grams,1)
	info = panelsetup(grams[o], 1)
	pp = info[2,1],. \ info[rows(info),1], .   // rows with information
	grams = grams[o[|pp|]]
	freq  = freq[o[|pp|]]
	
	
	stopfreq = freq :> mean(freq) + sqrt(variance(freq))*stopthrld  
	o      = order(freq,1)            
	info      = panelsetup(stopfreq[o],1)
	pp = info[2, 1],. \ info[2, 2], .
	
	stopwords = grams[o[|pp|]]
	freqsw    = freq[o[|pp|]]
	orfreq    = revorder(order(freqsw,1))
	stopwords = stopwords[orfreq]
	freqsw    = strofreal(freqsw[orfreq])
	
	// Print Stop words Table
	
	ltitle   = strlen("Stop WordsFrequency")
	minl     = 3                         // min space between columns
	lstwds   = max(strlen(stopwords))    // length of stop words
	lfreqsw  = max(strlen(freqsw)   )    // length of stop words
	
	if (lstwds + lfreqsw <= ltitle) {
		n1 = abs(ltitle + minl - (lstwds + lfreqsw))
		h1 = minl
	}
	else {
		n1 = minl
		h1 = abs(ltitle + minl - (lstwds + lfreqsw))
	}
	
	printf(sprintf("{text}{center %f:{ul:Suggested Stop Words}}\n", h1+ltitle+12))
	printf(sprintf("{res}{space 6}Stop Words{space %f}Frequency\n", h1))
	printf(sprintf("{text}{space 6}{hline %f}\n", h1+ltitle))
	prt = sprintf("{res}{space 6}%%-%fuds%%%fuds\n", lstwds+n1, lfreqsw)
	for (i = 1; i <= rows(stopwords); i++) {
		printf(prt, stopwords[i], freqsw[i])
	}
	printf(sprintf("{text}{space 6}{hline %f}\n", h1+ltitle))
	
	return(stopwords)
}


void _timecomments(real scalar time) {
	if (time < 60) {
		printf("\n{txt}Aprox. computing time {col 25}{res}%5.0g minutes ", time)
	}
	else {
		if (mod(time/60,2) >= 1) {
			hour   = time/60 - mod(time/60,2) + 1
			minute = round(60*(mod(time/60,2) - 1))
		} 
		else {
			hour   = time/60 - mod(time/60,2) 
			minute = round(60*mod(time/60,2))
		}
		printf("\n{txt}Aprox. computing time {col 25}{res}%5.0g hours and %5.0g minutes\n", 
		hour, minute)
	}
	if (time <= 10) {
		printf("\n{txt}... This won't take long. Please, be patient\n")
	}
	else if (time > 10 & time <= 20) {
		printf("\n{txt}... you should buy a nice cup of coffee and come back right afterwards\n")
	}
	else if (time > 20 & time <= 40) {
		printf("\n{txt}... you should get a nice cup of coffee and have a nice conversation\n")
	}
	else if (time > 40 & time <= 90) {
		printf("\n{txt}... Coffee, a sweet treat, and pleasant company is what you need while you wait for this to finish\n")
	}
	else if (time > 90 & time <= 180) {
		printf("\n{txt}... Dude, you should probably work on something else. This may take a while\n")
	}
	else if (time > 180 & time <= 720) {
		printf("\n{txt}... Honestly, leave this thing running and come back tomorrow\n")
	}
	else if (time > 720 ) {
		printf("\n{txt}... You better use a server instead of your laptop. This will take a while...\n")
	}
	
	printf("\t{res}Progress of this stage:\n")
	
}




end
exit


/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:

use "c:\Users\wb384996\OneDrive - WBG\Global TSD-Core\projects\GMD consumption\03_working files\data/_pan1.dta", replace
duplicates drop key, force
replace key = subinstr(key, "?", "", .)
icpmatch key nori, create ssm(min) countr(PAN) year(1000) survey(TEST) replace



1.
2.
3.
Version Control:

curobs++
st_addobs(1)
st_store(curobs,(1,3,5), (idvar[i,1], usingidvar[usingkey,1], Similscore))
st_sstore(curobs,(2,4), (textvar[i,1], usingtextvar[usingkey,1]))	




save icpmatch, replace

use `icpmerge', clear 
keep if _merge == 1
keep `idvar' `txtvar' 

timer on 2
noi matchit `idvar' `txtvar' using "`mainpath'/icpinall.dta", ///
idu(icpcode) txtus(keyhole) override  similmethod(`similmethod')
timer off 2

tempvar rankscore
bysort `txtvar': egen `rankscore' = rank(similscore), field
keep if `rankscore' == 1
icplabels icpcode

save matchit, replace

noi timer list


*------------ Update Global file

dirlist "`manualmatched'"
local gftime = clock("`r(fdates)'`r(ftimes)'", "MDYhm")		

dirlist "`mainpath'\data\icpinall.dta"
local icpftime = clock("`r(fdates)'`r(ftimes)'", "MDYhm")

if (`gftime' > `icpftime') {
	noi disp as text "global file " as resu %tcDDmonCCYY_HH:mm `gftime'   
	noi disp as text "ICP file    " as resu %tcDDmonCCYY_HH:mm `icpftime' 
	
	tempfile userfile
	save `userfile'
	
	import excel using "`manualmatched'", ///
	firstrow case(lower) clear
	destring icpcode, replace 
	tempfile mglobal
	save `mglobal'
	
	local f = 1
	cap confirm file "`mainpath'/data/vintage/icpinall `date' `f'.dta"
	while (_rc == 0) {
		local ++f
		cap confirm file "`mainpath'/data/vintage/icpinall `date' `f'.dta"
	}
	
	copy "`mainpath'/data/icpinall.dta" ///
	"`mainpath'/data/vintage/icpinall `date' `f'.dta"
	use "`mainpath'/data/icpinall.dta", clear
	merge 1:1 addition nobs using `mglobal', update replace nogen
	drop oricode	
	
	duplicates drop icpcode keyhole, force   // this should be check for latest addition or any other rule. 
	save "`mainpath'/data/icpinall.dta", replace
	use `userfile', clear
}  // end of updating ICP in all file. 

