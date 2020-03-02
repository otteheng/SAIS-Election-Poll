*Gerhard Ottehenning
*02/27/2020
*input(s): SAIS Election Poll_ Democratic Primary (Responses).xlsx

local time=c(current_date)
global log_file "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Log Files"
log using "$log_file/2_clean data_pie chart_`time'.txt", text append
********************************************************************************

********************************************************************************

global data "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Raw Data"
global output "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Tables"

*************************
*	Step 1: Clean 	    *
*************************

import excel "$data/SAIS Election Poll_ Democratic Primary (Responses).xlsx", sheet("Form Responses 1") firstrow clear

	*A. Change variable names
		ren *, lower
		ren timestamp tstamp
		ren concentration concent 
		ren degreeprogramegmamippp deg_prog 
		ren expectedgraduationyear exp_grad_yr
		ren whowouldyousupportforthede support_dem 
		ren forwhatreasonsdoyoubeliev reason_longansw
		ren ifyourdemocraticcandidateof ifdem_notvote
		ren whodoyouthinkisthemostlik mostlikely_dem 
		ren asofrightnowwhatdoyouthi chance_trump_win	
		
	*B. Clean Concentration
		tab concent
		
		**1. Change to upper case
			replace concent = upper(concent)
			replace concent = strtrim(concent)
			tab concent
			
		**2. Change names
			replace concent = "ERE" if concent=="ENERGY, RESOURCES, AND ENVIRONMENT"
			replace concent = "STRATEGIC STUDIES" if concent=="STRAT"
			replace concent = "AFP" if concent=="AMERICAN FOREIGN POLICY"
			replace concent = "CHINA STUDIES" if concent=="CHINA"
			replace concent = "IDEV" if concent=="INTERNATIONAL DEVELOPMENT"
			replace concent = "INTERNATIONAL POLITICAL ECONOMY" if concent=="IPE"
			replace concent = "LASP" if concent=="LATIN AMERICAN STUDIES"
			replace concent = "CONFLICT MANAGEMENT" if concent=="CM"
			replace concent = "EUROPEAN AND EURASIAN STUDIES" if ///
				inlist(concent, "EUROPEAN & EURASIAN STUDIES", ///
				"EUROPEAN EURASIAN STUDIES", "EUROPEAN STUDIES")
				
		**3. Drop bad entries
			drop if strpos(concent, "CUCK")
			tab concent 
			replace concent = proper(concent) if length(concent)>4
			
		**4. Combine concentrations
			replace concent = "Conflict Management/ILaw" if ///
				inlist(concent, "Conflict Management", "International Law And Organizations", ///
				"International Law")
			replace concent = "IPE/AFP/Global Theory & History" if ///
				inlist(concent, "International Political Economy", "AFP", ///
				"Global Theory And History")
			replace concent = "China/Japan/Southeast Asia Studies" if ///
				inlist(concent, "China Studies", "Japan Studies", ///
				"Southeast Asia Studies", "Southeast Asia")
			replace concent = "European/Eurasian/Middle East/African Studies" if ///
				inlist(concent, "European And Eurasian Studies", "Middle East Studies", ///
				"African Studies")
			
	*C. Clean deg_prog
		tab deg_prog
		replace deg_prog = upper(deg_prog)
		replace deg_prog = strtrim(deg_prog)
		tab deg_prog
		
	*D. Encode values
		
		**1. Concent
			encode concent, gen(e_concent) 

		**2. Candidates
			label define candidates 1 "Amy Klobuchar" 2 "Bernie Sanders" 3 "Elizabeth Warren" ///
				4 "Joe Biden" 5	"Mike Bloomberg" 6 "Pete Buttigieg"
			foreach var of varlist support_dem mostlikely_dem {
				encode `var', gen(e_`var') label(candidates)
				}

	*E. Keep variables needed for Pie Chart
		keep support_dem ifdem_notvote mostlikely_dem chance_trump_win
		
//1.2: Export

	*A. Export to same location as other Tables
		export excel using "$output/Pie Charts.xlsx", replace firstrow(variables)
		
