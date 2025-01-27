 /***
* Name: coronavirus
* Author: Gamaliel Palomo and Mario Siller
* Description: Modelo que permite conocer el impacto de la cultura, educación, forma de vida de la población en méxico en el patrón de dispersión del vírus.
* El modelo considera agentes que son personas, estas personas tienen comportamientos que se rigen dependiendo de ciertas variables como el nivel socio-economico. 
* Las personas con una alta necesidad de realizar actividades económicas se verán más motivadas a salir de casa en el caso de una emergencia epidemiológica.
* El modelo calcula las probabilidades de transición de estado de los agentes de manera individual y general, teniendo la ventaja de ser valores dinámicos con lo que 
* pueden hacerse estimaciones más cercanas a la realidad.
* La base de la transmisión del virus es el contacto, contacto directo entre una persona infectada y una susceptible.
* El modelo puede simular tres escenarios de tiempo: corto, mediano y largo plazo donde se expone el comprotamiento de la enfermedad en la rutina de las 
* personas diariamente. Mediano plazo considera una semana con una escala de espacio mayor. Largo plazo simula el comportamiento de la
* ciudad y de sus servicios y actividad económica en un lapso de un mes.
* The system status according to the model are: 
* Susceptible (S), Exposed (E), Infectious not yet symptomatic (pre or Asymptomatic) (Ia), Infectious with symptoms (Is), Hospitalized (H), Recovered (R), Isolated (Q).
* 
* The model is based mostly in the following papers:
* [Tang et. al.] Estimation of the transmission risk of 2019-nCov and its implication for public healt interventions.
* [Alcaraz and De-Leon] Modeling control strategies for influenza A H1N1 epidemics: SIR models.
* [World Healt Organization] Q&A on coronaviruses (COVID-19) https://www.who.int/news-room/q-a-detail/q-a-coronaviruses.
* Tags: Epidemics, coronavirus, México.
***/

model coronavirus
import "Constants.gaml"

global{
	
	int timeElapsed <- 0 update: int(cycle*step);
	
	//General virus behavior related parameters and variables
	int nb_vertical_individualist 		<- 10;
	int nb_vertical_collectivist 			<- 10;
	int nb_horizontal_individualist 	<- 10;
	int nb_horizontal_collectivist 		<- 10;
	int nb_unique_profile					<- 0;
	int nb_people <- nb_vertical_individualist+nb_vertical_collectivist+nb_horizontal_individualist+nb_horizontal_collectivist+nb_unique_profile;
	bool update_beliefs 						<- false;
	bool mobility_restriction 				<- false;
	bool saveToCSV 							<- false;
	string scenario								<- "default";
	list<string> output;
	int init_nb_exposed 	parameter:"init_nb_exposed" category:"Model parameters" 	<- 10 min:0 max:100; //Number of agents initially exposed to the virus S.
	float beta 					parameter: "beta" category:"Model parameters" 						<- 0.01; //Probability of going from Susceptible to Exposed.
	float rho 						parameter: "rho" category:"Model parameters"						<- 0.86834 min:0.0 max:1.0; //Probability of having symptoms among infected individuals E->Is.
	float delta_s 				parameter: "delta_s" category:"Model parameters" 					<- 0.5 min:0.0 max:1.0; //Probability of going from symptomatic infected individuals to the quarantined infected class I->Q_Is.
	float delta_a 				parameter: "delta_a" category:"Model parameters" 				<- 0.3 min:0.0 max:1.0; //Probability of going from asymptomatic infected individuals to the quarantined infected class I->Q_Ia.
	float gamma 				parameter: "gamma" category:"Model parameters" 				<- 0.1 min:0.0 max:1.0; //Probability of being symptomatic and being then hospitalized. 
	
	//Indices y perfiles de morbilidad poblacional
	float lambda parameter: "lambda" category:"Model parameters" 								<- 0.8 min:0.0 max:1.0; //Probability of return to susceptible class S once Recovered.
	int init_beds parameter: "Beds in hospital" category:"Hospital" 									<- 100 min:0 max:2000;
	int init_icbeds parameter: "Int. care beds" category:"Hospital" 									<- 20 min:0 max:2000; 
	int aux_parameter;
	
	//Basic Reproductive Number (R0) calculation
	float R0 									<- 0.0;
	bool save_to_csv_R0 			<- false;
	bool patient_0_recovered 	<- false;
	bool stop_simulation 			<- false;

	
	//Visualization parameters
	//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious without symptoms(Ia), 4.Recovered(R), 5.Immune(I).
	//list<rgb> status_color <- [#yellow,#darkturquoise,#red,#magenta,#greenyellow,#gray, #skyblue,#green,#white];
	map<string,int> status_size 		<- ["S"::5,"E"::5,"Is"::5,"Ia"::5,"R"::5,"I"::5, "D"::5];
	map<string,rgb> status_color 	<- ["S"::#yellow,"E"::#gamaorange,"Is"::#red,"Ia"::#magenta,"R"::#greenyellow,"I"::#white, "D"::rgb (179, 0, 0,255), "Qs"::#red, "Qa"::#blueviolet,"H"::#skyblue ];

	
	//Output variables
	int nb_susceptible 							<- nb_people-init_nb_exposed update: length(people where(each.epidemic_status="S"));
	int nb_exposed 									<- init_nb_exposed update: length(people where(each.epidemic_status="E"));
	int nb_infectious_symptomatic 		<- 0 update: length(people where(each.epidemic_status="Is"));
	int nb_infectious_asymptomatic 		<- 0 update: length(people where(each.epidemic_status="Ia"));
	int nb_recovered 								<- 0 update: length(people where(each.epidemic_status="R"));
	int nb_immune 									<- 0 update: length(people where(each.epidemic_status="I"));
	int nb_D 												<- 0 update: length(people where(each.epidemic_status="D"));
	int nb_Qs 											<- 0 update: length(people where(each.Qs=true));
	int nb_Qa 											<- 0 update: length(people where(each.Qa=true));
	int nb_H 												<- 0 update: length(people where(each.H=true));
	
	float individualist_value	<- 0.0;
	float collectivist_value		<- 0.0;
	float unique_individualist_value <- 0.0;
	
	int nb_mask 					<- 0 update: length(people where(each.wear_mask=true));
	int nb_hand_wash 		<- 0 update: length(people where(each.hand_wash=true));
	int nb_social_distance 	<- 0 update: length(people where(each.keep_distance=true));
	
	//General model parameters
	geometry shape <- envelope(roads_shp);
	graph road_network;
	map<road, float> weight_map;
	init{
		starting_date <- date("2020-02-28 00:00:00") ;
		step <- 3#mn; 
		create road from:roads_shp;
		create block from:blocks_shp;
		create hospital{beds		<- 30;intensive_care_beds<-10;}
		weight_map 					<- road as_map(each::each.shape.perimeter);
		road_network 				<- as_edge_graph(road) with_weights weight_map;
		create people number:nb_vertical_individualist{cultural_orientation		<-"vertical_individualist";}
		create people number:nb_vertical_collectivist{cultural_orientation			<-"vertical_collectivist";}
		create people number:nb_horizontal_individualist{cultural_orientation	<-"horizontal_individualist";}
		create people number:nb_horizontal_collectivist{cultural_orientation		<-"horizontal_collectivist";}
		create people number:nb_unique_profile{cultural_orientation <- "unique_profile";}
		//create people number:init_nb_exposed{epidemic_status<-"E"; last_change <- cycle;}

		if scenario = "25-75-1"{
			loop i from:0 to:int(length(people)*0.75){
				ask people(i){
					epidemic_status <- "I";
				}
			}
		}
		else if scenario = "50-50-1"{
			loop i from:0 to:int(length(people)*0.5){
				ask people(i){
					epidemic_status <- "I";
				}
			}
		}
		else if scenario = "75-25-1"{
			loop i from:0 to:int(length(people)*0.25){
				ask people(i){
					epidemic_status <- "I";
				}
			}
		}
		
		/*int jump <- int(length(nb_people)/init_nb_exposed);
		loop i from:0 to:init_nb_exposed-1{
			ask people(i*jump){
				im_patient_0 			<- true;
				epidemic_status		<-"E"; 
				last_change 			<- cycle;
			}
		}*/
		loop times:init_nb_exposed{
			ask one_of(people){
				epidemic_status <- "E";
				last_change 			<- cycle;
			}
		}
	}
	
	reflex compute_R0{
		float sum <- 0.0;
		list<people> recovered_people <- people where(each.epidemic_status="R" or each.epidemic_status="D");
		ask recovered_people{
			sum <- sum + nb_caused_infections;
		}
		R0 <- empty(recovered_people)?R0:sum/length(recovered_people);
	}
	
	reflex save_results when:saveToCSV and every(24#hour){
		string current <- ""+cycle+","+current_date+","+int(timeElapsed/86400)+","+nb_susceptible+","+nb_exposed+","
		+nb_infectious_symptomatic+","+nb_infectious_asymptomatic+","+nb_recovered+","+nb_immune
		+","+nb_Qs+","+nb_Qa+","+nb_H+","+nb_D+","+nb_mask+","+nb_hand_wash+","+nb_social_distance+","+R0+nb_people
		+","+nb_vertical_individualist+","+nb_vertical_collectivist+","+nb_horizontal_individualist+","+nb_horizontal_collectivist;
		save current to: "output_epidemic/"+scenario+".csv" type:csv rewrite:false;
		/*write ""+nb_infectious_symptomatic+","+nb_infectious_asymptomatic+","+nb_D+","+(nb_infectious_symptomatic+nb_infectious_asymptomatic+nb_D) / nb_people;
		ask people(0){
			write "people("+name+") beliefs:"+beliefs[0]+","+beliefs[1]+","+beliefs[2];
		}	
		ask people(9){
			write "people("+name+") beliefs:"+beliefs[0]+","+beliefs[1]+","+beliefs[2];
		}	
		ask people(2){
			write "people("+name+") beliefs:"+beliefs[0]+","+beliefs[1]+","+beliefs[2];
		}	*/
	}
	reflex saveToCSV_R0 when:save_to_csv_R0 and patient_0_recovered{
		int nb_cases <- 0;
		ask people where(each.im_patient_0){
			nb_cases <- nb_caused_infections;
		}
		string current <- ""+nb_cases;
		save current to: "output_epidemic/results_epidemic_R0_"+scenario+".csv" type:csv rewrite:false;
		write scenario+":"+"ready";
		self.stop_simulation <- true;
		save_to_csv_R0 <- false;
	}
}


species people skills:[moving] parallel:500{
	
	//Mobility
	point target;
	float speed 					<- 1.4;
	string mobility_profile 	<- one_of(["bus","car","walk","bicycle"]);
	
	//Social-economical variables
	string income_level <- one_of(["low","medium","high"]);
	bool essential_worker;
	
	//Agenda related variables
	point home;
	map<date,point> agenda_day;
	
	//Medical related variables
	int age;
	bool morbilities;
	bool intensive_care;
	
	//Culture related variables
	string cultural_orientation <- one_of(["vertical_individualist","horizontal_individualist","vertical_collectivist","horizontal_collectivist"]);
	
	//Risk acceptability
	float acceptable_risk;
	
	//Epidemic related variables
	//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious without symptoms(Ia), 4.Recovered(R), 5.Immune(I).
	string epidemic_status;
	
	//Response to symptoms
	bool Qs <- false; //Goes to quarantine at home once detected symptoms
	bool H <- false; //Goes to hospital after show symptoms
	bool Qa <- false; //Self-isolate at home even does not know about contageousness.
	
	//Interventions, policies, restrictions, etc. 
	/*
	 * Agents' beliefs:
	 * 0. wear_mask
	 * 1. hand_wash
	 * 2. keep_distance
	 * 3. go_out
	 * 4. go_out_essentials
	 * */
	list<float> beliefs <- [0.0,0.0,0.0,0.0,0.0];
	bool wear_mask;
	bool hand_wash;
	bool keep_distance;
	
	//Variables to calculate R0
	bool im_patient_0 				<- false;
	int nb_caused_infections 		<- 0;
	
	
	int last_change 					<- 0; //Time of last status change.
	float incubation_period 	<- 0.0; //The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days. [WHO: The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days.]
	int t1_ <- rnd(t1-3,t1+3);
	int t2_ <- rnd(t2-10,t2+10);
	int t3_ <- rnd(t3-7,t3+7);
	int t4_ <- rnd(t4-2,t4+2);
	
	init{
		home <- any_location_in(one_of(block));
		location <- home;
		target <- home;
		epidemic_status <- "S";
		//pedestrian_model <- "SFM";
		//obstacle_species <- [block,people];
		intensive_care <- false;
		wear_mask <- false;
		hand_wash <- false;
	}
	action update_behavior {
		//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious without symptoms(Ia), 4.Recovered(R), 5.Immune(I).
		if epidemic_status = "Is"{
			if rnd(100)/100 < delta_s{//Probability of being symptomatic
				Qs <- true;
				if rnd(100)/100 < gamma{ //Probability of needing hospitalization
					hospital hosp <- hospital closest_to self;
					ask hosp{
						if hospitalize(myself){
							myself.H <- true;
							myself.Qs <- false;	
						}
					}
				}
			}
		}
		else if epidemic_status = "Ia"{
			if rnd(100)/100 < delta_a{
				Qa <- true;
			}
		}
		else{
			H <- false;
			Qs <- false;
			Qa <- false;
		}
		
	}
	
	reflex create_new_agenda when:empty(agenda_day){
		int hours_for_activities;
		int hour_for_go_out;
		int nb_activities;
		int hours_per_activity;
		int sum;
		/*In this model we include different types of activities
		 * Work:
		 * 1. Presencial
		 * Recreative:
		 * 1. Visitar amigos o familiares
		 * 2. Ejercicio
		 * Compras:
		 * 1. Comprar suministros
		 * */
		if mobility_restriction{
			
			if essential_worker{//Essential worker, it is needed to go out and develop activities
				hours_for_activities 	<- rnd(2,8);
				hour_for_go_out 		<- rnd(7,24-hours_for_activities);
				nb_activities 				<- rnd(1,2);	
			}
			else{//Not essenial worker, just go out for needed activities like shopping supplies
				hours_for_activities 	<- rnd(1,3);
				hour_for_go_out 		<- rnd(9,20-hours_for_activities);
				nb_activities 				<- 1;
			}	
		}
		else{
			hours_for_activities <- rnd(12,17);
			hour_for_go_out <- rnd(0,24-hours_for_activities);
			nb_activities <- rnd(2,8);
		}
		
		hours_per_activity <- int(hours_for_activities/nb_activities);
		sum <- 0;
		loop times:nb_activities{
			agenda_day <+ (date(current_date.year,current_date.month,hour_for_go_out+sum>24?current_date.day+1:current_date.day,hour_for_go_out+sum>=24?mod(hour_for_go_out+sum,24):hour_for_go_out+sum, rnd(0,59),0)::any_location_in(one_of(block)));
			sum<- sum + hours_per_activity;
		}	
		agenda_day <+ (date(current_date.year,current_date.month,hour_for_go_out+sum>24?current_date.day+1:current_date.day,hour_for_go_out+sum>=24?mod(hour_for_go_out+sum,24):hour_for_go_out+sum, rnd(0,59),0)::home);
	}
	
	reflex update_activity when:not empty(agenda_day) and (after(agenda_day.keys[0])){
		target <- agenda_day.values[0];
		agenda_day>>first(agenda_day);
		if Qa or Qs{
			//If the agent wants to go to quarantine, either it is symtomatic or asymptomatic
			target <- home;
		}
		if H{
			target <- any_location_in(hospital closest_to self);
		}
		//Determine wether the agent implements health care recommendations.
		if update_beliefs{
			float estimated_risk <- calculate_risk(); //Add here bayesian function?
			do update_beliefs;
			wear_mask <- beliefs[0]>rnd(100)/100?true:false;
			hand_wash <- beliefs[1]>rnd(100)/100?true:false;
			keep_distance <- beliefs[2]>rnd(100)/100?true:false;
		}
	}	
	
	float calculate_risk{
		float result <- 0.0;
		if(age>65) {result<- result+0.35;}
		if(morbilities){result<-result+0.35;}		
		return result;
	}
	
	float likelihood{
		/*This may be a probability taken from the cultural orientation of the agent.
		** 
		**
		
		float result <- 0.5;
		if cultural_orientation = "vertical_individualist"{result <- result + 0.0;}
		if cultural_orientation = "horizontal_individualist"{result <- result + 0.17;}
		if cultural_orientation = "vertical_collectivist"{result <- result + 0.33;}
		if cultural_orientation = "horizontal_collectivist"{result <- result + 0.5;}
		return result;*/
		float result <- 0.0;
		if cultural_orientation = "vertical_individualist"{result 			<- 1-unique_individualist_value;}
		if cultural_orientation = "horizontal_individualist"{result 		<- unique_individualist_value;}
		if cultural_orientation = "vertical_collectivist"{result 				<- 1-unique_individualist_value;}
		if cultural_orientation = "horizontal_collectivist"{result 		<- unique_individualist_value;}
		if cultural_orientation = "unique_profile"{result 						<- unique_individualist_value;}
		return result;
	}
	
	float incoming_information{
		float result <- 0.0;
		result <- (nb_infectious_symptomatic+nb_infectious_asymptomatic+nb_D) / nb_people;
		//result <- aux_parameter / nb_people;
		return result;
	}
	
	action update_beliefs{
		loop i from: 0 to:2{
			if beliefs[i] = 0.0 {beliefs[i]<-0.001;}
			float numerator1 			<- likelihood()*beliefs[i];
			float denominator1 		<- likelihood()*beliefs[i] + (1-likelihood())*(1-beliefs[i]);
			float numerator2 			<- (1-likelihood())*beliefs[i];
			float denominator2 		<- (1-likelihood())*beliefs[i] + likelihood()*(1-beliefs[i]);
			try{
				float result 		<- (numerator1*incoming_information()/denominator1) + (numerator2*(1-incoming_information())/denominator2);
				beliefs[i] 		<- result;
				//beliefs[i] 		<- beliefs[i]=1.0?0.999:beliefs[i];
			}catch{
				write "agent("+name+") division1: "+numerator1*incoming_information()+"/"+denominator1+"\tdivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
				+"\n" +"likelihood: "+likelihood()+ ", beliefs["+i+"]:"+beliefs[i];
			}
			/*write "agent("+name+") division1: "+numerator1*incoming_information()+"/"+denominator1+"\tdivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
				+"\n" +"likelihood: "+likelihood()+ ", beliefs["+i+"]:"+beliefs[i];*/
		}	
		//write "beliefs: "+beliefs[0]+","+beliefs[1]+","+beliefs[2];
	}
		
	reflex mobility when:target!=location and epidemic_status != "D"{
		
		do goto target:target on:road_network speed:speed;
		/*
		 * EXPERIMENTAL USING PEDESTRIAN OR ESCAPE_PEDESTRIAN SKILL
		 * 
		 * 	if final_target = nil{
				do compute_virtual_path pedestrian_graph:road_network final_target: target;
			}
			do walk;
		* */
	}
	
	reflex epidemic{
		//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious without symptoms(Ia), 4.Recovered(R), 5.Immune(I).
		
		//Exposed (E)
		if epidemic_status = "E"{
			//do infect_encounter;
			if ((cycle-last_change)*step/86400)>t1_{//86400 seconds in a day. t1:incubation period
				epidemic_status 	<- rnd(100)/100 < rho?"Is":"Ia";//Likelihoood of rho of becoming Infectious with symptoms and (1-rho) of being asymptomatic.
				last_change 			<- cycle;
				do update_behavior;
			}
		}
		//Infectious symptomatic (Is)
		if epidemic_status = "Is" {
			do infect_encounter;
			if ((cycle-last_change)*step/86400)>t2_{
				epidemic_status 	<- "R";
				last_change 			<- cycle;
				if im_patient_0{
					patient_0_recovered <- true;
				}
				do update_behavior;
			}
		}
		//Infectious asymptomatic (Ia)
		if epidemic_status = "Ia"{
			do infect_encounter;
			if ((cycle-last_change)*step/86400)>t3_{
				epidemic_status 	<- "R";
				last_change 			<- cycle;
				if im_patient_0{
					patient_0_recovered <- true;
				}
				do update_behavior;
			}
		}
		//Recovered
		if epidemic_status = "R"{
			if ((cycle-last_change)*step/86400)>t4_{
				epidemic_status 	<- rnd(100)/100<lambda?"D":"I";
				last_change 			<- cycle;
				do update_behavior;
			}
		}
		//Immune
		if epidemic_status = "I"{
			do update_behavior;
		}
		//Dead
		if epidemic_status = "D"{
			
		}
	}
	action infect_encounter{
		if !Qs and !Qa and !H{
			
			list<people> near_people <- people at_distance(2);//To do: as a parameter
			if near_people != nil{
				loop contact over:near_people{
					if not wear_mask{
						ask contact{
							if rnd(100)/100 < beta and epidemic_status = "S" {
								epidemic_status <- "E";
								last_change <- cycle;
								myself.nb_caused_infections <- myself.nb_caused_infections + 1;
							}
						}	
					}
				}
			}	
		}
	}
	aspect default{draw circle(status_size[epidemic_status]) color:status_color[epidemic_status];}
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
	bool hospitalize(people person){
		float prob_i_care <- 0.0;
		if person.morbilities{
			prob_i_care <- prob_i_care + 0.25;
		}
		if person.age > 65{
			prob_i_care <- prob_i_care + 0.25;
		}
		if rnd(1) < prob_i_care{
			if intensive_care_beds = 0 {return false;}
			person.intensive_care <- true;
			intensive_care_beds <- intensive_care_beds - 1;
		}
		else{
			if beds = 0 {return false;}
			person.intensive_care <- false;
			beds <- beds-1;
		}
		return true;
	}
}

species road{
	aspect default{draw shape color:rgb(50,50,50,0.5) width:15.0;}
}

species block{
	aspect default{draw shape color:rgb(50,50,50,0.5);}
}
