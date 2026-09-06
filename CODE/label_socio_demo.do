gen socio_demo_label=""

replace socio_demo_label="Households" if v1=="gq" & v2==0
replace socio_demo_label="Group quarters" if v1=="gq" & v2==1

replace socio_demo_label="Related to head" if v1=="relate" & v2==1
replace socio_demo_label="In-laws" if v1=="relate" & v2==2
replace socio_demo_label="Non-relatives" if v1=="relate" & v2==3
replace socio_demo_label="Inmates" if v1=="relate" & v2==4

replace socio_demo_label="Ever married" if v1=="marst" & v2==1
replace socio_demo_label="Never married" if v1=="marst" & v2==2

replace socio_demo_label="Whites" if v1=="race" & v2==1
replace socio_demo_label="Non-whites" if v1=="race" & v2==2

replace socio_demo_label="US-born" if v1=="bpl" & v2==1
replace socio_demo_label="Foreign-born" if v1=="bpl" & v2==2

replace socio_demo_label="Not in school" if v1=="school" & v2==1
replace socio_demo_label="In school" if v1=="school" & v2==2

replace socio_demo_label="No schooling" if v1=="higrade" & v2==1
replace socio_demo_label="Some elem. sch." if v1=="higrade" & v2==2
replace socio_demo_label="Some mid. sch." if v1=="higrade" & v2==3
replace socio_demo_label="Some high sch. " if v1=="higrade" & v2==4
replace socio_demo_label="Some univ./col." if v1=="higrade" & v2==5
replace socio_demo_label="Some grad. sch." if v1=="higrade" & v2==6

replace socio_demo_label="Employed" if v1=="empstat" & v2==1
replace socio_demo_label="Unemployed" if v1=="empstat" & v2==2
replace socio_demo_label="Out of labor force" if v1=="empstat" & v2==3

replace socio_demo_label="Out of labor force" if v1=="labforce" & v2==1
replace socio_demo_label="In labor force" if v1=="labforce" & v2==2

replace socio_demo_label="Self-employed" if v1=="classwkr" & v2==1
replace socio_demo_label="Works for wages" if v1=="classwkr" & v2==2

replace socio_demo_label="Professional" if v1=="occ1950" & v2==0
replace socio_demo_label="Farmers" if v1=="occ1950" & v2==1
replace socio_demo_label="Managers" if v1=="occ1950" & v2==2
replace socio_demo_label="Clerical" if v1=="occ1950" & v2==3
replace socio_demo_label="Sales workers" if v1=="occ1950" & v2==4
replace socio_demo_label="Craftsmen" if v1=="occ1950" & v2==5
replace socio_demo_label="Operatives" if v1=="occ1950" & v2==6
replace socio_demo_label="Service Workers" if v1=="occ1950" & v2==7
replace socio_demo_label="Farm Laborers" if v1=="occ1950" & v2==8
replace socio_demo_label="Laborers" if v1=="occ1950" & v2==9

replace socio_demo_label="Agriculture" if v1=="ind1950" & v2==1
replace socio_demo_label="Mining" if v1=="ind1950" & v2==2
replace socio_demo_label="Construction" if v1=="ind1950" & v2==3
replace socio_demo_label="Manufacturing" if v1=="ind1950" & v2==4
replace socio_demo_label="Utilities" if v1=="ind1950" & v2==5
replace socio_demo_label="Retail" if v1=="ind1950" & v2==6
replace socio_demo_label="Finance" if v1=="ind1950" & v2==7
replace socio_demo_label="Business services" if v1=="ind1950" & v2==8
replace socio_demo_label="Personal services" if v1=="ind1950" & v2==9
replace socio_demo_label="Entertainment services" if v1=="ind1950" & v2==10
replace socio_demo_label="Professional services" if v1=="ind1950" & v2==11
replace socio_demo_label="Public administration" if v1=="ind1950" & v2==12

replace socio_demo_label="Worked 1-13 wks." if v1=="wkswork2" & v2==1
replace socio_demo_label="Worked 14-26 wks." if v1=="wkswork2" & v2==2
replace socio_demo_label="Worked 27-39 wks." if v1=="wkswork2" & v2==3
replace socio_demo_label="Worked 40-47 wks." if v1=="wkswork2" & v2==4
replace socio_demo_label="Worked 48-49 wks." if v1=="wkswork2" & v2==5
replace socio_demo_label="Worked 50-52 wks." if v1=="wkswork2" & v2==6

replace socio_demo_label="Worked 1-14 hrs." if v1=="hrswork2" & v2==1
replace socio_demo_label="Worked 15-29 hrs." if v1=="hrswork2" & v2==2
replace socio_demo_label="Worked 30-34 hrs." if v1=="hrswork2" & v2==3
replace socio_demo_label="Worked 35-39 hrs." if v1=="hrswork2" & v2==4
replace socio_demo_label="Worked 40 hrs." if v1=="hrswork2" & v2==5
replace socio_demo_label="Worked 41-48 hrs." if v1=="hrswork2" & v2==6
replace socio_demo_label="Worked 49-59 hrs." if v1=="hrswork2" & v2==7
replace socio_demo_label="Worked 60+ hrs." if v1=="hrswork2" & v2==8

replace socio_demo_label="Same house" if v1=="migrate5" & v2==1
replace socio_demo_label="Same state" if v1=="migrate5" & v2==2
replace socio_demo_label="Moved btw. states" if v1=="migrate5" & v2==3
replace socio_demo_label="Abroad 5yrs ago" if v1=="migrate5" & v2==4

replace socio_demo_label="Nonwage inc.>50" if v1=="incnonwg" & v2==2

replace socio_demo_label="English is not mother tongue" if v1=="non_english_mtongue" & v2==1
replace socio_demo_label="English is mother tongue" if v1=="non_english_mtongue" & v2==0
