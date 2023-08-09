

use "/rds/projects/c/cooperjx-ltc-covid/IncPrev/PointPrevalence_AURUMaddons5.dta", replace

generate CCBDate = date(bd_drugcalciumchannelblck_d2t4, "YMD")
format CCBDate %tdDD/NN/CCYY

generate BetablockerDate = date(bd_drugbetablockers_optimal3, "YMD")
format BetablockerDate %tdDD/NN/CCYY 

generate DiureticsDate = date(bd_drugall_diuretics_d2t1, "YMD")
format DiureticsDate %tdDD/NN/CCYY 

generate ACEiDate = date(bd_drugace_inhibitors_d2t5, "YMD")
format ACEiDate %tdDD/NN/CCYY 

generate ARBsDate = date(bd_drugarbs_luyuan7, "YMD")
format ARBsDate %tdDD/NN/CCYY 

generate Bblocker =1 if bdbetablockers_optimal3==1
generate CCB =1 if bdcalciumchannelblck_d2t4==1
gen ACEi =1 if bdace_inhibitors_d2t5==1
gen Diuretics =1 if bdall_diuretics_d2t1 ==1
gen ARBs = 1 if bdarbs_luyuan7==1

replace Bblocker =. if BetablockerDate < td(01/06/2019)
replace CCB =. if CCBDate< td(01/06/2019)
replace ACEi =. if ACEiDate< td(01/06/2019)
replace Diuretics =. if DiureticsDate< td(01/06/2019)
replace ARBs =. if ARBsDate< td(01/06/2019)

generate Antihypertensive6month =1 if Bblocker==1 | CCB==1 | ACEi==1 | Diuretics==1 | ARBs ==1

gen Sys=value_blood
replace Sys =. if value_blood>220
replace Sys =. if value_blood<60

gen Dias=v29
replace Dias =. if v29 >120
replace Dias=. if v29 <30 

gen SysHome=value_home
replace SysHome=. if value_home > 220
replace SysHome=. if value_home <60

gen DiasHome=v41
replace DiasHome=. if v41 >120
replace DiasHome=. if v41 <30

replace Sys=. if v29>value_blood
replace Dias=. if v29>value_blood

replace SysHome=. if v41>value_home
replace DiasHome=. if v41>value_home


 
 
generate SysDate = date(bd_systolic_blood_pressure_1_blo, "YMD")
format SysDate %tdDD/NN/CCYY

generate DiasDate = date(bd_diastolic_blood_pressure_2_bl, "YMD")
format DiasDate %tdDD/NN/CCYY

 
generate SysHomeDate = date(bd_average_home_systolic_blood_p, "YMD")
format SysHomeDate %tdDD/NN/CCYY

generate DiasHomeDate = date(bd_average_home_diastolic_blood_, "YMD")
format DiasHomeDate %tdDD/NN/CCYY
 
 replace Sys=. if SysDate<td(01/01/2017)
  replace SysHome=. if SysHomeDate<td(01/01/2017)
  replace Dias=. if DiasDate<td(01/01/2017)
  replace DiasHome=. if DiasHomeDate<td(01/01/2017)
 
 gen SysHypertensionBP =0 
 replace SysHypertensionBP = 1 if Sys>139
 replace SysHypertensionBP=0 if Sys==.
 
 gen DiasHypertensionBP=0
 replace DiasHypertensionBP=1 if Dias >79
 replace DiasHypertensionBP = 0 if Dias==.
 
 gen HypertensionBP=0
 replace HypertensionBP=1 if DiasHypertensionB==1
 replace HypertensionBP=1 if SysHypertensionBP==1
 tab HypertensionBP
 
 keep practice_patient_id bmminfarction_bham_cam0 bmanxietygadonlyaurum8 HypertensionBP SysHypertensionBP DiasHypertensionBP Antihypertensive6month 
 
 *** check antihypertensive data***
merge m:1 practice_patient_id using "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDons1.dta"

drop _merge 


save "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDons1.dta", replace




gen CreatUnit=.
replace CreatUnit=1 if numunit_creatinine =="umol/L" 
replace CreatUnit=1 if numunit_creatinine =="micmol/l"
replace CreatUnit=1 if numunit_creatinine =="micromol/L"
gen CreatValue=value_creatinine if CreatUnit==1
replace CreatValue=. if value_creatinine==0 
replace CreatValue=. if value_creatinine>3000 

sum CreatValue, detail

*******create eGFR categories with CKD-EPI formula
generate CreatinineDate = date(bd_serum_creatinine_1_creatinine, "YMD")
format CreatinineDate %tdDD/NN/CCYY

replace CreatValue=. if CreatinineDate <td(01/01/2017)

rename CreatValue CreatResult2
keep practice_patient_id CreatResult2 CreatinineDate






save "/rds/projects/c/cooperjx-ltc-covid/IncPrev/PointPrevalence_AURUMCreat.dta", replace

clear 
use "/rds/projects/c/cooperjx-ltc-covid/IncPrev/PointPrevalence_AURUMCreat.dta", clear
 
merge m:1 practice_patient_id using "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDons1.dta"

drop _merge 


save "/rds/projects/c/cooperjx-ltc-covid/PointPrevalence_AURUM_ADDons1.dta", replace

rename CreatResult2 CreatResultFinal



gen ageatcreatinine = (CreatinineDate - YearofBirth)/ 365.25
sum ageatcreatinine, detail
***** CKD ******
gen CalculatedGFR = .
replace CalculatedGFR = 141 * min((CreatResultFinal * 0.0113122/0.7), 1)^(-0.329) * max((CreatResultFinal * 0.0113122/0.7), 1)^(-1.209) * (0.993^ageatcreatinine) * (1.018) * (1.159) if CreatResultFinal > 0 & CreatResultFinal!=. & Sex == 1  & Ethnicity ==2   
replace CalculatedGFR = 141 * min((CreatResultFinal * 0.0113122/0.7), 1)^(-0.329) * max((CreatResultFinal * 0.0113122/0.7), 1)^(-1.209) * (0.993^ageatcreatinine) * (1.018) if CreatResultFinal > 0 & CreatResultFinal!=. & Sex == 1  & Ethnicity !=2
replace CalculatedGFR = 141 * min((CreatResultFinal * 0.0113122/0.9), 1)^(-0.411) * max((CreatResultFinal * 0.0113122/0.9), 1)^(-1.209) * (0.993^ageatcreatinine) * (1.159) if CreatResultFinal > 0 & CreatResultFinal!=. & Sex == 2  & Ethnicity ==2
replace CalculatedGFR = 141 * min((CreatResultFinal * 0.0113122/0.9), 1)^(-0.411) * max((CreatResultFinal * 0.0113122/0.9), 1)^(-1.209) * (0.993^ageatcreatinine) if CreatResultFinal > 0 & CreatResultFinal!=. & Sex == 2  & Ethnicity !=2 

count if CreatResultFinal ==0  

 
 ***********
replace CalculatedGFR =. if CalculatedGFR > 200 
replace CalculatedGFR =. if CreatResultFinal==0
label var CalculatedGFR "eGFR --> ml/min/1.73m²"
misstable summarize CalculatedGFR
sum CalculatedGFR, detail


recode CalculatedGFR (min/14.9999999999 = 6 "<15 (Stage 5)") (15/29.9999999999 = 5 "15-29 (Stage 4)") (30/44.9999999999 = 4 "30-44 (Stage 3b)") (45/59.9999999999 = 3 "45-59 (Stage 3a)") (60/89.9999999999 = 2 "60-89 (Stage 2)") (90/300 = 1 ">=90 (Stage 1)") (missing = 88 "missing or implausible values"), gen(CalculatedGFRCat)
label var CalculatedGFRCat "eGFR categories at baseline"
tab CalculatedGFRCat 

gen CKD=0
replace CKD=1 if CalculatedGFR<60
tab2 CKD CalculatedGFRCat 

tab2 CKD Sex, col

tab2 tab2 bmckdstage3to5_bham_cam104 Sex, col




