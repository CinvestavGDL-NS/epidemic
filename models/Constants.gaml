/***
* Name: Constants
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Constants

global{
	file limits_shp <- file("../includes/gis/elarenal_limit.shp");
	file roads_shp <- file("../includes/gis/elarenal_roads.shp");
	//file blocks_shp <- file("../includes/gis/test_blocks.shp");
	file blocks_shp <- file("../includes/gis/elarenal_blocks.shp");
	file denue_shp <- file("../includes/gis/elarenal_denue.shp");
	file workplaces_shp <- file("../includes/gis/elarenal_workplaces.shp");
	file people_shp <- file("../includes/gis/elarenal_people.shp");
	file schools_shp <- file("../includes/gis/elarenal_schools.shp");
	file parks_shp <- file("../includes/gis/elarenal_parks.shp");
	
	float the_seed <- 55.0;
	
	//Hospital variables
	int init_beds 		<-	1; 
	int init_icbeds		<-	1;
	
	//Reported INEGI data about population and age distribution
	int INEGI_tot 			<- 21115;
	int INEGI_0to2 		<- 1201;
	int INEGI_3to5 		<- 1223;
	int INEGI_6to11 		<- 2515;
	int INEGI_12to14		<- 1215;
	int INEGI_15to17		<- 1192;
	int INEGI_18to24		<- 2540;
	int INEGI_65_and_more <- 1485;
	int INEGI_25to64		<- INEGI_tot-INEGI_65_and_more-INEGI_0to2-INEGI_3to5-INEGI_6to11-INEGI_12to14-INEGI_15to17-INEGI_18to24;
	
	//Average people by family
	int family_size		<- 4;
	
	int t1 <- 5;			//Incuvation period
	int t2 <- 25;		//Symptomatic period
	int t3 <- 15;		//Asymptomatic period
	int t4 <- 180;			//Immunity period
	
}