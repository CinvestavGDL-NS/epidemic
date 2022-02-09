/**
* Name: precalcroutes
*  
* Author: Gamaliel Palomo
* Tags: 
*/


model preprocess
import "Constants.gaml"


global{
	geometry shape <- envelope(limits_shp);
	int tot_0to2 					<-0;
	int tot_3to5 					<-0;
	int tot_6to11 					<-0;
	int tot_12to14 				<-0;
	int tot_15to17 				<-0;
	int tot_18to24 				<-0;
	int tot_25to64 				<-0;
	int tot_65_and_more 		<-0;
	int tot_people 				<-0;
	
	int range 	parameter:"range" category:"Model parameters" 	<- 10 min:0 max:100;
	
	graph road_network;
	map<road, float> weight_map;
	int nb_paths <- 0;
	
	int family_counter <- 0;
	
	init{
		create block from:blocks_shp with:[
			nb_people::int(read("POBTOT")),
			nb_0to2::int(read("P_0A2")),
			nb_3to5::int(read("P_3A5")),
			nb_6to11::int(read("P_6A11")),
			nb_12to14::int(read("P_12A14")),
			nb_15to17::int(read("P_15A17")),
			nb_18to24::int(read("P_18A24")),
			nb_65_and_more::int(read("POB65_MAS"))
		]{
			tot_people 			<- tot_people + nb_people;
			tot_0to2					<- tot_0to2 + nb_0to2;
			tot_3to5					<- tot_3to5 + nb_3to5;
			tot_6to11				<- tot_6to11 + nb_6to11;
			tot_12to14			<- tot_12to14 + nb_12to14;
			tot_15to17			<- tot_15to17 + nb_15to17;
			tot_18to24			<- tot_18to24 + nb_18to24;
			tot_65_and_more			<- tot_65_and_more + nb_65_and_more;
			tot_25to64 				<- tot_people - tot_65_and_more - tot_0to2 -tot_3to5 - tot_6to11 - tot_12to14 - tot_15to17 - tot_18to24;
		}
		blocks_shp <- [];
		create workplace from:denue_shp with:[place_name::string(read("nom_estab")),str_nb_employees::string(read("per_ocu")),id::string(read("id"))];
		denue_shp <- [];
		int available_jobs <- 0;
		ask workplace{
			list words <- str_nb_employees split_with(" ");
			if words[1] = "a"{
				nb_employees <- int(words[2]);
			}
			else if words[1] = "y"{
				nb_employees <- int(words[0]);
			}
			available_jobs <- available_jobs + nb_employees;
		}
		write "available jobs: "+available_jobs;
		write "available work places: "+length(workplace);
		list<block> tmp_zero_pop <- block where(each.nb_people = 0);
		int zero_blocks <- length(tmp_zero_pop);
		if zero_blocks > 0{
			loop i from:0 to:INEGI_0to2-tot_0to2-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_0to2 <- nb_0to2 + 1;
				}
			}
			loop i from:0 to:INEGI_3to5-tot_3to5-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_3to5 <- nb_3to5 + 1;
				}
			}
			loop i from:0 to:INEGI_6to11-tot_6to11-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_6to11 <- nb_6to11 + 1;
				}
			}
			loop i from:0 to:INEGI_12to14-tot_12to14-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_12to14 <- nb_12to14 + 1;
				}
			}
			loop i from:0 to:INEGI_15to17-tot_15to17-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_15to17 <- nb_15to17 + 1;
				}
			}
			loop i from:0 to:INEGI_18to24-tot_18to24-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_18to24 <- nb_18to24 + 1;
				}
			}
			loop i from:0 to:INEGI_25to64-tot_25to64-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_25to64 <- nb_25to64 + 1;
				}
			}
			loop i from:0 to:INEGI_65_and_more-tot_65_and_more-1{
				ask one_of(tmp_zero_pop){
					nb_people <- nb_people + 1;
					nb_65_and_more <- nb_65_and_more + 1;
				}
			}
		}
		ask block{
			int nb_families <- int(nb_people/family_size);
			list<people> people_living_here <- create_people();
			write self.name + " ---------------------------";
			loop i from:1 to: nb_families{
				point family_location <- any_location_in(self);
				write "Family "+i+":";
				list<people> current_family;
				loop j from:1 to:family_size{
					people choosen_one <- one_of(people_living_here);
					add choosen_one to:current_family;
					remove choosen_one from:people_living_here;
				}
				ask current_family{
					family_id <- family_counter;
					location <- {family_location.x+rnd(-5,5),family_location.y+rnd(-5,5)};
					my_family <- current_family;
					write my_family;
				}
				family_counter <- family_counter + 1;
			}
		}
		ask workplace{
			loop i from:1 to:nb_employees{
				ask one_of(people where(each.age>=18 and each.age<65 and each.my_workplace = nil)){
					my_workplace <- myself;
					my_workplace_str <- my_workplace.place_name;
				}
			}
		}
		
		/*create road from:roads_shp;
		weight_map 			<- road as_map(each::each.shape.perimeter);
		road_network 		<- as_edge_graph(road) with_weights weight_map;
		roads_shp <- [];
		int components <- length(connected_components_of(road_network));
		write "Graph components: "+ components;		
		save road_network to:"road_network.txt" type:"text" rewrite:true;
		create test_point number:1000;
		
		ask people where(each.age>=25 and each.age<65 and each.my_workplace != nil){
			path the_path <- path_between(road_network,self.location,self.my_workplace.location);
			add "home-work"::the_path to: my_paths;
			write the_path;
		}*/
		save workplace to:"../includes/gis/elarenal_workplaces.shp" type:"shp" attributes:["name"::place_name,"nb_employees"::nb_employees,"id"::id] crs:"EPSG:4326";
		save people to:"../includes/gis/elarenal_people.shp" type:"shp" attributes:["age"::age,"my_workplace"::my_workplace.id, "family_id"::family_id] crs:"EPSG:4326";
	}
	
}

species road{
	aspect default{draw shape color:rgb(50,50,50,0.7) width:1.5;}
}

species block{
	//Population
	int nb_0to2;
	int nb_3to5;
	int nb_6to11;
	int nb_12to14;
	int nb_15to17;
	int nb_18to24;
	int nb_25to64;
	int nb_65_and_more;
	int nb_people;
	list<people> create_people{
		list<people> output;
		nb_25to64 <- nb_people-nb_65_and_more-nb_0to2-nb_3to5-nb_6to11-nb_12to14-nb_15to17-nb_18to24;
		create people number:nb_0to2 {
			age <- rnd(0,2);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_3to5 {
			age <- rnd(3,5);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_6to11 {
			age <- rnd(6,11);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_12to14 {
			age <- rnd(12,14);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_15to17 {
			age <- rnd(15,17);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_18to24 {
			age <- rnd(18,24);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_25to64 {
			age <- rnd(25,64);
			location <- any_location_in(myself);
			add self to:output;
		}
		create people number:nb_65_and_more {
			age <- rnd(65,100);
			location <- any_location_in(myself);
			add self to:output;
		}
		return output;
	}
	aspect default{
		draw shape color:rgb(50,50,50,0.5);
	}
}

species test_point parallel:true{
	point objective;
	path my_path <- nil;
	init{
		location <- any_location_in(one_of(block));
		objective <- any_location_in(one_of(block));
	}
	reflex main when:my_path=nil{
		my_path <- path_between(road_network,location,objective);
		if my_path = nil{
			
			location <- {location.x+rnd(-1*range,range),location.y+rnd(-1*range,range)};
			objective <- {objective.x+rnd(-1*range,range),objective.y+rnd(-1*range,range)};
			//location <- road_network.vertices closest_to self;//any_location_in(one_of(block));
			//objective <- road_network.vertices closest_to objective;
		}
		else{
			nb_paths <- nb_paths +1;
		}
	}
	aspect default{
		draw triangle(100) color:#green at:location;
		draw triangle(100) color:#red at:objective;
		if my_path != nil{
			draw my_path.shape color:#yellow;
		} 
	}
}

species people skills:[moving] parallel:500{
	
	int age;
	string my_workplace_str;
	workplace my_workplace <- nil;
	map<string,path> my_paths;
	
	//Mobility
	point target;
	float speed 					<- 1.4;
	string mobility_profile 	<- one_of(["bus","car","walk","bicycle"]);
	
	//Social-economical variables
	bool essential_worker;
	
	//Family
	int family_id;
	list<people> my_family;
	
	//Agenda related variables
	point home;
	map<date,point> agenda_day;
	aspect color_by_age{
		rgb color_by_age;
		if age <=2{color_by_age <- #blue;}
		else if age <= 5{color_by_age <- #orange;}
		else if age <= 11{color_by_age <- #green;}
		else if age <= 14{color_by_age <- #white;}
		else if age <=17{color_by_age <- #turquoise;}
		else if age <=24{color_by_age <- #yellowgreen;}
		else if age >=25 and age <65{color_by_age <- rgb (255, 255, 0,255);}
		else if age >=65{color_by_age <- rgb (255, 0, 128,255);}
		draw circle(3) color:color_by_age;
		ask my_family{
			draw line(self.location,myself.location) color:#green;
		}
	}
}

species hospital{
	int beds;
	int intensive_care_beds;
	block belongs_to;
	
	init {
		belongs_to 	<- block(int(length(block)/2));
		shape 			<- belongs_to.shape;
		location 		<- belongs_to.location;
		beds 				<- init_beds;
		intensive_care_beds <- init_icbeds;
	}
	aspect default{
		draw shape color:rgb (96, 191, 232,255);
	}
}

species workplace{
	string id;
	string place_name;
	string str_nb_employees;
	int nb_employees;
	aspect default{
		draw square(30) color:#blue;
	}
}

experiment preprocess type:gui{
	output{
		monitor "Paths computed" value: nb_paths;
		display output background:#black type:opengl{
			species workplace aspect:default refresh:false;
			species road aspect:default refresh:false;
			species people aspect:color_by_age refresh:false;
			species test_point aspect:default;
		}
	}
}