*************************************************************************
* 						PART E. Generate Plots							*			
*************************************************************************

*----------------------------------
*generating age-specific plots
*----------------------------------

foreach age of numlist 1/3 {

	use `MORTALITY_TEMP', clear
	merge m:1 adm1_code using "`tercile'"
	drop if ytile==.

	foreach y of numlist 1/3 {
		foreach T of numlist 1/3 {
			count if ytile == `y' & ttile == `T' & agegroup==`age'
			local obs_`y'_`T'_`age' = r(N)
		}
	}

	collapse (mean) loggdppc_adm1_avg lr_tavg_GMFD_adm1_avg, by(ytile ttile)
	

	*initialize
	gen tavg_poly_1_GMFD =.
	gen deathrate_w99 =.
			

	local ii = 1

	*loop through quintiles
	foreach y of numlist 1/3 {
		foreach T of numlist 1/3 {
			

			preserve
			keep if ytile == `y' & ttile == `T'

			foreach var in "loggdppc_adm1_avg" "lr_tavg_GMFD_adm1_avg" {
				loc zvalue_`var' = `var'[1]
			}

			*obs	
			local min = `x_min'
			local max = `x_max'
			local obs = `max' - `min' + 1
			local omit = 20

			drop if _n > 0
			set obs `obs'
			replace tavg_poly_1_GMFD = _n + `min' - 1

			*----------------------------------
			*Polynomial (4) 
			*----------------------------------

			estimate use "`STER'/Agespec_interaction_response.ster"
			estimates

			*uninteracted terms
			local line = "_b[`age'.agegroup#c.tavg_poly_1_GMFD]*(tavg_poly_1_GMFD-`omit')"
			foreach k of numlist 2/`o' {
				*replace tavg_poly_`k'_GMFD = tavg_poly_1_GMFD ^ `k'
				local add = "+ _b[`age'.agegroup#c.tavg_poly_`k'_GMFD]*(tavg_poly_1_GMFD^`k' - `omit'^`k')"
				local line "`line' `add'"
				}

			*lgdppc and Tmean at the tercile mean
			foreach var in "loggdppc_adm1_avg" "lr_tavg_GMFD_adm1_avg" {
				loc z = `zvalue_`var''
				foreach k of numlist 1/`o' {
					*replace tavg_poly_`k'_GMFD = tavg_poly_1_GMFD ^ `k'
					local add = "+ _b[`age'.agegroup#c.`var'#c.tavg_poly_`k'_GMFD] * (tavg_poly_1_GMFD^`k' - `omit'^`k') * `z'"
					local line "`line' `add'"
					}
				}

			di "`line'"
			predictnl yhat_poly`o'_pop = `line', se(se_poly`o'_pop) ci(lowerci_poly`o'_pop upperci_poly`o'_pop)



			*----------------------------------
			* Clipping
			*----------------------------------

			if `yclip' == 1 {
				foreach var of varlist yhat_poly`o'_pop lowerci_poly`o'_pop upperci_poly`o'_pop {
					replace `var' = `yclipmax_a`age'' if `var' > `yclipmax_a`age''
					replace `var' = `yclipmin_a`age'' if `var' < `yclipmin_a`age''
				}
			}


			* graph
			local graph_`ii' "(line yhat_poly4_pop tavg_poly_1_GMFD, lc(black) lwidth(medthick)) (rarea lowerci_poly4_pop upperci_poly4_pop tavg_poly_1_GMFD, col(gray%25) lwidth(none))"
			display("saved `graph_`ii'' `ii'")

				

			display("1 = `graph_1'")
			local graph_conc = "`graph_1'"


			*----------------------------------
			* Set axes and titles
			*----------------------------------

			loc ytit "Deaths per 100k"
			loc xtit "Temperature (°C)"
			loc empty ""
			loc space "" ""

			if `ii' == 7 | `ii' == 4 {
				loc ylab "ytitle(`ytit') ylabel(, labsize(small))"
				loc xlab "xtitle(`space') xlabel(none) xscale(off) fysize(25.2)"
			} 

			if `ii' == 8 | `ii' == 5 {
				loc ylab "ytitle(`space') ylabel(none) yscale(off) fxsize(38)"
				loc xlab "xtitle(`space') xlabel(none) xscale(off) fysize(25.2)"
			} 

			if `ii' == 9 | `ii' == 6 {
				loc ylab "ytitle(`ytit') ylabel(, labsize(small)) yscale(alt)"
				loc xlab "xtitle(`space') xlabel(none) xscale(off) fysize(25.2)"
			} 

			if `ii' == 1 {
				loc ylab "ytitle(`ytit') ylabel(, labsize(small))"
				loc xlab "xtitle(`xtit') xlabel(`x_min'(`x_int')35, labsize(small))"
			}

			if `ii' == 2 {
				loc ylab "ytitle(`space') ylabel(none) yscale(off) fxsize(38)"
				loc xlab "xtitle(`xtit') xlabel(`x_min'(`x_int')35, labsize(small))"
			}

			if `ii' == 3 {
				loc ylab "ytitle(`ytit') ylabel(, labsize(small)) yscale(alt)"
				loc xlab "xtitle(`xtit') xlabel(`x_min'(`x_int')35, labsize(small))"
			}


			*----------------------------------
			* Plot charts
			*----------------------------------

			if `ycommon' == 1 {
				twoway `graph_conc' ///
				, yline(0, lcolor(red%50) lwidth(vvthin)) name(matrix_Y`y'_T`T'_noSE, replace) ///
				`xlab' `ylab' plotregion(icolor(white) lcolor(black)) ///
				graphregion(color(white)) legend(off) ///						
				text(`a`age'_y' `a_x' "{bf:%POP 2010: `a`age'_Y`y'T`T'_g_2010'}", place(ne) size(small)) ///
				text(`a`age'_y' `a_x' "{bf:%POP 2100: `a`age'_Y`y'T`T'_g_2100'}", place(se) color(gray) size(small))
			}
			else {
				twoway `graph_conc' ///
				, yline(0, lcolor(gs5) lwidth(vthin)) name(matrix_Y`y'_T`T'_noSE, replace) ///
				`xlab' `ylab' plotregion(icolor(white) lcolor(black)) ///
				graphregion(color(white)) legend(off) 
			}

			restore

			loc ii = `ii' + 1
		}		
	}

	* label chart titles
    if `age' == 1 {
    	loc agetit "< 5"
    	loc fig "D1"
    }
     
    if `age' == 2 {
    	loc agetit "5 - 64"
    	loc fig "D2"
    } 
    if `age' == 3 {
    	loc agetit "> 64"
    	loc fig "1"
    }

	
	if `ycommon' == 1 {
		graph combine matrix_Y3_T1_noSE matrix_Y3_T2_noSE matrix_Y3_T3_noSE ///
		matrix_Y2_T1_noSE matrix_Y2_T2_noSE matrix_Y2_T3_noSE ///
		matrix_Y1_T1_noSE matrix_Y1_T2_noSE matrix_Y1_T3_noSE, ///
		plotregion(color(white)) graphregion(color(white)) cols(3) ycommon ///
		l2title("Poor {&rarr} Rich") b2title("Cold {&rarr} Hot") imargin(vsmall) ///
		title("Age `agetit' Adaptation Model Response Functions", size(medsmall)) 
		graph export "`OUTPUT'/Figure_`fig'_array_plots/Age`age'_interacted_response_array_GMFD`suffix'.pdf", replace
	}
	else {
		graph combine matrix_Y3_T1_noSE matrix_Y3_T2_noSE matrix_Y3_T3_noSE ///
		matrix_Y2_T1_noSE matrix_Y2_T2_noSE matrix_Y2_T3_noSE ///
		matrix_Y1_T1_noSE matrix_Y1_T2_noSE matrix_Y1_T3_noSE, ///
		plotregion(color(white)) graphregion(color(white)) cols(3) rows(3) xcommon ///
		l2title("Poor {&rarr} Rich") b2title("Cold {&rarr} Hot") ///
		title("Age `agetit' Adaptation Model Response Functions", size(medsmall)) 
		graph export "`OUTPUT'/Figure_`fig'_array_plots/Age`age'_interacted_response_array_GMFD`suffix'_ydiff.pdf", replace
	}
	
	graph drop _all
	
}
