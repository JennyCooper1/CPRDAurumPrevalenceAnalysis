use "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDons3.dta", clear
****************/




**Encoding dates from string to being readable by STATA

generate IndexDate = date(index_date, "YMD") //IndexDate (Date when a patient enters study)
format IndexDate %tdDD/NN/CCYY

generate YearofBirth = date(year_of_birth, "YMD") //DateOfBirth (Accurate to month level for children & accurate to year level for adults)
format YearofBirth %tdDD/NN/CCYY


generate ExitDate = date(exit_date, "YMD") //ExitDate (Date when a patient leaves study)
format ExitDate %tdDD/NN/CCYY

generate EndDate = date(exit_date, "YMD") //EndDate (Date when a patient leaves study)
format EndDate %tdDD/NN/CCYY


generate StandardDate = date(standard_date1, "YMD") //An indicator of data quality but not actually used in CPRD Aurum yet  - set to 1st Jan 2005
format StandardDate %tdDD/NN/CCYY

generate CollectionDate = date(collection_date, "YMD") //Data when the last set of medical records were collected from the practice to CPRD
format CollectionDate %tdDD/NN/CCYY

generate StartDate = date(start_date, "YMD") //Patient Start Date
format StartDate %tdDD/NN/CCYY

generate TransferDate = date(transfer_date, "YMD") 
format TransferDate %tdDD/NN/CCYY

generate DeathDate = date(death_date, "YMD") 									//Patient Death Date; Death is indicated by registration status being recorded as 99; 
format DeathDate %tdDD/NN/CCYY				

generate RegistrationDate = date(registration_date, "YMD") //Patient registration date to practice
format RegistrationDate %tdDD/NN/CCYY


*****relabel sex

gen Sex = 1 if sex == "M"
replace Sex = 2 if sex == "F"
label define sexLab 1 "Male" 2 "Female"
label value Sex sexLab
tab Sex
drop sex


******relabel ethnicity
encode ethnicity, gen(Ethnicity1)
recode Ethnicity1 (6 = 1 "White" ) (3 = 2 "Mixed Race" ) (4 = 3 "Others" )(1 = 4 "Black" ) (5 = 5 "South Asians" )(2 = 6 "Missing" ), gen(Ethnicity)
tab Ethnicity




********relabel age  - but will use age_at_index continuous
***age
gen Age = round(age_at_index)
sum Age, detail
recode Age (min/39=1 "Under 40 years") (40/49=2 "40 - 49 years") (50/59=3 "50 - 59 years") (60/69=4 "60 - 69 years") (70/79=5 "70 - 79 years")(80/max=6 "80 & overs"), gen (Agecat)
label var Agecat "Age categories"
tab Agecat


******relabel ethnicity // missing
gen Ethnicity = 1 if ethnicity == "WHITE"
replace Ethnicity = 2 if ethnicity == "BLACK"
replace Ethnicity = 3 if ethnicity == "SOUTH_ASIAN"
replace Ethnicity = 4 if ethnicity == "MIXED_RACE"
replace Ethnicity = 5 if ethnicity == "OTHERS"
replace Ethnicity = 6 if ethnicity == "MISSING"
label define ethnicLab 1 "White" 2 "Black" 3 "South Asian" 4 "Mixed Race" 5 "Others" 6 "Missing"
label value Ethnicity ethnicLab
tab Ethnicity
drop ethnicity







// count number of practcies 
 
 sort practice_id
by practice_id:gen n=_n
by practice_id: gen N=_N
 
 //putexcel set  "PrevalenceTableCVDMH.xlsx", modify 

keep if IndexDate == td(01/01/2020)
drop Stroke
 
 gen Stroke =0
 replace Stroke = 1 if bmischaemicstroke_bham_cam89 ==1 | bmstrokeunspecified_bham_cam92 ==1 | bmstroke_haemrgic_bham_cam93 ==1
 
 //gen StrokeTIA = 0 
 replace StrokeTIA=1 if bmtia_bham_cam0==1 | Stroke==1
 tab Stroke
 
 tab StrokeTIA
 
 //gen DiabetesAll=0
 replace DiabetesAll =1 if bmtype2diabetes_11_3_21_birm_cam ==1 | bmtype1dm_11_3_21_birm_cam41 ==1
 tab DiabetesAll

 //gen IHD=0
 replace IHD=1 if bmihd_nomi_bham_cam86==1 | bmminfarction_bham_cam0==1
 tab IHD
 tab bmminfarction_bham_cam0
 
 //gen HTNcomp =0 
 replace HTNcomp =1 if HypertensionBP==1 | Antihypertensive6month==1
 tab HTNcomp 
 
 

 
 save "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDonsCVDMH.dta", replace
 
 
 
****Prevalence calculation
local run = 1
foreach var in bmhf_bham_cam_final90 bmaf_bham_cam95 Stroke StrokeTIA bmhypertension_bham_cam84 HypertensionBP HTNcomp bmihd_nomi_bham_cam86 bmminfarction_bham_cam0 IHD bmpad_strict_bham_cam88 bmvalvulardiseases_bham_cam87 bmaorticaneurysm_bham_cam91 bmaorticaneurysm_aurum_norupture bmtype1dm_11_3_21_birm_cam41 DiabetesAll bmckdstage3to5_bham_cam104 CKD bmdepression_birm_cam38 bmanxiety_birm_cam39 bmanxietygadonlyaurum8 bmbipolar_birm_cam53 bmeatingdisorders_birm_cam52 bmschizophreniamm0 bmptsd_tlc_v20 bmalcoholmisuse_birm_cam22 bmsubstancemisuse_birm_cam8 {
	use "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDonsCVDMH.dta", clear
  
dis as blue `run' " " "`var'"
	local a = ustrregexra("`var'" ,"bm","")
	local b = ustrregexra("`a'" ,"_bi(\w*.*)","")
	local c = ustrregexra("`b'" ,"_bh(\w*.*)","")
	local d = ustrregexra("`c'" ,"_[0-9]+$","")
	local e = ustrregexra("`d'" ,"_p(\w*.*)","")	
	local f = ustrregexra("`e'" ,"_v(\w*.*)","")
	local g = ustrregexra("`f'" ,"v[0-9]+$","")
	local h = ustrregexra("`g'" ,"mm[0-9]+$","")
	local i = ustrregexra("`h'" ,"_mm(\w*.*)","")
	local j = ustrregexra("`i'" ,"mm_(\w*.*)","")
	local name = cond(substr("`j'",-1,.)=="_",substr("`j'",1,length("`j'")-1),"`j'")
	dis as red "    `name'"


count if IndexDate == td(01/01/2020)
	local genr_denominator = r(N)
	count if `var' == 1 & IndexDate == td(01/01/2020)
	local genr_numerator = r(N)
	local genr_prevalence = (`genr_numerator' / `genr_denominator')*100
	dis "    total prv = `genr_prevalence'"
	ci proportion `var'
	local genr_proportion =  r(proportion)
	local genr_lb = r(lb)
	local genr_ub = r(ub)

	clear
	set obs 1
	gen id = `run'
	gen morbidity = "`name'"
	gen genr_total = `genr_numerator' 
	gen genr_prevalence  = `genr_prevalence'
	gen genr_lowerbound = `genr_lb'
	gen genr_upperbound = `genr_ub'
	
	if `run'!=1 append using "PrevalenceTableCVDMH.dta"
	save "PrevalenceTableCVDMH.dta", replace 
	
local run = `run' + 1
}
//


 
export excel "PrevalenceTableCVDMH", firstrow(variables) replace
browse





***********************************************************************************


****Prevalence calculation by Age - median (IQR)

foreach var in bmhf_bham_cam_final90 bmaf_bham_cam95 Stroke bmhypertension_bham_cam84 HypertensionBP HTNcomp bmihd_nomi_bham_cam86 bmminfarction_bham_cam0 IHD bmpad_strict_bham_cam88 bmvalvulardiseases_bham_cam87 bmaorticaneurysm_bham_cam91 bmaorticaneurysm_aurum_norupture bmtype1dm_11_3_21_birm_cam41 DiabetesAll bmckdstage3to5_bham_cam104 CKD bmdepression_birm_cam38 bmanxiety_birm_cam39 bmanxietygadonlyaurum8 bmbipolar_birm_cam53 bmeatingdisorders_birm_cam52 bmschizophreniamm0 bmptsd110 bmautism_birm_cam68 bmalcoholmisuse_birm_cam22 bmsubstancemisuse_birm_cam8 { 
	use "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDonsCVDMH.dta", clear
  
dis as blue `run' " " "`var'"
	local a = ustrregexra("`var'" ,"bm","")
	local b = ustrregexra("`a'" ,"_bi(\w*.*)","")
	local c = ustrregexra("`b'" ,"_bh(\w*.*)","")
	local d = ustrregexra("`c'" ,"_[0-9]+$","")
	local e = ustrregexra("`d'" ,"_p(\w*.*)","")	
	local f = ustrregexra("`e'" ,"_v(\w*.*)","")
	local g = ustrregexra("`f'" ,"v[0-9]+$","")
	local h = ustrregexra("`g'" ,"mm[0-9]+$","")
	local i = ustrregexra("`h'" ,"_mm(\w*.*)","")
	local j = ustrregexra("`i'" ,"mm_(\w*.*)","")
	local name = cond(substr("`j'",-1,.)=="_",substr("`j'",1,length("`j'")-1),"`j'")
	dis as red "    `name'"




quietly sum age_at_index if `var' == 1, detail 
 gen median = r(p50)
 dis median 
 gen Q1 = r(p25) 
 dis Q1
gen Q3 = r(p75) 
dis Q3
 gen denominator = r(N)
 dis denominator
drop median Q1 Q3 denominator


}




****Prevalence calculation by deprivation quintile 

foreach var in bmhf_bham_cam_final90 bmaf_bham_cam95 Stroke bmhypertension_bham_cam84 HypertensionBP HTNcomp bmihd_nomi_bham_cam86 bmminfarction_bham_cam0 IHD bmpad_strict_bham_cam88 bmvalvulardiseases_bham_cam87 bmaorticaneurysm_bham_cam91 bmaorticaneurysm_aurum_norupture bmtype1dm_11_3_21_birm_cam41 DiabetesAll bmckdstage3to5_bham_cam104 CKD bmdepression_birm_cam38 bmanxiety_birm_cam39 bmanxietygadonlyaurum8 bmbipolar_birm_cam53 bmeatingdisorders_birm_cam52 bmschizophreniamm0 bmptsd110 bmautism_birm_cam68 bmalcoholmisuse_birm_cam22 bmsubstancemisuse_birm_cam8 {
	use "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDonsCVDMH.dta", clear
  
dis as blue `run' " " "`var'"
	local a = ustrregexra("`var'" ,"bm","")
	local b = ustrregexra("`a'" ,"_bi(\w*.*)","")
	local c = ustrregexra("`b'" ,"_bh(\w*.*)","")
	local d = ustrregexra("`c'" ,"_[0-9]+$","")
	local e = ustrregexra("`d'" ,"_p(\w*.*)","")	
	local f = ustrregexra("`e'" ,"_v(\w*.*)","")
	local g = ustrregexra("`f'" ,"v[0-9]+$","")
	local h = ustrregexra("`g'" ,"mm[0-9]+$","")
	local i = ustrregexra("`h'" ,"_mm(\w*.*)","")
	local j = ustrregexra("`i'" ,"mm_(\w*.*)","")
	local name = cond(substr("`j'",-1,.)=="_",substr("`j'",1,length("`j'")-1),"`j'")
	dis as red "    `name'"




tab2 IMDeprivation `var',mis row


}



*********** Regression analysis by age/sex/ ethnicity/deprivation ***************



foreach var in bmhf_bham_cam_final90 bmaf_bham_cam95 Stroke bmhypertension_bham_cam84 IHD bmpad_strict_bham_cam88 bmvalvulardiseases_bham_cam87 bmaorticaneurysm_bham_cam91 bmtype1dm_11_3_21_birm_cam41 bmtype2diabetes_11_3_21_birm_cam bmckdstage3to5_bham_cam104 bmdepression_birm_cam38 bmanxiety_birm_cam39  bmbipolar_birm_cam53 bmeatingdisorders_birm_cam52 bmschizophreniamm0 bmptsd_tlc_v20 bmalcoholmisuse_birm_cam22 bmsubstancemisuse_birm_cam8 {
	use "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDonsCVDMH.dta", clear
  
dis as blue `run' " " "`var'"
	local a = ustrregexra("`var'" ,"bm","")
	local b = ustrregexra("`a'" ,"_bi(\w*.*)","")
	local c = ustrregexra("`b'" ,"_bh(\w*.*)","")
	local d = ustrregexra("`c'" ,"_[0-9]+$","")
	local e = ustrregexra("`d'" ,"_p(\w*.*)","")	
	local f = ustrregexra("`e'" ,"_v(\w*.*)","")
	local g = ustrregexra("`f'" ,"v[0-9]+$","")
	local h = ustrregexra("`g'" ,"mm[0-9]+$","")
	local i = ustrregexra("`h'" ,"_mm(\w*.*)","")
	local j = ustrregexra("`i'" ,"mm_(\w*.*)","")
	local name = cond(substr("`j'",-1,.)=="_",substr("`j'",1,length("`j'")-1),"`j'")
	dis as red "    `name'"

logit  `var' i.Sex ib4.Agecat i.Ethnicity i.IMDeprivation, or nolog


}





