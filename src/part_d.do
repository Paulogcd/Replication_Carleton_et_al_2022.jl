
*generating age-specific population figures for globe in 2010 and 2100
preserve

    use "`DATA'/2_cleaned/covar_pop_count.dta", clear
    rename (loggdppc tmean) (lgdppc Tmean)

    gen ytile = .
    gen ttile = .
    replace ytile = 1 if lgdppc<=`yc1'
    replace ytile = 2 if lgdppc>`yc1' & lgdppc<=`yc2'
    replace ytile = 3 if lgdppc>`yc2'
    replace ttile = 1 if Tmean<=`tc1'
    replace ttile = 2 if Tmean>`tc1' & Tmean<=`tc2'
    replace ttile = 3 if Tmean>`tc2'

gen popshare2 = 1 - popshare1 - popshare3
gen pop1 = popshare1*pop
gen pop2 = popshare2*pop
gen pop3 = popshare3*pop
drop if popshare2<0
"'

collapse (sum) pop pop1 pop2 pop3, by(ytile ttile year)
bysort year: egen pop_tot = total(pop)
bysort year: egen pop1_tot = total(pop1)
bysort year: egen pop2_tot = total(pop2)
bysort year: egen pop3_tot = total(pop3)
bysort year: gen pop_per = (pop/pop_tot)*100
bysort year: gen pop1_per = (pop1/pop1_tot)*100
bysort year: gen pop2_per = (pop2/pop2_tot)*100
bysort year: gen pop3_per = (pop3/pop3_tot)*100


* gen age spec pop shares
sort year ytile ttile
foreach age of numlist 1/3 {
	local i = 1
	foreach y of numlist 1/3 {
		foreach t of numlist 1/3 {
			local a`age'_Y`y'T`t'_g_2010 `=round(pop`age'_per[`i'],.50)'
			local a`age'_Y`y'T`t'_g_2100 `=round(pop`age'_per[`=`i'+9'],.50)'
			local i = `i' + 1
		}
	}
}

* gen total age shares
local i = 1
sort year ytile ttile
foreach y of numlist 1/3 {
    foreach t of numlist 1/3 {
        local a_Y`y'T`t'_g_2010 = round(pop_per[`i'],.50)
        local a_Y`y'T`t'_g_2100 = round(pop_per[`=`i'+9'],.50)
        local i = `i' + 1
    }
}

restore
