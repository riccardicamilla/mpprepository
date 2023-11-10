/***********
Master Thesis: Assessing the Adequacy of Child Benefits
Camilla Riccardi
i6327836
***********/

cd "C:\Users\camil\Documents\MASTER MPP\THESIS TRACK\ANALYSIS"
capture log close
*log using "Logs\Master Thesis_LOG", replace
set more off

/*
***********DATASET PREPARATION
*import excel dataset
import excel "C:\Users\camil\Documents\MASTER MPP\THESIS TRACK\ANALYSIS\Inputs\Riccardi_CBA.xls", sheet("Sheet1") cellrange(A1:AC21) firstrow clear

***encode string variable to numeric
encode cntry_code, gen(country_code)
label variable country_code "Country code"
encode cntry_name, gen(country_name)
label variable country_name "Country name"
encode income_group, gen(income)
label variable income "Income group"
encode reg, gen(region)
label variable region "Country region"
encode access, gen(accessibility)
label variable accessibility "The access to the child benefit scheme includes a means test"

drop cntry_code cntry_name income_group reg access

***destring variables
*socioeconomic 
destring GDP_pc_PPP GNI_pc_PPP mean median pov_line_national GINI HDI pop_total gender fragility, replace
*child population
destring pop_tot_UNICEF pop_minors pop_infants births_woman poverty_190 poverty_320 poverty_550 MPI, replace

***label variables
label variable GDP_pc_PPP "Per capita GDP values, 2017 PPP int$" 
label variable GNI_pc_PPP "Per capita GNI values, 2017 PPP int$"
label variable mean "Average consumption or income pc, total population (2017 PPP int$ day)"
label variable median "Median consumption or income per capita, total population (2017 PPP int$ day)"
label variable pov_line_national "Harmonized national poverty lines, income/consumption pc day, 2017 PPP int$"
label variable GINI "Gini index, 0 - 100"
label variable HDI "Human Development Index, 0-1"
label variable pop_total "De facto population, thousands. World Bank"
label variable gender "Gender Inequality Index, 0-1"
label variable fragility "Fragile States Index, 0-120."
label variable pop_tot_UNICEF "Total population, thousands"
label variable pop_minors "Population under 18, thousands"
label variable pop_infants "Pupulation under 5, thousands"
label variable births_woman "Total fertility  (live births per woman)"
label variable poverty_190 "Percent of poor children, 1.90 2011 PPP int$"
label variable poverty_320 "Percent of poor children, 3.20 2011 PPP int$"
label variable poverty_550 "Percent of poor children, 5.50 2011 PPP int$"
label variable MPI "Multidimensional Poverty Index of population 0-17, 0-1"
label variable benefit_amount "Monthly CB for HH of 2 parents-2 children (3 and 6 y/o), local currency"
label variable coverage "Proportion of children covered by child or family cash benefits"
label variable SSC_ratification "Ratification of international family Social Security Conventions"
label variable ppp2017 "PPP conversion factor, private consumption (LCU per international $)"
label variable sensitivity "The CB scheme is sensitive to family/child characteristics"
label variable ages "Ages of the child covered by the CB scheme"

*generate new variables
gen GDPday=GDP_pc_PPP/365
label variable GDPday "Daily per capita GDP values, current PPP int$" 
gen GNIday=GNI_pc_PPP/365
label variable GNIday "Daily per capita GNI values, current PPP int$"

gen pop_minors_over5=pop_minors-pop_infants
label variable pop_minors_over5 "Population aged 5-18, thousands"
gen pop_adults=pop_tot_UNICEF-pop_minors
label variable pop_adults "Population over 18, thousands"

***save .dta dataset
save "Inputs\Riccardi_dataset_file1of2.dta", replace
*/

***********
use "Inputs\Riccardi_dataset_file1of2", clear
browse

*sum GDPdifference, d
*codebook GDPdifference
*tab GDPdifference country_name

************DATA DESCRIPTION
tab region income, row col
*graph bar GDP_pc_PPP, over(country_name) by(income)
*graph bar GNI_pc_PPP, over(country_name) by(income)

*graph bar GDPday mean median, by(country_name)
*graph bar median, by(country_region)
*graph bar fragility, over(country_name) by(income)
bysort income:sum fragility, d 
bysort region: sum fragility, d

sum median, d

*child population focus
*graph hbar pop_infants pop_minors_over5 pop_adults, over(country_name) stack percent
*graph hbar pop_infants pop_minors_over5 pop_adults, over(country_region) stack percent
*/


*********ANALYSIS
***DIGNITY: proportion of relative income poverty threshold (60% median income) of the benefit amount for a family of 2 children and 2 parents (2017 PPP, current international $)

*benefit amount expressed in 2017 PPP international $
gen amount_ppp=benefit_amount/ppp2017
label variable amount_ppp "Monthly CB for HH of 2 parents-2 children (3 and 6 y/o), 2017 PPP int$"
tab country_name, sum(amount_ppp)

*household monthly median income
gen equivincome_month=(median*30)*sqrt(4)
tab country_name, sum(equivincome_month)

*relative income poverty threshold (60% of median income)
gen relpov_60=0.6*equivincome_month
tab country_name, sum(relpov_60)

*proportion of threshold
gen dignity=(amount_ppp/relpov_60)*100

*graph bar dignity, over(country_name, sort(dignity)) 
tab country_name, sum(dignity)

*code dignity
recode dignity (0/9.99=0.05)(10/29.99=0.1)(30/600=0.2), gen(dignity_score)
tab country_name, sum(dignity_score)

***SENSITIVITY
recode sensitivity (1=0.05)(2=0.1)(3=0.15)(4=0.2), gen(sensitivity_score)
tab country_name, sum(sensitivity_score)

***INCLUSION
gen inclusion=(coverage/100)*0.2
tab country_name, sum(inclusion)

***STABILITY
recode ages (0/9=0.1)(10/18=0.2), gen(stability)
tab country_name, sum(stability)

***ACCESSIBILITY
recode accessibility (1=0.2)(2=0), gen(accessibility_score)
tab country_name, sum(accessibility_score)

***ADEQUACY***
gen adequacy=dignity_score+sensitivity_score+inclusion+stability+accessibility_score
tab country_name, sum(adequacy)
*graph bar adequacy, over(country_name, sort(adequacy)) 