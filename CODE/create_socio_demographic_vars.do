/********************************************************************************/
/*THIS CODE CONSTRUCTS SOCIO-DEMOGRAPHIC VARIABLES THAT ARE USED IN THE ANALYSES*/
/********************************************************************************/
/*FEMALE DUMMY*/
gen female=sex==2 if sex>=1 & sex<=2
label var female "Female"

/*RACE DUMMY*/
gen black=floor(race/100)==2 if race>=100 & race<=620
gen american_indian=floor(race/100)==3 if race>=100 & race<=620
gen asian=floor(race/100)>=4 & floor(race/100)<=6 if race>=100 & race<=620

label var black "Black"
label var american_indian "American Indian"
label var asian "Asian"

label var age "Age"

/*
/*LITERACY DUMMY*/
gen literate=lit==4 if lit>=1 & lit<=4
label var literate "Can read \& write"
*/

gen no_ed=higrade>=10 & higrade<=12 if higrade>=10 & higrade<=230
label var no_ed "No education"

gen grad_elem=higrade>=110 & higrade<=230 if higrade>=10 & higrade<=230
label var grad_elem "Graduated elementary sch."

/*FOREIGN-BORN DUMMY*/
gen foreign_born=!(bpl>=100 & bpl<=12092) if bpl>=100 & bpl<=90022
label var foreign_born "Foreign-born"

/*FOREIGN-BORN FATHER DUMMY*/
gen father_foreign_born=!(fbpl>=100 & fbpl<=12092) if fbpl>=100 & fbpl<=90022
label var father_foreign_born "Father is foreign-born"

/*"CURRENTLY ENROLLED IN SCHOOL" DUMMY*/
gen in_school=school==2 if school>=1 & school<=2

/*"RELATED-TO-HEAD OF HOUSEHOLD" DUMMY*/
gen related_to_head=floor(relate/100)>=1 & floor(relate/100)<=10 if floor(relate/100)>=1 & floor(relate/100)<=13
label var related_to_head "Related to head"

/*"EVER MARRIED" DUMMY*/
gen ever_married=marst>=1 & marst<=5 if marst>=1 & marst<=6
label var ever_married "Ever married"

/*BIRTH CENSUS REGION DUMMIES*/
gen bpl_orig=bpl
replace bpl=floor(bpl/100)

gen northeast_bpl=(bpl==9|bpl==23|bpl==25|bpl==33|bpl==44|bpl==50|bpl==34|bpl==36|bpl==42) if bpl!=.
gen midwest_bpl=bpl==17|bpl==18|bpl==26|bpl==39|bpl==55|bpl==19|bpl==20|bpl==27|bpl==29|bpl==31|bpl==38|bpl==46 if bpl!=.
gen south_bpl=bpl==10|bpl==11|bpl==12|bpl==13|bpl==24|bpl==37|bpl==45|bpl==51|bpl==54|bpl==1|bpl==21|bpl==28|bpl==47|bpl==5|bpl==22|bpl==40|bpl==48 if bpl!=.
gen west_bpl=bpl==4|bpl==8|bpl==16|bpl==30|bpl==32|bpl==35|bpl==49|bpl==56|bpl==2|bpl==6|bpl==15|bpl==41|bpl==53 if bpl!=.

replace bpl=bpl_orig
drop bpl_orig

/*********************************************************************************/
/*OCCUPATION CATEGORIES BASED ON LONG AND FERRIE (2013, AMERICAN ECONOMIC REVIEW)*/
/*********************************************************************************/
#delimit;
/*WHITE COLLAR*/
gen white_color=(occ1950>=0 & occ1950<=99)| /*PROFESSIONAL, TECHNICAL*/
(occ1950>=200 & occ1950<=290)| /*MANAGERS, OFFICIALS, AND PROPRIETORS*/
(occ1950>=300 & occ1950<=390)| /*CLERICAL*/
(occ1950>=400 & occ1950<=490) if occ1950!=. & occ1950>=0 & occ1950<=970; /*SALES*/

label var white_color "White-collar";

/*FARMER*/
gen farmer=occ1950==100|occ1950==123 if occ1950!=. & occ1950>=0 & occ1950<=970; /*FARM OWNERS (INCLUDING TENANTS, BECAUSE WE CANNOT DIFFERENTIATE BETWEEN OWNER AND TENANTS) AND FARM MANAGERS*/

label var farmer "Farmer";

/*SKILLED*/
gen skilled=(occ1950>=500 & occ1950<=595)| /*CRAFTSMEN*/
(occ1950>=600 & occ1950<=690) if occ1950!=. & occ1950>=0 & occ1950<=970; /*OPERATIVES*/

label var skilled "Skilled";

/*UNSKILLED*/
gen unskilled=(occ1950>=700 & occ1950<=790)| /*SERVICE WORKERS*/
(occ1950>=810 & occ1950<=840)| /*FARM LABORERS*/
(occ1950>=910 & occ1950<=970) if occ1950!=. & occ1950>=0 & occ1950<=970; /*LABORERS*/

label var unskilled "Unskilled";

#delimit cr

/*RECODE EXISTING VARIABLES*/
replace urban=. if !(urban>=1 & urban<=2)
replace farm=. if !(farm>=1 & farm<=2)

recode urban (2=1) (1=0)
replace urban=. if urban!=1 & urban!=0

recode farm (2=1) (1=0)
replace farm=. if farm!=1 & farm!=0	

label var farm "Live on farm"
label var urban "Live in urban area"

/*INCOME AND WAGE*/
replace incwage=. if incwage>5001
label var incwage "Yearly income"

/*LABEL VARIABLES*/
label variable in_school "Attending school"
label variable northeast_bpl "Born in Northeast"
label variable midwest_bpl "Born in Midwest"
label variable south_bpl "Born in South"
label variable west_bpl "Born in West"

/*
/*KEEP ONLY THE NECESSARY VARIABLES*/
keep serial pernum unique_ID urban farm sex age birthyr realprop persprop verified-unskilled `additional_var'
