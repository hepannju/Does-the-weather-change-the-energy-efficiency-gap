/*

cd "G:\climate and air conditioner\"


****************climate projection
***temperature
clear all

import delimited "projection\CMIP5_US_county\result_tas.csv", clear

rename fip fips_county

drop if fips_county=="#N/A"

destring fips_county, replace
tostring fips_county, format(%05.0f) replace

reshape long v, i(fip polyname_2) j(date)

rename v TEMP

replace TEMP=TEMP-273.15 //convert K to C

save "projection temp.dta", replace

***precipitation

clear all

import delimited "projection\CMIP5_US_county\result_pr.csv", clear

rename fip fips_county

drop if fips_county=="#N/A"

destring fips_county, replace
tostring fips_county, format(%05.0f) replace

reshape long v, i(fip polyname_2) j(date)

rename v PRCP

replace PRCP=PRCP*86400 //convert kg/(s*m^2) to mm/day

save "projection prcp.dta", replace

***wind speed
clear all

import delimited "projection\CMIP5_US_county\result_sfcWind.csv", clear

rename fip fips_county

drop if fips_county=="#N/A"

destring fips_county, replace
tostring fips_county, format(%05.0f) replace

reshape long v, i(fip polyname_2) j(date)

rename v WDSP

*replace temp=temp-273.15

save "projection wdsp.dta", replace

***relative humidity
clear all

import delimited "projection\CMIP5_US_county\result_rhs.csv", clear

rename fip fips_county

drop if fips_county=="#N/A"

destring fips_county, replace
tostring fips_county, format(%05.0f) replace

reshape long v, i(fip polyname_2) j(date)

rename v RH

*replace temp=temp-273.15

save "projection rh.dta", replace


***merge data
clear all

use "projection temp.dta", clear

merge 1:1 fips_county date using "projection prcp.dta"
drop _merge

merge 1:1 fips_county date using "projection wdsp.dta"
drop _merge

merge 1:1 fips_county date using "projection rh.dta"
drop _merge

gen YEAR=2030
gen MONTH=1
gen DAY=1
gen date_new=mdy(MONTH, DAY, YEAR)+date-3
replace YEAR=year(date_new)
replace MONTH=month(date_new)
replace DAY=day(date_new)
replace YEAR=2050 if YEAR==2031
replace YEAR=2080 if YEAR==2032
replace YEAR=2100 if YEAR==2033

tostring YEAR MONTH DAY, replace
gen week_end=YEAR+MONTH+DAY
destring YEAR MONTH DAY, replace

drop date date_new
gen date=mdy(MONTH, DAY, YEAR)
gen dow=dow(date)

gen no_week=int((date-25573+7)/7)

foreach var of varlist TEMP WDSP PRCP RH {
egen `var'_county_w=mean(`var'), by(no_week YEAR fips_county)
}

gen week_count=1
egen count_week=count(week_count), by(no_week YEAR fips_county)
gen CDD=max(TEMP*1.8+32-70, 0)
gen HDD=max(70-TEMP*1.8-32, 0)

gen CDD65=max(TEMP*1.8+32-65, 0)
gen HDD65=max(65-TEMP*1.8-32, 0)

egen HDD_w=sum(HDD/count_week*7), by(no_week YEAR fips_county)
egen CDD_w=sum(CDD/count_week*7), by(no_week YEAR fips_county)
gen totalDD_w=HDD_w+CDD_w

egen HDD65_w=sum(HDD65/count_week*7), by(no_week YEAR fips_county)
egen CDD65_w=sum(CDD65/count_week*7), by(no_week YEAR fips_county)
gen totalDD65_w=HDD65_w+CDD65_w

keep if dow==6

keep YEAR MONTH DAY fips_county week_end *_w

*cd "G:\climate and air conditioner\"

save "air quality county week projection.dta", replace



****************Political preference
clear all

import delimited "countypres_2000-2020.csv", clear

rename county_fips fips_county

replace fips_county="" if fips_county=="NA"
destring fips_county, replace
tostring fips_county, format(%05.0f) replace

replace candidatevotes="" if candidatevotes=="NA"
replace totalvotes="" if totalvotes=="NA"
destring candidatevotes totalvotes, replace

drop if totalvotes==. | totalvotes==0

gen _democrat_support_p=candidatevotes/totalvotes if party=="DEMOCRAT"
egen democrat_support_p=max(_democrat_support_p), by(year fips_county)

egen vote_max=max(candidatevotes), by(year fips_county)

keep if candidatevotes==vote_max

keep year fips_county party democrat_support_p

rename year year_election

duplicates drop year_election fips_county, force

save "political preference.dta", replace


****************ACS socio-economic characteristics
*****2015-2019
***race
clear all

import delimited "maps\race_2019_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

keep fips_county b02001e1 b02001e2 b02001e3 b02001e5

rename b02001e1 pop_total
rename b02001e2 pop_white
rename b02001e3 pop_black
rename b02001e5 pop_asian

save "race 2015_2019.dta", replace

***education
clear all

import delimited "maps\education_2019_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b15003e1 pop25_total

egen pop25_highschool=rowtotal(b15003e17 b15003e18 b15003e19 b15003e20 b15003e21 b15003e22 b15003e23 b15003e24 b15003e25)

egen pop25_bachelor=rowtotal(b15003e22 b15003e23 b15003e24 b15003e25)

keep fips_county pop25*

save "education 2015_2019.dta", replace


***income
clear all

import delimited "maps\income_2019_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b19001e1 total_hh

rename b19013e1 median_hhincome

rename b19025e1 aggregated_hhincome

keep fips_county total_hh *_hhincome

save "income 2015_2019.dta", replace

***age
clear all

import delimited "maps\age_2019_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b01002e1 median_age

keep fips_county *_age

save "age 2015_2019.dta", replace

***housing
clear all

import delimited "maps\housing_2019_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b25018e1 median_room
rename b25003e2 units_owner
rename b25003e3 units_renter
rename b25040e4 units_electricity
rename b25040e1 units_total

keep fips_county *_room units_*

save "housing 2015_2019.dta", replace

*****2010-2014
***race
clear all

import delimited "maps\race_2014_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

keep fips_county b02001e1 b02001e2 b02001e3 b02001e5

rename b02001e1 pop_total
rename b02001e2 pop_white
rename b02001e3 pop_black
rename b02001e5 pop_asian

save "race 2010_2014.dta", replace

***education
clear all

import delimited "maps\education_2014_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b15003e1 pop25_total

egen pop25_highschool=rowtotal(b15003e17 b15003e18 b15003e19 b15003e20 b15003e21 b15003e22 b15003e23 b15003e24 b15003e25)

egen pop25_bachelor=rowtotal(b15003e22 b15003e23 b15003e24 b15003e25)

keep fips_county pop25*

save "education 2010_2014.dta", replace


***income
clear all

import delimited "maps\income_2014_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b19013e1 median_hhincome

rename b19025e1 aggregated_hhincome

keep fips_county *_hhincome

save "income 2010_2014.dta", replace

***age
clear all

import delimited "maps\age_2014_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b01002e1 median_age

keep fips_county *_age

save "age 2010_2014.dta", replace

***housing
clear all

import delimited "maps\housing_2014_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b25018e1 median_room
rename b25003e2 units_owner
rename b25003e3 units_renter
rename b25040e4 units_electricity
rename b25040e1 units_total

keep fips_county *_room units_*

save "housing 2010_2014.dta", replace


*****2008-2012
***race
clear all

import delimited "maps\race_2012_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

keep fips_county b02001e1 b02001e2 b02001e3 b02001e5

rename b02001e1 pop_total
rename b02001e2 pop_white
rename b02001e3 pop_black
rename b02001e5 pop_asian

save "race 2008_2012.dta", replace

***education
clear all

import delimited "maps\education_2012_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b15003e1 pop25_total

egen pop25_highschool=rowtotal(b15003e17 b15003e18 b15003e19 b15003e20 b15003e21 b15003e22 b15003e23 b15003e24 b15003e25)

egen pop25_bachelor=rowtotal(b15003e22 b15003e23 b15003e24 b15003e25)

keep fips_county pop25*

save "education 2008_2012.dta", replace


***income
clear all

import delimited "maps\income_2012_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b19013e1 median_hhincome

rename b19025e1 aggregated_hhincome

keep fips_county *_hhincome

save "income 2008_2012.dta", replace

***age
clear all

import delimited "maps\age_2012_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b01002e1 median_age

keep fips_county *_age

save "age 2008_2012.dta", replace

***housing
clear all

import delimited "maps\housing_2012_ACS.txt", encoding(ISO-8859-9) clear

gen fips_county=substr(geoid, 8, 5)

rename b25018e1 median_room
rename b25003e2 units_owner
rename b25003e3 units_renter
rename b25040e4 units_electricity
rename b25040e1 units_total

keep fips_county *_room units_*

save "housing 2008_2012.dta", replace



*************all the socio-economic characteristics
clear all

use "race 2015_2019.dta", clear

merge 1:1 fips_county using "education 2015_2019.dta"

drop _merge

merge 1:1 fips_county using "income 2015_2019.dta"

drop _merge

merge 1:1 fips_county using "age 2015_2019.dta"

drop _merge

merge 1:1 fips_county using "housing 2015_2019.dta"

drop _merge

save "ACS 2015_2019.dta", replace


clear all

use "race 2010_2014.dta", clear

merge 1:1 fips_county using "education 2010_2014.dta"

drop _merge

merge 1:1 fips_county using "income 2010_2014.dta"

drop _merge

merge 1:1 fips_county using "age 2010_2014.dta"

drop _merge

merge 1:1 fips_county using "housing 2010_2014.dta"

drop _merge

save "ACS 2010_2014.dta", replace


clear all

use "race 2008_2012.dta", clear

merge 1:1 fips_county using "education 2008_2012.dta"

drop _merge

merge 1:1 fips_county using "income 2008_2012.dta"

drop _merge

merge 1:1 fips_county using "age 2008_2012.dta"

drop _merge

merge 1:1 fips_county using "housing 2008_2012.dta"

drop _merge

save "ACS 2008_2012.dta", replace


clear all

use "ACS 2008_2012.dta", clear
gen year=2008
append using "ACS 2008_2012.dta"
replace year=2009 if year==.

append using "ACS 2010_2014.dta"
replace year=2010 if year==.
append using "ACS 2010_2014.dta"
replace year=2011 if year==.
append using "ACS 2010_2014.dta"
replace year=2012 if year==.
append using "ACS 2010_2014.dta"
replace year=2013 if year==.
append using "ACS 2010_2014.dta"
replace year=2014 if year==.

append using "ACS 2015_2019.dta"
replace year=2015 if year==.
append using "ACS 2015_2019.dta"
replace year=2016 if year==.
append using "ACS 2015_2019.dta"
replace year=2017 if year==.
append using "ACS 2015_2019.dta"
replace year=2018 if year==.
append using "ACS 2015_2019.dta"
replace year=2019 if year==.

save "ACS socio-economic.dta", replace


****************energy star
clear all

import excel "variable list.xlsx", sheet("energy star") firstrow

save "energy star.dta", replace


****************electricity price
*state abbreviation
clear all

import excel "variable list.xlsx", sheet("state abbreviation") firstrow clear

drop state_match

save "state abbreviation.dta", replace

*monthly
clear all

import excel "variable list.xlsx", sheet("electricity price monthly") firstrow clear

tostring eprice*, replace

reshape long eprice, i(type year month) j(state) string

replace eprice="" if eprice=="--" | strpos(eprice, "NM")

destring eprice, replace

keep if type=="Residential"

replace month=month+1
replace year=year+1 if month==13
replace month=1 if month==13

merge m:1 state using "state abbreviation.dta"

drop if _merge!=3

drop _merge

drop if fips_state_descr==""

egen eprice_m=mean(eprice), by(fips_state_descr)

egen eprice_y_m=mean(eprice), by(fips_state_descr year)

save "electricity price.dta", replace 


*annual
clear all

import excel "variable list.xlsx", sheet("electricity price annual") firstrow clear

rename Year year

rename State fips_state_descr

keep if IndustrySectorCategory=="Total Electric Industry"

keep fips_state_descr year Residential

replace year=year+1

egen Residential_m=mean(Residential), by(fips_state_descr)

save "electricity price annual.dta", replace 


****************support for regulating CO2 as a pollutant and belief that global warming is happening (2013)
clear all

import excel "41558_2015_BFnclimate2583_MOESM432_ESM.xls", sheet("nclimate2583-s3") firstrow

keep County_FIPS x*

rename County_FIPS fips_county

tostring fips_county, format(%05.0f) replace

save "climate attitude.dta", replace


****************gsod station coordination data
clear all

use "GSOD\US climate 1996 to 1999.dta", clear
append using "GSOD\US climate 2000 to 2005.dta"
append using "GSOD\US climate 2006 to 2012.dta"
append using "GSOD\US climate 2013 to 2019.dta"

keep STNID NAME LATITUDE LONGITUDE ELEVATION

duplicates drop *, force

save "gsod stations.dta", replace



****************fips code of counties
clear all

use "all_products_final.dta", clear

keep fips_state_code fips_state_descr fips_county_code fips_county_descr

duplicates drop *, force

drop if fips_county_descr==""

tostring fips_state_code, format(%02.0f) replace

tostring fips_county_code, format(%03.0f) replace

gen fips_county=fips_state_code+fips_county_code



****************convert match list into .dta

clear all

import dbase using "G:\climate and air conditioner\maps\climate_station_county_100km.dbf", clear

rename *, lower

destring latitude intptlat longitude intptlon, replace

gen distance=0.5-cos((latitude-intptlat)*(c(pi)/180))/2+cos(intptlat*(c(pi)/180))*cos(latitude*(c(pi)/180))* (1-cos((longitude-intptlon)*(c(pi)/180)))/2
replace distance=12742*asin(sqrt(distance))

keep stnid geoid distance

rename geoid fips_county

rename stnid STNID

save "climate station to county 100km.dta", replace


****************calculate climate data by fips county
clear all

use "GSOD\US climate 1996 to 1999.dta", clear
append using "GSOD\US climate 2000 to 2005.dta"
append using "GSOD\US climate 2006 to 2012.dta"
append using "GSOD\US climate 2013 to 2019.dta"

joinby STNID using "climate station to county 100km.dta"
*joinby STNID using "climate station to county 50km.dta"


foreach var of varlist TEMP DEWP VISIB WDSP PRCP RH {
egen `var'_county=mean(`var'), by(YEAR MONTH DAY fips_county)
*egen `var'_county=wtmean(`var'), weight(1/distance^2) by(YEAR MONTH DAY fips_county)
}

keep YEAR MONTH DAY fips_county *_county

duplicates drop YEAR MONTH DAY fips_county, force

save "climate county.dta", replace


clear all

use "climate county.dta", clear

tostring fips_county, format(%05.0f) replace

gen date=mdy(MONTH,DAY,YEAR)
gen week=week(date)
gen dow=dow(date)

tostring YEAR, replace
tostring MONTH, format(%02.0f) replace
tostring DAY, format(%02.0f) replace

gen week_end=YEAR+MONTH+DAY

destring YEAR MONTH DAY week_end, replace

gen no_week=int((date-13148)/7)

foreach var of varlist TEMP_county DEWP_county VISIB_county WDSP_county PRCP_county RH_county {
egen `var'_w=mean(`var'), by(no_week YEAR fips_county)
}

egen TEMP_county_max_w=max(TEMP_county), by(no_week YEAR fips_county)
egen TEMP_county_min_w=min(TEMP_county), by(no_week YEAR fips_county)

gen week_count=1
egen count_week=count(week_count), by(no_week YEAR fips_county)
gen CDD=max(TEMP_county*1.8+32-70, 0)
gen HDD=max(70-TEMP_county*1.8-32, 0)
gen CDD65=max(TEMP_county*1.8+32-65, 0)
gen HDD65=max(65-TEMP_county*1.8-32, 0)

egen HDD_w=sum(HDD/count_week*7), by(no_week YEAR fips_county)
egen CDD_w=sum(CDD/count_week*7), by(no_week YEAR fips_county)
gen totalDD_w=HDD_w+CDD_w

egen HDD65_w=sum(HDD65/count_week*7), by(no_week YEAR fips_county)
egen CDD65_w=sum(CDD65/count_week*7), by(no_week YEAR fips_county)
gen totalDD65_w=HDD65_w+CDD65_w

keep if dow==6

keep YEAR MONTH DAY fips_county week_end *_w

save "climate county week.dta", replace


*****climate in the week before
*0
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

rename *_w *_w_0

save "climate county week 0.dta", replace

*-1
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date+7
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

save "climate county week -1.dta", replace

*-2
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date+7*2
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

rename *_w *_w_1

save "climate county week -2.dta", replace

*-3
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date+7*3
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

rename *_w *_w_2

save "climate county week -3.dta", replace

*-4
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date+7*4
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

rename *_w *_w_3

save "climate county week -4.dta", replace

*-5
clear all

use "climate county week.dta", clear

gen date=mdy(MONTH,DAY,YEAR)
replace date=date+7*5
replace MONTH=month(date)
replace DAY=day(date)
replace YEAR=year(date)
replace week_end=YEAR*10000+MONTH*100+DAY

drop YEAR MONTH DAY date

rename *_w *_w_4

save "climate county week -5.dta", replace


*****HDD & CDD, 1996-2005
clear all

use "climate county week.dta", clear

drop if YEAR>=2006

egen HDD_1996_2005=mean(HDD_w), by(fips_county)
egen CDD_1996_2005=mean(CDD_w), by(fips_county)
gen totalDD_1996_2005=HDD_1996_2005+CDD_1996_2005

duplicates drop fips_county, force

keep fips_county HDD_1996_2005 CDD_1996_2005 totalDD_1996_2005

save "CDD HDD by county 1996-2005.dta", replace

*/

/*
*******************small sample
clear all

use "all_products_final.dta", clear

set seed 12345

sample 1000, count

save "all_products_final small sample.dta", replace


clear all

use "all_products_final small sample.dta", clear

tostring fips_state_code, format(%02.0f) replace

tostring fips_county_code, format(%03.0f) replace

gen fips_county=fips_state_code+fips_county_code

keep fips_county week_end

joinby fips_county week_end using "climate county week 0.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -1.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -2.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -3.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -4.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -5.dta", unmatched(master)

drop _merge

save "climate county week small sample.dta", replace
*/

*******************regression
clear all

use "all_products_final small sample.dta", clear

*expand units

gen upc_descr_trim=subinstr(upc_descr, " ", "", .)

drop _merge

merge m:1 upc_descr_trim using "energy star.dta"

drop if upc_descr_trim==""

drop _merge

tostring fips_state_code, format(%02.0f) replace

tostring fips_county_code, format(%03.0f) replace

gen fips_county=fips_state_code+fips_county_code

merge m:1 fips_county using "CDD HDD by county 1996-2005.dta"

drop _merge

merge m:1 fips_county year using "ACS socio-economic.dta"

drop if _merge==2

drop _merge

gen year_election=2020
replace year_election=2016 if year<2016
replace year_election=2012 if year<2012
replace year_election=2008 if year<2008

merge m:1 year_election fips_county using "political preference.dta"

drop if _merge==2

drop _merge

/*
joinby fips_county week_end using "climate county week 0.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -1.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -2.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -3.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -4.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -5.dta", unmatched(master)

drop _merge
*/

joinby fips_county week_end using "climate county week small sample.dta", unmatched(master)

drop _merge

tostring week_end, replace

*gen year=substr(week_end,1,4)
gen month=substr(week_end,5,2)
gen day=substr(week_end,7,2)
destring month day, replace
gen date=mdy(month,day,year)
gen week=week(date)

merge m:1 fips_county using "climate attitude.dta"

drop if _merge==2

drop _merge

merge m:1 fips_state_descr year month using "electricity price.dta"

drop if _merge==2

drop _merge

merge m:1 fips_state_descr year using "electricity price annual.dta"

drop if _merge==2

drop _merge

gen lnprice=ln(price)

gen TEMPcounty_w2=TEMP_county_w^2
gen TEMP10_county_w=TEMP_county_w/10
gen TEMP10_county_w2=TEMP10_county_w^2
gen RH10_county_w=RH_county_w/10
gen RH10_county_w2=RH10_county_w^2
gen CDD10_w=CDD_w/10
gen HDD10_w=HDD_w/10
gen totalDD10_w=totalDD_w/10
egen fips_county_num=group(fips_county)
destring fips_state_code, gen(fips_state)

gen TEMP_range2=int(TEMP_county_w/2)
replace TEMP_range2=-1 if TEMP_range2<=-1
replace TEMP_range2=17 if TEMP_range2>17 & TEMP_range2!=.
replace TEMP_range2=TEMP_range2+2
replace TEMP_range2=0 if TEMP_range2==12

gen TEMP_county_w_dev_p=max(TEMP_county_w-21,0)
gen TEMP_county_w_dev_n=max(21-TEMP_county_w,0)

gen p_pop25_bachelor=pop25_bachelor/pop25_total
gen p_white=pop_white/pop_total
gen r_owner_renter=units_owner/units_renter
gen p_fuel_electricity=units_electricity/units_total

*****descriptive statistics
tabstat price [fweight=units], by(EnergyStar) stat(mean sd min max) format(%6.3f)
tabstat price [fweight=units], by(EnergyStar) stat(N)

tabstat TEMP_county_w CDD_w HDD_w WDSP_county_w PRCP_county_w RH_county_w [fweight=units], stat(mean sd min max) format(%6.3f) columns(statistics)
tabstat TEMP_county_w CDD_w HDD_w WDSP_county_w PRCP_county_w RH_county_w [fweight=units], stat(N) columns(statistics)

tabstat Residential_m CDD_1996_2005 HDD_1996_2005 median_hhincome p_pop25_bachelor p_white median_age median_room r_owner_renter p_fuel_electricity x65_happening x78_worried x129_regulate x82_harmUS x130_supportRPS democrat_support_p [fweight=units], stat(mean sd min max) format(%6.3f) columns(statistics)
tabstat Residential_m CDD_1996_2005 HDD_1996_2005 median_hhincome p_pop25_bachelor p_white median_age median_room r_owner_renter p_fuel_electricity x65_happening x78_worried x129_regulate x82_harmUS x130_supportRPS democrat_support_p [fweight=units], stat(N) columns(statistics)


*****main result
set more off
reghdfe EnergyStar i.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main

matrix main=e(b)'
svmat main

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_l)

matrix ul=r["ul",....]'
svmat ul,names(main_u)

***price outlier
set more off
reghdfe EnergyStar i.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier

matrix outlier=e(b)'
svmat outlier

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_u)

*****main result, deviation
set more off
reghdfe EnergyStar TEMP_county_w_dev_p TEMP_county_w_dev_n WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_dev

set more off
reghdfe EnergyStar TEMP_county_w_dev_p TEMP_county_w_dev_n WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_dev

esttab main outlier main_dev outlier_dev ///
 using "results main.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
 keep(*.TEMP_range2 TEMP_county_w_dev_p TEMP_county_w_dev_n WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  order(*.TEMP_range2 TEMP_county_w_dev_p TEMP_county_w_dev_n WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 mtitle("Main" "Price Outlier" "Main" "Price Outlier")
 
preserve

keep main* outlier*

gen id=_n

replace id=id-1
replace id=id+1 if id>=12
replace id=12 if id==0
keep if id<=19
 
reshape long main outlier, i(id) j(coefficient) string

rename main est_main
rename outlier est_outlier

reshape long est_, i(id coefficient) j(variable) string

gen coef="c"
replace coef="l" if strpos(coefficient, "_l")>0
replace coef="u" if strpos(coefficient, "_u")>0
replace coef="V" if strpos(coefficient, "_V")>0
replace coef="CV" if strpos(coefficient, "_CV")>0
replace variable="Main" if variable=="main"
replace variable="Price Outlier" if variable=="outlier"

drop coefficient

save "coefficient R main.dta", replace

restore 


set more off
reghdfe lnprice c.CDD10_w##i.EnergyStar c.HDD10_w##i.EnergyStar c.WDSP_county_w##i.EnergyStar c.PRCP_county_w##i.EnergyStar c.RH10_county_w##i.EnergyStar c.RH10_county_w2##i.EnergyStar [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)


*****main result, CDD & HDD
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_CDD_HDD

matrix main_CDD_HDD=e(b)'
svmat main_CDD_HDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_CDD_HDD_l)

matrix ul=r["ul",....]'
svmat ul,names(main_CDD_HDD_u)

***price outlier, CDD & HDD
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_CDD_HDD

matrix outlier_CDD_HDD=e(b)'
svmat outlier_CDD_HDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_CDD_HDD_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_CDD_HDD_u)


****************time lag, CDD & HDD

gen TEMP10_county_w_0=TEMP_county_w_0/10
gen TEMP10_county_w2_0=TEMP10_county_w_0^2
gen RH10_county_w_0=RH_county_w_0/10
gen RH10_county_w2_0=RH10_county_w_0^2
gen CDD10_w_0=CDD_w_0/10
gen HDD10_w_0=HDD_w_0/10

gen TEMP10_county_w_1=TEMP_county_w_1/10
gen TEMP10_county_w2_1=TEMP10_county_w_1^2
gen RH10_county_w_1=RH_county_w_1/10
gen RH10_county_w2_1=RH10_county_w_1^2
gen CDD10_w_1=CDD_w_1/10
gen HDD10_w_1=HDD_w_1/10

gen TEMP10_county_w_2=TEMP_county_w_2/10
gen TEMP10_county_w2_2=TEMP10_county_w_2^2
gen RH10_county_w_2=RH_county_w_2/10
gen RH10_county_w2_2=RH10_county_w_2^2
gen CDD10_w_2=CDD_w_2/10
gen HDD10_w_2=HDD_w_2/10

gen TEMP10_county_w_3=TEMP_county_w_3/10
gen TEMP10_county_w2_3=TEMP10_county_w_3^2
gen RH10_county_w_3=RH_county_w_3/10
gen RH10_county_w2_3=RH10_county_w_3^2
gen CDD10_w_3=CDD_w_3/10
gen HDD10_w_3=HDD_w_3/10

gen TEMP10_county_w_4=TEMP_county_w_4/10
gen TEMP10_county_w2_4=TEMP10_county_w_4^2
gen RH10_county_w_4=RH_county_w_4/10
gen RH10_county_w2_4=RH10_county_w_4^2
gen CDD10_w_4=CDD_w_4/10
gen HDD10_w_4=HDD_w_4/10

gen CDD10_w_sum=CDD10_w+CDD10_w_1+CDD10_w_2+CDD10_w_3
gen HDD10_w_sum=HDD10_w+HDD10_w_1+HDD10_w_2+HDD10_w_3
gen WDSP_county_w_sum=(WDSP_county_w+WDSP_county_w_1+WDSP_county_w_2+WDSP_county_w_3)/4
gen PRCP_county_w_sum=(PRCP_county_w+PRCP_county_w_1+PRCP_county_w_2+PRCP_county_w_3)/4
gen RH10_county_w_sum=(RH10_county_w+RH10_county_w_1+RH10_county_w_2+RH10_county_w_3)/4
gen RH10_county_w2_sum=RH10_county_w_sum^2

*****main result, control current
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_0 HDD10_w_0 WDSP_county_w_0 PRCP_county_w_0 RH10_county_w_0 RH10_county_w2_0 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_current

matrix main_current=e(b)'
svmat main_current

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_current_l)

matrix ul=r["ul",....]'
svmat ul,names(main_current_u)

***price outlier, control current
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_0 HDD10_w_0 WDSP_county_w_0 PRCP_county_w_0 RH10_county_w_0 RH10_county_w2_0 if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_current

matrix outlier_current=e(b)'
svmat outlier_current

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_current_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_current_u)

*****main result, separate
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_1 CDD10_w_2 CDD10_w_3 HDD10_w_1 HDD10_w_2 HDD10_w_3 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_lag_sep

matrix main_lag_sep=e(b)'
svmat main_lag_sep

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_lag_sep_l)

matrix ul=r["ul",....]'
svmat ul,names(main_lag_sep_u)

*****price outlier, separate
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_1 CDD10_w_2 CDD10_w_3 HDD10_w_1 HDD10_w_2 HDD10_w_3 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_lag_sep

matrix outlier_lag_sep=e(b)'
svmat outlier_lag_sep

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_lag_sep_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_lag_sep_u)

*****main result, sum
set more off
reghdfe EnergyStar CDD10_w_sum HDD10_w_sum WDSP_county_w_sum PRCP_county_w_sum RH10_county_w_sum RH10_county_w2_sum lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_lag_sum

matrix main_lag_sum=e(b)'
svmat main_lag_sum

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_lag_sum_l)

matrix ul=r["ul",....]'
svmat ul,names(main_lag_sum_u)

*****price outlier, sum
set more off
reghdfe EnergyStar CDD10_w_sum HDD10_w_sum WDSP_county_w_sum PRCP_county_w_sum RH10_county_w_sum RH10_county_w2_sum lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_lag_sum

matrix outlier_lag_sum=e(b)'
svmat outlier_lag_sum

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_lag_sum_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_lag_sum_u)

esttab main_CDD_HDD outlier_CDD_HDD ///
main_current outlier_current ///
main_lag_sep outlier_lag_sep ///
main_lag_sum outlier_lag_sum ///
 using "results lag.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
 keep(CDD10_w CDD10_w_0 CDD10_w_1 CDD10_w_2 CDD10_w_3 CDD10_w_sum HDD10_w HDD10_w_0 HDD10_w_1 HDD10_w_2 HDD10_w_3 HDD10_w_sum ///
 WDSP_county_w WDSP_county_w_0 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 WDSP_county_w_sum ///
 PRCP_county_w PRCP_county_w_0 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 PRCP_county_w_sum ///
 RH10_county_w RH10_county_w_0 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w_sum ///
 RH10_county_w2 RH10_county_w2_0 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 RH10_county_w2_sum ///
 lnprice) ///
  order(CDD10_w CDD10_w_0 CDD10_w_1 CDD10_w_2 CDD10_w_3 CDD10_w_sum HDD10_w HDD10_w_0 HDD10_w_1 HDD10_w_2 HDD10_w_3 HDD10_w_sum ///
 WDSP_county_w WDSP_county_w_0 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 WDSP_county_w_sum ///
 PRCP_county_w PRCP_county_w_0 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 PRCP_county_w_sum ///
 RH10_county_w RH10_county_w_0 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w_sum ///
 RH10_county_w2 RH10_county_w2_0 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 RH10_county_w2_sum ///
 lnprice) ///
 mtitle("Main" "Price Outlier" "Main" "Price Outlier" "Main" "Price Outlier" "Main" "Price Outlier")
 

preserve

keep *_CDD_HDD* *_current* *_lag*

drop _*

gen id=_n

foreach var of varlist *_CDD_HDD* *_current* *_lag_sum* {
replace `var'=. if id>2
}

foreach var of varlist *_lag_sep* {
replace `var'=. if (id>2 & id<8) | id>13
}

gen indicator=""
replace indicator="CDD" if id==1
replace indicator="HDD" if id==2
replace indicator="CDD -1" if id==8
replace indicator="HDD -1" if id==9
replace indicator="CDD -2" if id==10
replace indicator="HDD -2" if id==11
replace indicator="CDD -3" if id==12
replace indicator="HDD -3" if id==13

keep if indicator!=""

drop id
 
reshape long main_CDD_HDD main_current main_lag_sep main_lag_sum ///
outlier_CDD_HDD outlier_current outlier_lag_sep outlier_lag_sum, i(indicator) j(coef) string

reshape long main outlier, i(indicator coef) j(setting) string

rename main estimatemain
rename outlier estimateoutlier

reshape long estimate, i(indicator coef setting) j(variable) string

drop if estimate==.

replace coef="c" if coef=="1"
replace coef="l" if strpos(coef, "_l")>0
replace coef="u" if strpos(coef, "_u")>0

replace variable="Main" if variable=="main"
replace variable="Price Outlier" if variable=="outlier"

replace setting="Major analysis" if setting=="_CDD_HDD"
replace setting="Current weather controlled" if setting=="_current"
replace setting="Lagged weather separated" if setting=="_lag_sep"
replace setting="Lagged weather summed" if setting=="_lag_sum"

gen color=""
replace color="CDD" if strpos(indicator,"CDD")
replace color="HDD" if strpos(indicator,"HDD")

save "coefficient R lag.dta", replace

restore 



****************robustness, quadratic and different default group
gen CDD6510_w=CDD65_w/10
gen HDD6510_w=HDD65_w/10

gen TEMP_range2_d18=int(TEMP_county_w/2)
replace TEMP_range2_d18=-1 if TEMP_range2<=-1
replace TEMP_range2_d18=17 if TEMP_range2>17 & TEMP_range2!=.
replace TEMP_range2_d18=TEMP_range2+2
replace TEMP_range2_d18=0 if TEMP_range2==10

set more off
reghdfe EnergyStar i.TEMP_range2_d18 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_18

set more off
reghdfe EnergyStar i.TEMP_range2_d18 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_18

set more off
reghdfe EnergyStar CDD6510_w HDD6510_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_18_CDD_HDD

set more off
reghdfe EnergyStar CDD6510_w HDD6510_w  WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_18_CDD_HDD

esttab main_18 outlier_18 main_18_CDD_HDD outlier_18_CDD_HDD ///
 using "results robust default group.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
 keep(*.TEMP_range2_d18 CDD6510_w HDD6510_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  order(*.TEMP_range2_d18 CDD6510_w HDD6510_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 mtitle("Main" "Price Outlier" "Main" "Price Outlier")

 
****************robustness, quadratic terms
gen TEMP10_county_w=TEMP_county_w/10
gen TEMP10_county_w2=TEMP10_county_w^2
gen TEMP10_county_w_dev_p=TEMP_county_w_dev_p/10
gen TEMP10_county_w_dev_p2=TEMP10_county_w_dev_p^2
gen TEMP10_county_w_dev_n=TEMP_county_w_dev_n/10
gen TEMP10_county_w_dev_n2=TEMP10_county_w_dev_n^2
gen WDSP_county_w2=WDSP_county_w^2
gen PRCP_county_w2=PRCP_county_w^2

set more off
reghdfe EnergyStar TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store robust_QT_1

set more off
reghdfe EnergyStar TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store robust_QT_2

set more off
reghdfe EnergyStar TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w WDSP_county_w2 PRCP_county_w PRCP_county_w2 RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store robust_QT_3

set more off
reghdfe EnergyStar TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w WDSP_county_w2 PRCP_county_w PRCP_county_w2 RH10_county_w RH10_county_w2 lnprice if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store robust_QT_4

esttab robust_QT_* ///
 using "results robust quadratic terms.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
keep(TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w WDSP_county_w2 PRCP_county_w PRCP_county_w2 RH10_county_w RH10_county_w2 lnprice) ///
  order(TEMP10_county_w_dev_p TEMP10_county_w_dev_p2 TEMP10_county_w_dev_n TEMP10_county_w_dev_n2 WDSP_county_w WDSP_county_w2 PRCP_county_w PRCP_county_w2 RH10_county_w RH10_county_w2 lnprice) ///
 mtitle("Main" "Price Outlier" "Main" "Price Outlier")
 
 
 
****************robustness, different clusters
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster fips_county_num)
est store robust_CL_county

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_zip3)
est store robust_CL_zip3

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster dma_code)
est store robust_CL_dma

esttab robust_CL_* ///
 using "results robust clusters.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 
 
 
****************robustness, less strict FE
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.month i.fips_state i.year i.week) vce(cluster store_code_uc)
est store robust_FE_1

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state i.year) vce(cluster store_code_uc)
est store robust_FE_2

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state i.month i.year) vce(cluster store_code_uc)
est store robust_FE_3

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.month i.year) vce(cluster store_code_uc)
est store robust_FE_4

set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year i.month) vce(cluster store_code_uc)
est store robust_FE_5


esttab robust_FE_* ///
 using "results robust fixed effects.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 



****************price, CDD & HDD
*****main result
set more off
reghdfe lnprice c.CDD10_w##i.EnergyStar c.HDD10_w##i.EnergyStar c.WDSP_county_w##i.EnergyStar c.PRCP_county_w##i.EnergyStar c.RH10_county_w##i.EnergyStar c.RH10_county_w2##i.EnergyStar  [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store price_main


***price outlier
set more off
reghdfe lnprice c.CDD10_w##i.EnergyStar c.HDD10_w##i.EnergyStar c.WDSP_county_w##i.EnergyStar c.PRCP_county_w##i.EnergyStar c.RH10_county_w##i.EnergyStar c.RH10_county_w2##i.EnergyStar if price>100 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store price_outlier

esttab price_* ///
 using "results price.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)


***************heterogenous effect, in forms of CDD & HDD
global hgroup 3

capture drop h_*

***climate attitude
xtile happening_group=x65_happening, n($hgroup)
xtile worried_group=x78_worried, n($hgroup)
xtile regulate_group=x129_regulate, n($hgroup)
xtile harmUS_group=x82_harmUS, n($hgroup)
xtile support_group=x130_supportRPS, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.happening_group c.HDD10_w##i.happening_group c.WDSP_county_w##i.happening_group c.PRCP_county_w##i.happening_group c.RH10_county_w##i.happening_group c.RH10_county_w2##i.happening_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_happening

matrix h_happening=e(b)'
svmat h_happening

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_happening_l)

matrix ul=r["ul",....]'
svmat ul,names(h_happening_u)

matrix test=e(V)
matrix h_happening_V=vecdiag(test)'
svmat h_happening_V

matrix h_happening_CV_CDD=test[1..29,"CDD10_w"]
svmat h_happening_CV_CDD

matrix h_happening_CV_HDD=test[1..29,"HDD10_w"]
svmat h_happening_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.worried_group c.HDD10_w##i.worried_group c.WDSP_county_w##i.worried_group c.PRCP_county_w##i.worried_group c.RH10_county_w##i.worried_group c.RH10_county_w2##i.worried_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_worried

matrix h_worried=e(b)'
svmat h_worried

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_worried_l)

matrix ul=r["ul",....]'
svmat ul,names(h_worried_u)

matrix test=e(V)
matrix h_worried_V=vecdiag(test)'
svmat h_worried_V

matrix h_worried_CV_CDD=test[1..29,"CDD10_w"]
svmat h_worried_CV_CDD

matrix h_worried_CV_HDD=test[1..29,"HDD10_w"]
svmat h_worried_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.harmUS_group c.HDD10_w##i.harmUS_group c.WDSP_county_w##i.harmUS_group c.PRCP_county_w##i.harmUS_group c.RH10_county_w##i.harmUS_group c.RH10_county_w2##i.harmUS_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_harmUS

matrix h_harmUS=e(b)'
svmat h_harmUS

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_harmUS_l)

matrix ul=r["ul",....]'
svmat ul,names(h_harmUS_u)

matrix test=e(V)
matrix h_harmUS_V=vecdiag(test)'
svmat h_harmUS_V

matrix h_harmUS_CV_CDD=test[1..29,"CDD10_w"]
svmat h_harmUS_CV_CDD

matrix h_harmUS_CV_HDD=test[1..29,"HDD10_w"]
svmat h_harmUS_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.regulate_group c.HDD10_w##i.regulate_group c.WDSP_county_w##i.regulate_group c.PRCP_county_w##i.regulate_group c.RH10_county_w##i.regulate_group c.RH10_county_w2##i.regulate_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_regulate

matrix h_regulate=e(b)'
svmat h_regulate

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_regulate_l)

matrix ul=r["ul",....]'
svmat ul,names(h_regulate_u)

matrix test=e(V)
matrix h_regulate_V=vecdiag(test)'
svmat h_regulate_V

matrix h_regulate_CV_CDD=test[1..29,"CDD10_w"]
svmat h_regulate_CV_CDD

matrix h_regulate_CV_HDD=test[1..29,"HDD10_w"]
svmat h_regulate_CV_HDD

set more off
reghdfe EnergyStar c.CDD10_w##i.support_group c.HDD10_w##i.support_group c.WDSP_county_w##i.support_group c.PRCP_county_w##i.support_group c.RH10_county_w##i.support_group c.RH10_county_w2##i.support_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_support

matrix h_support=e(b)'
svmat h_support

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_support_l)

matrix ul=r["ul",....]'
svmat ul,names(h_support_u)

matrix test=e(V)
matrix h_support_V=vecdiag(test)'
svmat h_support_V

matrix h_support_CV_CDD=test[1..29,"CDD10_w"]
svmat h_support_CV_CDD

matrix h_support_CV_HDD=test[1..29,"HDD10_w"]
svmat h_support_CV_HDD

esttab climate_happening climate_worried climate_harmUS climate_regulate climate_support ///
 using "results climate attitude.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 * ///
 *keep(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) /// 
 *order(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 *mtitle("Low" "Medium" "High" "Low" "Medium" "High" "Low" "Medium" "High") 

 
 
***background climate
xtile HDD_group=HDD_1996_2005, n($hgroup)
xtile CDD_group=CDD_1996_2005, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.CDD_group c.HDD10_w##i.CDD_group c.WDSP_county_w##i.CDD_group c.PRCP_county_w##i.CDD_group c.RH10_county_w##i.CDD_group c.RH10_county_w2##i.CDD_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_CDD

matrix h_CDD=e(b)'
svmat h_CDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_CDD_l)

matrix ul=r["ul",....]'
svmat ul,names(h_CDD_u)

matrix test=e(V)
matrix h_CDD_V=vecdiag(test)'
svmat h_CDD_V

matrix h_CDD_CV_CDD=test[1..29,"CDD10_w"]
svmat h_CDD_CV_CDD

matrix h_CDD_CV_HDD=test[1..29,"HDD10_w"]
svmat h_CDD_CV_HDD

set more off
reghdfe EnergyStar c.CDD10_w##i.HDD_group c.HDD10_w##i.HDD_group c.WDSP_county_w##i.HDD_group c.PRCP_county_w##i.HDD_group c.RH10_county_w##i.HDD_group c.RH10_county_w2##i.HDD_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store climate_HDD

matrix h_HDD=e(b)'
svmat h_HDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_HDD_l)

matrix ul=r["ul",....]'
svmat ul,names(h_HDD_u)

matrix test=e(V)
matrix h_HDD_V=vecdiag(test)'
svmat h_HDD_V

matrix h_HDD_CV_CDD=test[1..29,"CDD10_w"]
svmat h_HDD_CV_CDD

matrix h_HDD_CV_HDD=test[1..29,"HDD10_w"]
svmat h_HDD_CV_HDD

***electricity price
xtile eprice_group=Residential_m, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.eprice_group c.HDD10_w##i.eprice_group c.WDSP_county_w##i.eprice_group c.PRCP_county_w##i.eprice_group c.RH10_county_w##i.eprice_group c.RH10_county_w2##i.eprice_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store eprice

matrix h_eprice=e(b)'
svmat h_eprice

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_eprice_l)

matrix ul=r["ul",....]'
svmat ul,names(h_eprice_u)

matrix test=e(V)
matrix h_eprice_V=vecdiag(test)'
svmat h_eprice_V

matrix h_eprice_CV_CDD=test[1..29,"CDD10_w"]
svmat h_eprice_CV_CDD

matrix h_eprice_CV_HDD=test[1..29,"HDD10_w"]
svmat h_eprice_CV_HDD


esttab climate_CDD climate_HDD eprice ///
 using "results background climate and electricity price.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 * ///
 *keep(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  *order(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 *mtitle("Low" "Medium" "High" "Low" "Medium" "High" "Low" "Medium" "High")
 
***socio-economic characteristics
xtile income_group=median_hhincome, n($hgroup)
xtile education_group=p_pop25_bachelor, n($hgroup)
xtile ethnic_group=p_white, n($hgroup)
xtile age_group=median_age, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.income_group c.HDD10_w##i.income_group c.WDSP_county_w##i.income_group c.PRCP_county_w##i.income_group c.RH10_county_w##i.income_group c.RH10_county_w2##i.income_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store income

matrix h_income=e(b)'
svmat h_income

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_income_l)

matrix ul=r["ul",....]'
svmat ul,names(h_income_u)

matrix test=e(V)
matrix h_income_V=vecdiag(test)'
svmat h_income_V

matrix h_income_CV_CDD=test[1..29,"CDD10_w"]
svmat h_income_CV_CDD

matrix h_income_CV_HDD=test[1..29,"HDD10_w"]
svmat h_income_CV_HDD

set more off
reghdfe EnergyStar c.CDD10_w##i.education_group c.HDD10_w##i.education_group c.WDSP_county_w##i.education_group c.PRCP_county_w##i.education_group c.RH10_county_w##i.education_group c.RH10_county_w2##i.education_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store education

matrix h_education=e(b)'
svmat h_education

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_education_l)

matrix ul=r["ul",....]'
svmat ul,names(h_education_u)

matrix test=e(V)
matrix h_education_V=vecdiag(test)'
svmat h_education_V

matrix h_education_CV_CDD=test[1..29,"CDD10_w"]
svmat h_education_CV_CDD

matrix h_education_CV_HDD=test[1..29,"HDD10_w"]
svmat h_education_CV_HDD

set more off
reghdfe EnergyStar c.CDD10_w##i.ethnic_group c.HDD10_w##i.ethnic_group c.WDSP_county_w##i.ethnic_group c.PRCP_county_w##i.ethnic_group c.RH10_county_w##i.ethnic_group c.RH10_county_w2##i.ethnic_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store ethnic

matrix h_ethnic=e(b)'
svmat h_ethnic

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_ethnic_l)

matrix ul=r["ul",....]'
svmat ul,names(h_ethnic_u)

matrix test=e(V)
matrix h_ethnic_V=vecdiag(test)'
svmat h_ethnic_V

matrix h_ethnic_CV_CDD=test[1..29,"CDD10_w"]
svmat h_ethnic_CV_CDD

matrix h_ethnic_CV_HDD=test[1..29,"HDD10_w"]
svmat h_ethnic_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.age_group c.HDD10_w##i.age_group c.WDSP_county_w##i.age_group c.PRCP_county_w##i.age_group c.RH10_county_w##i.age_group c.RH10_county_w2##i.age_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store age

matrix h_age=e(b)'
svmat h_age

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_age_l)

matrix ul=r["ul",....]'
svmat ul,names(h_age_u)

matrix test=e(V)
matrix h_age_V=vecdiag(test)'
svmat h_age_V

matrix h_age_CV_CDD=test[1..29,"CDD10_w"]
svmat h_age_CV_CDD

matrix h_age_CV_HDD=test[1..29,"HDD10_w"]
svmat h_age_CV_HDD


***political preference
*gen democrat_group=0
*replace democrat_group=1 if party=="DEMOCRAT"
xtile democrat_s_group=democrat_support_p, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.democrat_s_group c.HDD10_w##i.democrat_s_group c.WDSP_county_w##i.democrat_s_group c.PRCP_county_w##i.democrat_s_group c.RH10_county_w##i.democrat_s_group c.RH10_county_w2##i.democrat_s_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store democrat

matrix h_democrat=e(b)'
svmat h_democrat

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_democrat_l)

matrix ul=r["ul",....]'
svmat ul,names(h_democrat_u)

matrix test=e(V)
matrix h_democrat_V=vecdiag(test)'
svmat h_democrat_V

matrix h_democrat_CV_CDD=test[1..29,"CDD10_w"]
svmat h_democrat_CV_CDD

matrix h_democrat_CV_HDD=test[1..29,"HDD10_w"]
svmat h_democrat_CV_HDD


esttab income education ethnic age democrat ///
 using "results socio-economic characteristics.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 * ///
 *keep(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  *order(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 *mtitle("Low" "Medium" "High" "Low" "Medium" "High" "Low" "Medium" "High")


***housing characteristics
xtile rooms_group=median_room, n($hgroup)
xtile owner_group=r_owner_renter, n($hgroup)
xtile heatinge_group=p_fuel_electricity, n($hgroup)

set more off
reghdfe EnergyStar c.CDD10_w##i.rooms_group c.HDD10_w##i.rooms_group c.WDSP_county_w##i.rooms_group c.PRCP_county_w##i.rooms_group c.RH10_county_w##i.rooms_group c.RH10_county_w2##i.rooms_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store rooms

matrix h_rooms=e(b)'
svmat h_rooms

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_rooms_l)

matrix ul=r["ul",....]'
svmat ul,names(h_rooms_u)

matrix test=e(V)
matrix h_rooms_V=vecdiag(test)'
svmat h_rooms_V

matrix h_rooms_CV_CDD=test[1..29,"CDD10_w"]
svmat h_rooms_CV_CDD

matrix h_rooms_CV_HDD=test[1..29,"HDD10_w"]
svmat h_rooms_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.owner_group c.HDD10_w##i.owner_group c.WDSP_county_w##i.owner_group c.PRCP_county_w##i.owner_group c.RH10_county_w##i.owner_group c.RH10_county_w2##i.owner_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store owner

matrix h_owner=e(b)'
svmat h_owner

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_owner_l)

matrix ul=r["ul",....]'
svmat ul,names(h_owner_u)

matrix test=e(V)
matrix h_owner_V=vecdiag(test)'
svmat h_owner_V

matrix h_owner_CV_CDD=test[1..29,"CDD10_w"]
svmat h_owner_CV_CDD

matrix h_owner_CV_HDD=test[1..29,"HDD10_w"]
svmat h_owner_CV_HDD


set more off
reghdfe EnergyStar c.CDD10_w##i.heatinge_group c.HDD10_w##i.heatinge_group c.WDSP_county_w##i.heatinge_group c.PRCP_county_w##i.heatinge_group c.RH10_county_w##i.heatinge_group c.RH10_county_w2##i.heatinge_group lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store heatinge

matrix h_heatinge=e(b)'
svmat h_heatinge

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(h_heatinge_l)

matrix ul=r["ul",....]'
svmat ul,names(h_heatinge_u)

matrix test=e(V)
matrix h_heatinge_V=vecdiag(test)'
svmat h_heatinge_V

matrix h_heatinge_CV_CDD=test[1..29,"CDD10_w"]
svmat h_heatinge_CV_CDD

matrix h_heatinge_CV_HDD=test[1..29,"HDD10_w"]
svmat h_heatinge_CV_HDD

esttab rooms owner heatinge ///
 using "results housing characteristics.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01)
 * ///
 *keep(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  *order(CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 *mtitle("Low" "Medium" "High" "Low" "Medium" "High" "Low" "Medium" "High")

 

save "air conditioner regression final.dta", replace 


*******************************R coefficient figure
clear all

use "air conditioner regression final.dta", clear

keep h_*

gen id=_n
keep if id==1 | (id>=6 & id<=8) | (id>=10 & id<=11)

drop id

gen id=_n

drop *_l1 *_u1

reshape long h_happening h_worried h_regulate h_harmUS h_support h_CDD h_HDD h_eprice h_income h_education h_ethnic h_age h_democrat h_rooms h_owner h_heatinge, i(id) j(coefficient) string

reshape long h_, i(id coefficient) j(variable) string

replace coefficient=subinstr(coefficient,"1","",.)
replace coefficient="_E" if coefficient==""

reshape wide h_*, i(variable id) j(coefficient) string

gen E_CDD=h__E if id==1
gen E_HDD=h__E if id==4
egen mE_CDD=max(E_CDD), by(variable)
egen mE_HDD=max(E_HDD), by(variable)

gen estimate_c=h__E if id==1 | id==4
replace estimate_c=h__E+mE_CDD if id==2 | id==3
replace estimate_c=h__E+mE_HDD if id==5 | id==6

gen V_CDD=h__V if id==1
gen V_HDD=h__V if id==4
egen mV_CDD=max(V_CDD), by(variable)
egen mV_HDD=max(V_HDD), by(variable)

gen estimate_l=estimate_c-1.96*sqrt(h__V) if id==1 | id==4
replace estimate_l=estimate_c-1.96*sqrt(h__V+mV_CDD+2*h__CV_CDD) if id==2 | id==3
replace estimate_l=estimate_c-1.96*sqrt(h__V+mV_HDD+2*h__CV_HDD) if id==5 | id==6
gen estimate_u=estimate_c+1.96*sqrt(h__V) if id==1 | id==4
replace estimate_u=estimate_c+1.96*sqrt(h__V+mV_CDD+2*h__CV_CDD) if id==2 | id==3
replace estimate_u=estimate_c+1.96*sqrt(h__V+mV_HDD+2*h__CV_HDD) if id==5 | id==6

keep id variable estimate_*

reshape long estimate, i(variable id) j(coef) string
replace coef=subinstr(coef, "_","",.)

replace variable="Believe climate change happening" if variable=="happening"
replace variable="Worry about climate change" if variable=="worried"
replace variable="Believe climate change harm US" if variable=="harmUS"
replace variable="Support regulation of CO2" if variable=="regulate"
replace variable="Support renewable energy standards" if variable=="support"
replace variable="Background climate - CDD" if variable=="CDD"
replace variable="Background climate - HDD" if variable=="HDD"
replace variable="State-level electricity price" if variable=="eprice"
replace variable="Median income" if variable=="income"
replace variable="% of population > bachelor" if variable=="education"
replace variable="% of White people" if variable=="ethnic"
replace variable="Median age" if variable=="age"
replace variable="Support Democratic Party" if variable=="democrat"
replace variable="Median number of rooms" if variable=="rooms"
replace variable="Owner:Renter" if variable=="owner"
replace variable="% of electricity as heating fuel" if variable=="heatinge"

rename id group
gen id="CDD" if group<=3
replace id="HDD" if group>=4

replace group=group-3 if group>3

tostring group, replace
*replace group="Low" if group=="1"
*replace group="Medium" if group=="2"
*replace group="High" if group=="3"

save "coefficient R heterogenous.dta", replace






*******************falsification test, telephone
/*
*******energy star, telephone
clear all

import excel "variable list.xlsx", sheet("energy star telephone") firstrow

duplicates drop upc_descr_trim, force

save "energy star telephone.dta", replace
*/


*******************small sample
clear all

use "all_products_telephonefinal.dta", clear

set seed 12345

sample 1000, count

save "all_products_telephonefinal small sample.dta", replace


clear all

use "all_products_telephonefinal small sample.dta", clear

tostring fips_state_code, format(%02.0f) replace

tostring fips_county_code, format(%03.0f) replace

gen fips_county=fips_state_code+fips_county_code

keep fips_county week_end

joinby fips_county week_end using "climate county week 0.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -1.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -2.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -3.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -4.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -5.dta", unmatched(master)

drop _merge

save "climate county week telephone small sample.dta", replace


*******regression, telephone
clear all

use "all_products_telephonefinal small sample.dta", clear

*expand units

gen upc_descr_trim=subinstr(upc_descr, " ", "", .)

drop _merge

merge m:1 upc_descr_trim using "energy star telephone.dta"

drop if _merge!=3

drop if upc_descr_trim==""

drop _merge

tostring fips_state_code, format(%02.0f) replace

tostring fips_county_code, format(%03.0f) replace

gen fips_county=fips_state_code+fips_county_code

/*
joinby fips_county week_end using "climate county week 0.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -1.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -2.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -3.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -4.dta", unmatched(master)

drop _merge

joinby fips_county week_end using "climate county week -5.dta", unmatched(master)

drop _merge
*/

joinby fips_county week_end using "climate county week telephone small sample.dta", unmatched(master)

drop _merge

tostring week_end, replace

*gen year=substr(week_end,1,4)
gen month=substr(week_end,5,2)
gen day=substr(week_end,7,2)
destring month day, replace
gen date=mdy(month,day,year)
gen week=week(date)
/*
merge m:1 fips_county using "climate attitude.dta"

drop if _merge==2

drop _merge

merge m:1 fips_state_descr year month using "electricity price.dta"

drop if _merge==2

drop _merge

merge m:1 fips_state_descr year using "electricity price annual.dta"

drop if _merge==2

drop _merge
*/

gen lnprice=ln(price)

gen TEMP10_county_w=TEMP_county_w/10
gen TEMP10_county_w2=TEMP10_county_w^2
gen RH10_county_w=RH_county_w/10
gen RH10_county_w2=RH10_county_w^2
gen CDD10_w=CDD_w/10
gen HDD10_w=HDD_w/10
gen totalDD10_w=totalDD_w/10
egen fips_county_num=group(fips_county)
destring fips_state_code, gen(fips_state)

gen TEMP_range2=int(TEMP_county_w/2)
replace TEMP_range2=-1 if TEMP_range2<=-1
replace TEMP_range2=17 if TEMP_range2>17 & TEMP_range2!=.
replace TEMP_range2=TEMP_range2+2
replace TEMP_range2=0 if TEMP_range2==12


*****main result
set more off
reghdfe EnergyStar i.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main

matrix main=e(b)'
svmat main

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_l)

matrix ul=r["ul",....]'
svmat ul,names(main_u)

***price outlier
set more off
reghdfe EnergyStar i.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>10 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier

matrix outlier=e(b)'
svmat outlier

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_u)


esttab main outlier ///
 using "results main telephone.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
 keep(*.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
  order(*.TEMP_range2 WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice) ///
 mtitle("Main" "Price Outlier")
 
preserve

keep main* outlier*

gen id=_n

replace id=id-1
replace id=id+1 if id>=12
replace id=12 if id==0
keep if id<=19
 
reshape long main outlier, i(id) j(coefficient) string

rename main est_main
rename outlier est_outlier

reshape long est_, i(id coefficient) j(variable) string

gen coef="c"
replace coef="l" if strpos(coefficient, "_l")>0
replace coef="u" if strpos(coefficient, "_u")>0
replace coef="V" if strpos(coefficient, "_V")>0
replace coef="CV" if strpos(coefficient, "_CV")>0
replace variable="Main" if variable=="main"
replace variable="Price Outlier" if variable=="outlier"

drop coefficient

save "coefficient R main telephone.dta", replace

restore 


*****main result, CDD & HDD
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_CDD_HDD

matrix main_CDD_HDD=e(b)'
svmat main_CDD_HDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_CDD_HDD_l)

matrix ul=r["ul",....]'
svmat ul,names(main_CDD_HDD_u)

***price outlier, CDD & HDD
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice if price>10 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_CDD_HDD

matrix outlier_CDD_HDD=e(b)'
svmat outlier_CDD_HDD

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_CDD_HDD_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_CDD_HDD_u)




****************time lag, CDD & HDD

gen TEMP10_county_w_0=TEMP_county_w_0/10
gen TEMP10_county_w2_0=TEMP10_county_w_0^2
gen RH10_county_w_0=RH_county_w_0/10
gen RH10_county_w2_0=RH10_county_w_0^2
gen CDD10_w_0=CDD_w_0/10
gen HDD10_w_0=HDD_w_0/10

gen TEMP10_county_w_1=TEMP_county_w_1/10
gen TEMP10_county_w2_1=TEMP10_county_w_1^2
gen RH10_county_w_1=RH_county_w_1/10
gen RH10_county_w2_1=RH10_county_w_1^2
gen CDD10_w_1=CDD_w_1/10
gen HDD10_w_1=HDD_w_1/10

gen TEMP10_county_w_2=TEMP_county_w_2/10
gen TEMP10_county_w2_2=TEMP10_county_w_2^2
gen RH10_county_w_2=RH_county_w_2/10
gen RH10_county_w2_2=RH10_county_w_2^2
gen CDD10_w_2=CDD_w_2/10
gen HDD10_w_2=HDD_w_2/10

gen TEMP10_county_w_3=TEMP_county_w_3/10
gen TEMP10_county_w2_3=TEMP10_county_w_3^2
gen RH10_county_w_3=RH_county_w_3/10
gen RH10_county_w2_3=RH10_county_w_3^2
gen CDD10_w_3=CDD_w_3/10
gen HDD10_w_3=HDD_w_3/10

gen TEMP10_county_w_4=TEMP_county_w_4/10
gen TEMP10_county_w2_4=TEMP10_county_w_4^2
gen RH10_county_w_4=RH_county_w_4/10
gen RH10_county_w2_4=RH10_county_w_4^2
gen CDD10_w_4=CDD_w_4/10
gen HDD10_w_4=HDD_w_4/10

gen CDD10_w_sum=CDD10_w+CDD10_w_1+CDD10_w_2+CDD10_w_3
gen HDD10_w_sum=HDD10_w+HDD10_w_1+HDD10_w_2+HDD10_w_3
gen WDSP_county_w_sum=(WDSP_county_w+WDSP_county_w_1+WDSP_county_w_2+WDSP_county_w_3)/4
gen PRCP_county_w_sum=(PRCP_county_w+PRCP_county_w_1+PRCP_county_w_2+PRCP_county_w_3)/4
gen RH10_county_w_sum=(RH10_county_w+RH10_county_w_1+RH10_county_w_2+RH10_county_w_3)/4
gen RH10_county_w2_sum=RH10_county_w_sum^2

*****main result, control current
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_0 HDD10_w_0 WDSP_county_w_0 PRCP_county_w_0 RH10_county_w_0 RH10_county_w2_0 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_current

matrix main_current=e(b)'
svmat main_current

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_current_l)

matrix ul=r["ul",....]'
svmat ul,names(main_current_u)

***price outlier, control current
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_0 HDD10_w_0 WDSP_county_w_0 PRCP_county_w_0 RH10_county_w_0 RH10_county_w2_0 if price>10 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_current

matrix outlier_current=e(b)'
svmat outlier_current

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_current_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_current_u)

*****main result, separate
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_1 CDD10_w_2 CDD10_w_3 HDD10_w_1 HDD10_w_2 HDD10_w_3 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_lag_sep

matrix main_lag_sep=e(b)'
svmat main_lag_sep

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_lag_sep_l)

matrix ul=r["ul",....]'
svmat ul,names(main_lag_sep_u)

*****price outlier, separate
set more off
reghdfe EnergyStar CDD10_w HDD10_w WDSP_county_w PRCP_county_w RH10_county_w RH10_county_w2 lnprice CDD10_w_1 CDD10_w_2 CDD10_w_3 HDD10_w_1 HDD10_w_2 HDD10_w_3 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 if price>10 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_lag_sep

matrix outlier_lag_sep=e(b)'
svmat outlier_lag_sep

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_lag_sep_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_lag_sep_u)

*****main result, sum
set more off
reghdfe EnergyStar CDD10_w_sum HDD10_w_sum WDSP_county_w_sum PRCP_county_w_sum RH10_county_w_sum RH10_county_w2_sum lnprice [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store main_lag_sum

matrix main_lag_sum=e(b)'
svmat main_lag_sum

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(main_lag_sum_l)

matrix ul=r["ul",....]'
svmat ul,names(main_lag_sum_u)

*****price outlier, sum
set more off
reghdfe EnergyStar CDD10_w_sum HDD10_w_sum WDSP_county_w_sum PRCP_county_w_sum RH10_county_w_sum RH10_county_w2_sum lnprice if price>10 [fweight=units], absorb(i.fips_county_num##i.week i.fips_state##i.year##i.month) vce(cluster store_code_uc)
est store outlier_lag_sum

matrix outlier_lag_sum=e(b)'
svmat outlier_lag_sum

mat r=r(table)
matrix ll=r["ll",....]'
svmat ll,names(outlier_lag_sum_l)

matrix ul=r["ul",....]'
svmat ul,names(outlier_lag_sum_u)

esttab main_CDD_HDD outlier_CDD_HDD ///
main_current outlier_current ///
main_lag_sep outlier_lag_sep ///
main_lag_sum outlier_lag_sum ///
 using "results lag telephone.csv", replace ///
 b(%6.3f) se(%6.3f) r2 star(* 0.10 ** 0.05  *** 0.01) ///
 keep(CDD10_w CDD10_w_0 CDD10_w_1 CDD10_w_2 CDD10_w_3 CDD10_w_sum HDD10_w HDD10_w_0 HDD10_w_1 HDD10_w_2 HDD10_w_3 HDD10_w_sum ///
 WDSP_county_w WDSP_county_w_0 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 WDSP_county_w_sum ///
 PRCP_county_w PRCP_county_w_0 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 PRCP_county_w_sum ///
 RH10_county_w RH10_county_w_0 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w_sum ///
 RH10_county_w2 RH10_county_w2_0 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 RH10_county_w2_sum ///
 lnprice) ///
  order(CDD10_w CDD10_w_0 CDD10_w_1 CDD10_w_2 CDD10_w_3 CDD10_w_sum HDD10_w HDD10_w_0 HDD10_w_1 HDD10_w_2 HDD10_w_3 HDD10_w_sum ///
 WDSP_county_w WDSP_county_w_0 WDSP_county_w_1 WDSP_county_w_2 WDSP_county_w_3 WDSP_county_w_sum ///
 PRCP_county_w PRCP_county_w_0 PRCP_county_w_1 PRCP_county_w_2 PRCP_county_w_3 PRCP_county_w_sum ///
 RH10_county_w RH10_county_w_0 RH10_county_w_1 RH10_county_w_2 RH10_county_w_3 RH10_county_w_sum ///
 RH10_county_w2 RH10_county_w2_0 RH10_county_w2_1 RH10_county_w2_2 RH10_county_w2_3 RH10_county_w2_sum ///
 lnprice) ///
 mtitle("Main" "Price Outlier" "Main" "Price Outlier" "Main" "Price Outlier"  "Main" "Price Outlier")
 
save "test final.dta", replace


preserve

keep *_CDD_HDD* *_current* *_lag*

drop _*

gen id=_n

foreach var of varlist *_CDD_HDD* *_current* *_lag_sum* {
replace `var'=. if id>2
}

foreach var of varlist *_lag_sep* {
replace `var'=. if (id>2 & id<8) | id>13
}

gen indicator=""
replace indicator="CDD" if id==1
replace indicator="HDD" if id==2
replace indicator="CDD -1" if id==8
replace indicator="HDD -1" if id==9
replace indicator="CDD -2" if id==10
replace indicator="HDD -2" if id==11
replace indicator="CDD -3" if id==12
replace indicator="HDD -3" if id==13

keep if indicator!=""

drop id
 
reshape long main_CDD_HDD main_current main_lag_sep main_lag_sum ///
outlier_CDD_HDD outlier_current outlier_lag_sep outlier_lag_sum, i(indicator) j(coef) string

reshape long main outlier, i(indicator coef) j(setting) string

rename main estimatemain
rename outlier estimateoutlier

reshape long estimate, i(indicator coef setting) j(variable) string

drop if estimate==.

replace coef="c" if coef=="1"
replace coef="l" if strpos(coef, "_l")>0
replace coef="u" if strpos(coef, "_u")>0

replace variable="Main" if variable=="main"
replace variable="Price Outlier" if variable=="outlier"

replace setting="Major analysis" if setting=="_CDD_HDD"
replace setting="Current climate controlled" if setting=="_current"
replace setting="Lagged climate separated" if setting=="_lag_sep"
replace setting="Lagged climate summed" if setting=="_lag_sum"

gen color=""
replace color="CDD" if strpos(indicator,"CDD")
replace color="HDD" if strpos(indicator,"HDD")

save "coefficient R lag telephone.dta", replace

restore 