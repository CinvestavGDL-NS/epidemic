/***
* Name: Constants
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Constants

global{
	file roads_shp <- file("../includes/gis/test_roads.shp");
	file blocks_shp <- file("../includes/gis/test_blocks.shp");
	
	int t1 <- 5;	//Incuvation period
	int t2 <- 25;	//Symptomatic period
	int t3 <- 15;	//Asymptomatic period
	int t4 <- 3;	//Time to know if become immune
	
	//Mobility related constants
	map<string,float> mobility_speeds <- ["bicycle"::2.0,"car"::4.0,"walk"::1.4];
}