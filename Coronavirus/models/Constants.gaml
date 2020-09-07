/***
* Name: Constants
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Constants

global{
	int t1 <- 5;	//Incuvation period
	int t2 <- 25;	//Symptomatic period
	int t3 <- 15;	//Asymptomatic period
	int t4 <- 3;	//Time to know if become immune
}