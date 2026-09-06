local curstatestr=`"`1'"'

if `"`curstatestr'"'=="Alabama" {
	global scraper_ass_num=1
}
if `"`curstatestr'"'=="Alaska" {
	global scraper_ass_num=2
}	
else if `"`curstatestr'"'=="Arizona" {
	global scraper_ass_num=4
}
else if `"`curstatestr'"'=="Arkansas" {
	global scraper_ass_num=5
}
else if `"`curstatestr'"'=="California" {
	global scraper_ass_num=6
}
else if `"`curstatestr'"'=="Colorado" {
	global scraper_ass_num=7
}
else if `"`curstatestr'"'=="Connecticut" {
	global scraper_ass_num=8
}
else if `"`curstatestr'"'=="Delaware" {
	global scraper_ass_num=9
}
else if `"`curstatestr'"'=="District of Columbia" {
	global scraper_ass_num=10
}
else if `"`curstatestr'"'=="Florida" {
	global scraper_ass_num=11
}
else if `"`curstatestr'"'=="Georgia" {
	global scraper_ass_num=12
}	
else if `"`curstatestr'"'=="Hawaii" {
	global scraper_ass_num=14
}
else if `"`curstatestr'"'=="Idaho" {
	global scraper_ass_num=15
}
else if `"`curstatestr'"'=="Illinois" {
	global scraper_ass_num=16
}
else if `"`curstatestr'"'=="Indiana" {
	global scraper_ass_num=17
}
else if `"`curstatestr'"'=="Iowa" {
	global scraper_ass_num=18
}
else if `"`curstatestr'"'=="Kansas" {
	global scraper_ass_num=19
}
else if `"`curstatestr'"'=="Kentucky" {
	global scraper_ass_num=20
}
else if `"`curstatestr'"'=="Louisiana" {
	global scraper_ass_num=21
}
else if `"`curstatestr'"'=="Maine" {
	global scraper_ass_num=22
}
else if `"`curstatestr'"'=="Maryland" {
	global scraper_ass_num=23
}
else if `"`curstatestr'"'=="Massachusetts" {
	global scraper_ass_num=24
}
else if `"`curstatestr'"'=="Michigan" {
	global scraper_ass_num=25
}
else if `"`curstatestr'"'=="Minnesota" {
	global scraper_ass_num=26
}
else if `"`curstatestr'"'=="Mississippi" {
	global scraper_ass_num=27
}	
else if `"`curstatestr'"'=="Missouri" {
	global scraper_ass_num=28
}
else if `"`curstatestr'"'=="Montana" {
	global scraper_ass_num=29
}
else if `"`curstatestr'"'=="Nebraska" {
	global scraper_ass_num=30
}
else if `"`curstatestr'"'=="Nevada" {
	global scraper_ass_num=31
}
else if `"`curstatestr'"'=="New Hampshire" {
	global scraper_ass_num=32
}
else if `"`curstatestr'"'=="New Jersey" {
	global scraper_ass_num=33
}	
else if `"`curstatestr'"'=="New Mexico" {
	global scraper_ass_num=34
}	
else if `"`curstatestr'"'=="New York" {
	global scraper_ass_num=35
}
else if `"`curstatestr'"'=="North Carolina" {
	global scraper_ass_num=36
}
else if `"`curstatestr'"'=="North Dakota" {
	global scraper_ass_num=37
}	
else if `"`curstatestr'"'=="Ohio" {
	global scraper_ass_num=38
}	
else if `"`curstatestr'"'=="Oklahoma" {
	global scraper_ass_num=39
}
else if `"`curstatestr'"'=="Oregon" {
	global scraper_ass_num=40
}
else if `"`curstatestr'"'=="Pennsylvania" {
	global scraper_ass_num=42
}
else if `"`curstatestr'"'=="Rhode Island" {
	global scraper_ass_num=44
}	
else if `"`curstatestr'"'=="South Carolina" {
	global scraper_ass_num=45
}
else if `"`curstatestr'"'=="South Dakota" {
	global scraper_ass_num=46
}
else if `"`curstatestr'"'=="Tennessee" {
	global scraper_ass_num=47
}
else if `"`curstatestr'"'=="Texas" {
	global scraper_ass_num=48
}
else if `"`curstatestr'"'=="Utah" {
	global scraper_ass_num=49
}
else if `"`curstatestr'"'=="Vermont" {
	global scraper_ass_num=50
}
else if `"`curstatestr'"'=="Virginia" {
	global scraper_ass_num=52
}
else if `"`curstatestr'"'=="Washington" {
	global scraper_ass_num=53
}
else if `"`curstatestr'"'=="West Virginia" {
	global scraper_ass_num=54
}
else if `"`curstatestr'"'=="Wisconsin" {
	global scraper_ass_num=55
}
else if `"`curstatestr'"'=="Wyoming" {
	global scraper_ass_num=56
}

global state_file_name=lower(subinstr(`"`curstatestr'"'," ","_",.))
