*Gerhard Ottehenning
*02/17/2020
*input(s): SAIS Election Poll_ Democratic Primary (Responses).xlsx

local time=c(current_date)
global log_file "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Log Files"
log using "$log_file/1_clean data_`time'.txt", text append
********************************************************************************

********************************************************************************

global data "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Raw Data"
global output "/Users/laurieottehenning/Documents/personal/G/SAIS/Spring 2020/Club/Data Visualization/SAIS Election Poll/Stata/Tables"

*************************
*	Step 1: Clean 	    *
*************************

import excel "$data/SAIS Election Poll_ Democratic Primary (Responses).xlsx", sheet("Form Responses 1") firstrow clear
	
//1.1: Fix variables

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

*************************
*	Step 2: Analysis    *
*************************

//2.1: Table - Support for Democratic Candidates by Concentration

preserve
	
	**Will remove undecided voters
		tab support_dem
		drop if support_dem=="Undecided"

	*A. All variables
		foreach var of varlist exp_grad_yr support_dem ifdem_notvote ///
			mostlikely_dem {
			tab `var'
			}
			
	*B. Cross Tabs
		forvalues cand=1/6 {
			mat CAND`cand' = .
			}
			
		**1. Fill table			
			forvalues cand=1/6 {
			forvalues cont = 1/8 {
				di "Concentration:`cand'/Candidate Support:`cont'"
				count if e_concent==`cont' & e_support_dem==`cand'
					scalar num = r(N)
				di "Total Concentration:`cont'"
				count if e_concent==`cont'
					scalar tot = r(N)
				mat CAND`cand' = CAND`cand'\((num/tot)*100)
				}
			}
			
		**2. Merge table
			mat cand_table = CAND1, CAND2, CAND3, CAND4, CAND5, CAND6
			matselrc cand_table cand_table, r(2/9)
			mat list cand_table
			
		**3. Export to excel
			putexcel set "$output/Tables.xlsx", modify sheet("Table 1")
			putexcel B3=matrix(cand_table)
restore 
	
//2.2: Table - Most likely Democratic Candidate by Concentration

	*A. Cross tabls
		forvalues cand=1/6 {
			mat CAND`cand' = .
			}
			
		**1. Fill table			
			forvalues cand=1/6 {
			forvalues cont = 1/8 {
				di "Concentration:`cand'/Candidate Support:`cont'"
				count if e_concent==`cont' & e_mostlikely_dem==`cand'
					scalar num = r(N)
				di "Total Concentration:`cont'"
				count if e_concent==`cont'
					scalar tot = r(N)
				mat CAND`cand' = CAND`cand'\((num/tot)*100)
				}
			}			

		**2. Merge table
			mat mostlikely_table = CAND1, CAND2, CAND3, CAND4, CAND5, CAND6
			matselrc mostlikely_table mostlikely_table, r(2/9)
			mat list mostlikely_table
			
		**3. Export to excel
			putexcel set "$output/Tables.xlsx", modify sheet("Table 2")
			putexcel B3=matrix(mostlikely_table)
			
//2.3: Table - Likelihood that Trump Wins by Concentration

		forvalues m=1/5 {
			mat MOST`m' = .
			}
			
		**1. Fill table			
			forvalues m=1/5 {
			forvalues cont = 1/8 {
				di "Concentration:`cand'/Candidate Support:`cont'"
				count if e_concent==`cont' & chance_trump_win==`m'
					scalar num = r(N)
				di "Total Concentration:`cont'"
				count if e_concent==`cont'
					scalar tot = r(N)
				mat MOST`m' = MOST`m'\((num/tot)*100)
				}
			}			

		**2. Merge table
			mat chn_win = MOST1, MOST2, MOST3, MOST4, MOST5
			matselrc chn_win chn_win, r(2/9)
			mat list chn_win
			
		**3. Export to excel
			putexcel set "$output/Tables.xlsx", modify sheet("Table 3")
			putexcel B3=matrix(chn_win)
