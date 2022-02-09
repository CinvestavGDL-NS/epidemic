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
	bool allow_beliefs 							<- false;
	bool mobility_restriction 				<- false;
	bool saveToCSV 								<- false;
	bool showFamily			parameter:"show families" 				category:"Visualization"			<- false;
	float fixed_info				parameter:"incoming information" category:"Visualization" 			<- 0.0 min:0.0 max:1.0;
	float fixed_profile			parameter:"profile"						category:"Visualization" 				<- 0.0 min:0.0 max:1.0;
	string scenario								<- "default";
	int init_nb_exposed 		parameter:"init_nb_exposed" 		category:"Model parameters" 		<- 0 min:0 max:100; //Number of agents initially exposed to the virus S.
	float infection_distance 	parameter:"infection distance" 	category:"Model parameters" 		<- 2.0#m min:0.0 max:50.0; 	//Number of agents initially exposed to the virus S.
	float beta 						parameter: "beta" 						category:"Model parameters" 		<- 0.0001; 					//Probability of going from Susceptible to Exposed after a contact.
	float rho 							parameter: "rho" 							category:"Model parameters"		<- 0.86834 min:0.0 max:1.0; //Probability of having symptoms among infected individuals E->Is.
	float delta_s 					parameter: "delta_s" 					category:"Model parameters" 		<- 0.5 min:0.0 max:1.0; //Probability of going from symptomatic infected individuals to the quarantined infected class I->Q_Is.
	float delta_a 					parameter: "delta_a" 					category:"Model parameters" 		<- 0.5 min:0.0 max:1.0; //Probability of going from asymptomatic infected individuals to the quarantined infected class I->Q_Ia.
	float gamma 					parameter: "gamma" 					category:"Model parameters" 		<- 0.1 min:0.0 max:1.0; //Probability of being symptomatic and being then hospitalized. 
	
	//Indices y perfiles de morbilidad poblacional
	float lambda parameter: "lambda" category:"Model parameters" 								<- 0.95 min:0.0 max:1.0; //Probability of survive to the disease.
	//Probability of being infected when working out of the municipality
	bool daily_flag;
	float infected_outside <- 0.0001;
	float essential_workers_ratio <- 0.25;
	
	//Basic Reproductive Number (R0) calculation
	float R0 									<- 0.0;
	bool save_to_csv_R0 				<- false;
	bool patient_0_recovered 		<- false;
	bool stop_simulation 				<- false;
	
	//Visualization parameters
	map<string,int> status_size 		<- ["S"::5,"E"::5,"Is"::5,"Ia"::5,"R"::5,"I"::5, "D"::5];
	map<string,rgb> status_color 	<- ["S"::#yellow,"E"::#gamaorange,"Is"::#red,"Ia"::#magenta,"R"::#greenyellow,"I"::#white, "D"::rgb (179, 0, 0,255), "Qs"::#red, "Qa"::#blueviolet,"H"::#skyblue ];
	
	//Output variables
	int nb_susceptible 								<- 0 update: length(people where(each.epidemic_status="S"));
	int nb_exposed 									<- init_nb_exposed update: length(people where(each.epidemic_status="E"));
	int nb_infectious_symptomatic 			<- 0 update: length(people where(each.epidemic_status="Is"));
	int nb_infectious_asymptomatic 		<- 0 update: length(people where(each.epidemic_status="Ia"));
	int nb_recovered 								<- 0 update: length(people where(each.epidemic_status="R"));
	int nb_immune 									<- 0 update: length(people where(each.epidemic_status="I"));
	int nb_D 												<- 0 update: length(people where(each.epidemic_status="D"));
	int nb_Qs 											<- 0 update: length(people where(each.Qs=true));
	int nb_Qa 											<- 0 update: length(people where(each.Qa=true));
	int nb_H 												<- 0 update: length(people where(each.H=true));
	int infected_today								<- 0;
	int hospitalized_today						<- 0;
	int deaths_today									<-0;
	int tot_infected									<- 1;
	int tot_hosp											<- 0;
	int tot_deaths										<- 0;
	
	float individualist_value <- 0.0;
	
	list<float> people_beliefs <- [0.0,0.0,0.0,0.0,0.0];
	int nb_mask 					<- 0 update: length(people where(each.wear_mask=true));
	int nb_hand_wash 			<- 0 update: length(people where(each.hand_wash=true));
	int nb_social_distance 	<- 0 update: length(people where(each.keep_distance=true));
	
	//General model parameters
	geometry shape <- envelope(limits_shp);
	
	//Variables related to the calculation of peoples' beliefs
	float hosp_occupancy <- 0.0;
	float cases_ratio <- 0.0;
	float semaphore <- 0.3; 
	float mobility_essential <- 1.0;
	float mobility_noessential <- 1.0;
	float incoming_information <- 0.0;
	
	
	people the_person;
	people another_person;

	init{
		starting_date <- date("2020-05-23 00:00:00") ;//starting_date <- date("2020-02-28 00:00:00") ;
		step <- 1#hour; 
		create limit from:limits_shp;
		create block from:blocks_shp;
		create workplace from:workplaces_shp with:[
			place_name :: string(read("name")),
			id::string(read("id"))
		];
		create park from:parks_shp;
		create school from:schools_shp with:[
			id::string(read("codigo_act")),
			place_name::string(read("nom_estab"))
		];
		create people from:people_shp with:[
			age::int(read("age")),
			my_workplace_id::string(read("my_workpla")),
			family_id::int(read("family_id"))
		];
		ask people{
			int the_id <- self.family_id;
			my_family <- people at_distance(50) where(each.family_id = the_id);
			do initialize;
		}
		the_person <- one_of(people where(each.age = 30));
		another_person <- one_of(people);
		create hospital{
			beds		<- init_beds;
			intensive_care_beds<-init_icbeds;
		}
		
		blocks_shp 			<- [];
		parks_shp 				<- [];
		roads_shp 				<- [];
		limits_shp 				<- [];
		people_shp			<- [];
		schools_shp			<- [];
		workplaces_shp 	<- [];
			
		loop times:init_nb_exposed{
			if not empty(people){
				ask the_person{
					epidemic_status <- "Ia";
					last_change 			<- cycle;
				}
			}
		}
	}
	
	reflex compute_R0 when:every(24#hour){
		float sum <- 0.0;
		list<people> recovered_people <- people where(each.epidemic_status="R" or each.epidemic_status="D");
		ask recovered_people{
			sum <- sum + nb_caused_infections;
		}
		R0 <- empty(recovered_people)?R0:sum/length(recovered_people);
	}
	
	reflex update_semaphore when:every(1#day){
		
		//Hospital occupancy;
		int sum_beds			<- 0;
		int sum_beds_left 	<- 0;
		int sum_icb 				<- 0;
		int sum_icb_left 		<- 0;

		sum_beds_left <- sum(hospital collect(each.beds));
		sum_icb_left <- sum(hospital collect(each.intensive_care_beds));
		float beds_occupancy <- (init_beds - sum_beds_left)/init_beds;
		float icb_occupancy <- (init_icbeds - sum_icb_left)/init_icbeds;
		hosp_occupancy <- (0.4*beds_occupancy) + (0.6*icb_occupancy); //Semaphore calculated using hospital occupation 
		
		//Number of cases
		cases_ratio <- (nb_infectious_symptomatic + nb_infectious_asymptomatic)/length(people);
		
		float semaphore_raw <- max(hosp_occupancy,cases_ratio);
		if semaphore_raw <= 0.3{ semaphore <- 0.3; }
		else if semaphore_raw <= 0.5{ semaphore <- 0.5; }
		else if semaphore_raw <= 0.7{ semaphore <- 0.7; }
		else{ semaphore <- 1.0; }
	}
	
	reflex update_incoming_information when:every(24#hour){
		float cases <- (nb_exposed+nb_infectious_symptomatic+nb_infectious_asymptomatic+nb_D) / length(people);
		float icbeds_left <- 1-(hospital[0].intensive_care_beds/init_icbeds);
		float beds_left <- 1-(hospital[0].beds/init_beds);
		float hospital_occupancy <- mean([beds_left,icbeds_left]);
		write "cases: "+cases+", hospital_occupancy: "+hospital_occupancy;
		incoming_information <- mean([cases,hospital_occupancy]);
	}
	
	float likelihood{
		//Versión mapeada al rango 0.5 a 1.0
		float result <- 1-(0.5*individualist_value);
		return result;
	}
	
	reflex update_beliefs when:every(24#hour){
		loop i from: 0 to:2{
			people_beliefs[i] <- max(0.01,min(0.99,people_beliefs[i]));
			float numerator1 			<- likelihood()*people_beliefs[i];
			float denominator1 		<- likelihood()*people_beliefs[i] + (1-likelihood())*(1-people_beliefs[i]);
			float numerator2 			<- (1-likelihood())*people_beliefs[i];
			float denominator2 		<- (1-likelihood())*people_beliefs[i] + likelihood()*(1-people_beliefs[i]);
			try{
				float result 		<- (numerator1*incoming_information/denominator1) + (numerator2*(1-incoming_information/denominator2));
				people_beliefs[i] 		<- result;
			}catch{
				/*write "agent("+name+") division1: "+numerator1*incoming_information()+"/"+denominator1+"\tdivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
				+"\n" +"likelihood: "+likelihood()+ ", beliefs["+i+"]:"+beliefs[i];*/	
			}
		}	
	}
	
	reflex update_mobility when:every(24#hour){
		if semaphore <= 0.3{
			mobility_essential 		<- 1.0;
			mobility_noessential <- 1.0;
		}
		if semaphore <= 0.5 {
			mobility_essential 		<- 1.0;
			mobility_noessential <- 0.75;
		}
		else if semaphore <= 0.7{
			mobility_essential <- 0.75;
			mobility_noessential <- 0.5;
		}
		else {
			mobility_essential <- 0.5;
		}
	}
	
	reflex save_results when:saveToCSV and every(24#hour){
		int day_of_simulation <- int(timeElapsed/86400);
		save data:[cycle,current_date,day_of_simulation,nb_susceptible,nb_exposed
			,nb_infectious_symptomatic,nb_infectious_asymptomatic,nb_recovered,
			nb_immune,nb_Qs,nb_Qa,nb_H,nb_D,nb_mask,nb_hand_wash,nb_social_distance,R0,infected_today,tot_infected,semaphore,hospitalized_today,tot_hosp,deaths_today, tot_deaths
		] to:"output_epidemic/"+scenario+".csv" type:csv rewrite:false header:true;
		infected_today <- 0;
		hospitalized_today <- 0;
		deaths_today 				<- 0;
	}
	
	reflex saveToCSV_R0 when:save_to_csv_R0 and patient_0_recovered{
		int nb_cases <- 0;
		ask people where(each.im_patient_0){
			nb_cases <- nb_caused_infections;
		}
		string current <- ""+nb_cases;
		save current to: "output_epidemic/results_epidemic_R0_"+scenario+".csv" type:csv rewrite:false;
		self.stop_simulation <- true;
		save_to_csv_R0 <- false;
	}
	

	
	
}

species limit{
	aspect default{
		draw shape color:rgb (77, 122, 168,255) empty:true;
	}
}

species people skills:[moving] parallel:true{
	
	int age;
	string my_workplace_id;
	workplace my_workplace <- nil;
	map<string,path> my_paths;
	
	//Family
	int family_id;
	list<people> my_family;
	
	//Mobility
	point target;
	float speed 						<- 1.4;
	string mobility_profile 	<- one_of(["bus","car","walk","bicycle"]);
	
	//Social-economical variables
	bool essential_worker;
	string social_profile;
	
	//Agenda related variables
	point home;
	bool work_out_of_city <- false;  //This variable indicates if the agent works in another municipality
	bool working_out_of_city <- false; //The agent is currently working in another municipality
	map<point,string> my_activities;
	list<point> leisure_activities;
	map<date,point> agenda_day;
	
	//Medical related variables
	bool morbilities;
	bool intensive_care;
	
	//Risk acceptability
	float acceptable_risk;
	
	//Epidemic related variables
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
	bool wear_mask;
	bool hand_wash;
	bool keep_distance;
	
	//Variables to calculate R0
	bool im_patient_0 					<- false;
	int nb_caused_infections 		<- 0;
	
	
	int last_change 					<- 0; //Time of last status change.
	float incubation_period 		<- 0.0; //The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days. [WHO: The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days.]
	float t1_ <- gauss(t1,3);//rnd(t1-3,t1+3);
	float t2_ <- gauss(t2,10);
	float t3_ <- gauss(t3,7);
	float t4_ <- gauss(t4,30);
	
	action initialize{
		home 			<- location;
		location 	<- home;
		target 		<- home;
		epidemic_status <- "S";
		intensive_care <- false;
		wear_mask 		<- false;
		hand_wash		<- false;
		if age < 4{
			social_profile <- "stay_home";
		}
		else if age < 6{
			social_profile <- "student";
			/*create activity{
				essential <- false;
				type <- "school";
				location <- one_of(school where(each.id="611112")).location;
			}*/
			add (one_of(school where(each.id = "611112")).location::"school") to:my_activities;
			//add activity[0] to:my_activities;
		}
		else if age < 12{
			social_profile <- "student";
			create activity{
				essential <- false;
				type <- "school";
				location <- any_location_in(one_of(school where(each.id="611122")));
			}
			add (any_location_in(one_of(school where(each.id="611122")))::"school") to:my_activities;
			/*create activity{
				essential <- false;
				type <- "leisure";
				location <- any_location_in((park closest_to self));
			}*/
			add any_location_in((park closest_to self)) to:leisure_activities;
		}
		else if age < 15{
			social_profile <- "student";
			/*create activity{
				essential <- false;
				type <- "school";
				location <- any_location_in(one_of(school where(each.id="611132")));
			}
			create activity number:2{
				essential <- false;
				type <- "leisure";
				location <- any_location_in((park closest_to self));
			}*/
			add (any_location_in(one_of(school where(each.id="611132")))::"school") to:my_activities;
			add any_location_in((park closest_to self)) to:leisure_activities;
			add any_location_in((park closest_to self)) to:leisure_activities;
		}
		else if age < 18{
			social_profile <- "student";
			/*create activity{
				essential <- false;
				type <- "school";
				location <- any_location_in(one_of(school where(each.id="611162")));
			}
			create activity number:3{
				essential <- false;
				type <- "leisure";
				location <- any_location_in((park closest_to self));
			}*/
			add (any_location_in(one_of(school where(each.id="611162")))::"school") to:my_activities;
			add any_location_in((park closest_to self)) to:leisure_activities;
			add any_location_in(one_of(park)) to:leisure_activities;
			add any_location_in(one_of(park)) to:leisure_activities;
		}
		else if age <65{
			social_profile <- "worker";
			my_workplace <- one_of(workplace where(each.id = my_workplace_id));
			if my_workplace = nil{
				my_workplace <- one_of(workplace where(each.id = "0"));
				work_out_of_city <- true;
			}
			/*create activity{
				essential <- true;
				type <- "work";
				location <- my_workplace.location;
			}
			create activity{
				essential <- false;
				type <- "leisure";
				location <- any_location_in((park closest_to self));
			}*/
			add (my_workplace.location::"work") to:my_activities;
			add any_location_in((park closest_to self)) to:leisure_activities;
			essential_worker <- flip(essential_workers_ratio);		
		}
		else {
			social_profile <- "stay_home";
		}
	}
	
	
	reflex create_new_agenda when:empty(agenda_day)  and social_profile != "stay_home"{
		int hours_for_activities;
		int hour_for_go_out;
		int nb_activities;
		int hours_per_activity;
		int sum;
		list<point> activities_to_do;
		if mobility_restriction{ //Is the semaphore working
			
			if essential_worker{//Essential worker, it is needed to go out and develop activities
				hours_for_activities 	<- rnd(2,8);
				hour_for_go_out 			<- rnd(7,20-hours_for_activities);
				if flip(mobility_essential){
					add my_workplace.location to:activities_to_do;
				}
			}
			else{//Not essenial worker, just go out for needed activities like shopping supplies
				hours_for_activities 	<- rnd(1,3);
				hour_for_go_out 			<- rnd(10,20-hours_for_activities);
			}
			if not empty(leisure_activities){
				loop i from:0 to: length(leisure_activities)-1{
					if flip(mobility_noessential){
						add leisure_activities[i] to:activities_to_do;
					}
				}
			}
			
			
			/*ask activity where(each.type = "leisure"){
				if flip(mobility_noessential){
					add self to:activities_to_do;
				}
			}*/
		}
		else{
			hours_for_activities <- rnd(6,10);
			hour_for_go_out <- rnd(5,20-hours_for_activities);
			if my_workplace != nil{
				add my_workplace.location to:activities_to_do;
			}
			if not empty(leisure_activities){
				loop i from:0 to:length(leisure_activities)-1{
					add leisure_activities[0] to:activities_to_do;
				}
			}
			
			/*ask activity{
				add self to:activities_to_do;
			}*/
		}
		//New version of activities
		date activity_date <- date(current_date.year,current_date.month,current_date.day,hour_for_go_out,0,0);
		nb_activities <- length(activities_to_do);
		hours_per_activity <- nb_activities>0?int(hours_for_activities/nb_activities):0;
		sum <- 0;
		if nb_activities>0{
			loop i from:0 to:length(activities_to_do)-1{
				activity_date <- activity_date + sum#hours;
				agenda_day <+ (activity_date::activities_to_do[i]);    
				sum<- sum + hours_per_activity;
			}
		}
		
		/*ask activities_to_do{
			activity_date <- activity_date + sum#hours;
			agenda_day <+ (activity_date::self.location);    
			sum<- sum + hours_per_activity;
		}*/			
		activity_date <- activity_date + sum#hours;
		agenda_day <+ (activity_date::home);		
	}
	
	reflex update_activity when:not empty(agenda_day) and (after(agenda_day.keys[0])) and social_profile != "stay_home"{
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
		if allow_beliefs{
			wear_mask 		<- flip(people_beliefs[0])?true:false;
			hand_wash 		<- flip(people_beliefs[1])?true:false;
			keep_distance 	<- flip(people_beliefs[2])?true:false;
		}
	}	
	
	
	/*
	float likelihood{
		//Versión mapeada al rango 0.5 a 1.0
		float result <- 1-(0.5*individualist_value);
		return result;
	}
	
	reflex update_beliefs when:every(24#hour){
		loop i from: 0 to:2{
			beliefs[i] <- max(0.01,min(0.99,beliefs[i]));
			float numerator1 			<- likelihood()*beliefs[i];
			float denominator1 		<- likelihood()*beliefs[i] + (1-likelihood())*(1-beliefs[i]);
			float numerator2 			<- (1-likelihood())*beliefs[i];
			float denominator2 		<- (1-likelihood())*beliefs[i] + likelihood()*(1-beliefs[i]);
			try{
				float result 		<- (numerator1*incoming_information/denominator1) + (numerator2*(1-incoming_information/denominator2));
				beliefs[i] 		<- result;
			}catch{
			}
		}	
	}
	*/
	reflex mobility when:target!=location and epidemic_status != "D" and social_profile != "stay_home" {
		location <- target;
		if work_out_of_city and location = my_workplace.location{
			working_out_of_city <- true;
		}
		else{
			working_out_of_city <- false;
		}
	}
	
	action update_behavior {
		if epidemic_status = "Is" and flip(delta_s){//Probability of being symptomatic
			Qs <- true;
			if flip(gamma){ //Probability of needing hospitalization
				hospital hosp <- hospital closest_to self;
				ask hosp{
					if hospitalize(myself){
						myself.H <- true;
						myself.Qs <- false;	
						hospitalized_today <- hospitalized_today + 1;
						tot_hosp <- tot_hosp + 1;
					}
				}
			}
		}
		else if epidemic_status = "Ia" and flip(delta_a){
			Qa <- true;
		}
		else{
			Qs <- false;
			Qa <- false;
		}
	}
	
	reflex epidemic {
		//Exposed (E)
		if epidemic_status = "E"{
			//do infect_encounter;
			if ((cycle-last_change)*step/86400)>t1_{//86400 seconds in a day. t1:incubation period
				epidemic_status 	<- flip(rho)?"Is":"Ia";//Likelihoood of rho of becoming Infectious with symptoms and (1-rho) of being asymptomatic.
				last_change 			<- cycle;
				do update_behavior;
			}
		}
		//Infectious symptomatic (Is)
		if epidemic_status = "Is" {
			if not working_out_of_city{do infect_encounter;}
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
			if not working_out_of_city{do infect_encounter;}
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
			if H{
				write name+": saliendo del hospital";
				ask hospital{
					do dehospitalize(myself);
				}
				H <- false;
			}
			if flip(lambda){
				epidemic_status <- "I";
			}
			else{
				epidemic_status <- "D";
				deaths_today <- deaths_today + 1;
				tot_deaths <- tot_deaths + 1;
			}
			//epidemic_status 	<- flip(lambda)?"I":"D";
			last_change 			<- cycle;
			do update_behavior;
		}
		//Immune
		if epidemic_status = "I"{
		}
		//Dead
		if epidemic_status = "D"{
			
		}
	}
	
	action infect_encounter{
		if !Qs and !Qa and !H{
			if location = home{
				ask my_family where(each.location = each.home){
					if flip(beta) and self.epidemic_status = "S" {
						self.epidemic_status <- "E";
						self.last_change <- cycle;
						myself.nb_caused_infections <- myself.nb_caused_infections + 1;
						tot_infected <- tot_infected + 1;
						infected_today <- infected_today + 1;
					}
				}	
			}
			list<people> near_people <- people at_distance(infection_distance);
			ask near_people{
				if not myself.wear_mask and flip(beta) and self.epidemic_status = "S"{
					self.epidemic_status <- "E";
					last_change <- cycle;
					tot_infected <- tot_infected + 1;
					infected_today <- infected_today + 1;
					myself.nb_caused_infections <- myself.nb_caused_infections + 1;
				}
			}	
		}
	}
	
	reflex update_daily_flags when:every(1#day) and social_profile != "stay_home"{
		daily_flag <- true; 
	}
	reflex infect_out_of_city when:working_out_of_city and daily_flag and social_profile != "stay_home"{
		if flip(infected_outside) and epidemic_status = "S"{
			epidemic_status <- "E";
			last_change <- cycle;
			tot_infected <- tot_infected + 1;
			infected_today <- infected_today + 1;
			daily_flag <- false;
		}
	}
	
	aspect default{
		if social_profile = "worker"{
			rgb current_color <- location=home?#red:#green;
			draw circle(status_size[epidemic_status]) color:current_color;//status_color[epidemic_status];
		}
		
		if showFamily{
			ask my_family{
				draw line(myself.location,self.location) color:#green;
			}
		}
	}
	
	species activity{
		string type;
		bool essential;
	}
	
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
	bool dehospitalize(people person){
		if person.intensive_care = true{
			intensive_care_beds <- intensive_care_beds + 1;
			write "Dando de alta a "+person.name+ " de icu";
		}
		else{
			write "Dando de alta a "+person.name + " de normal";
			beds <- beds + 1;
		}
		return true;
	}
}

species road{
	aspect default{draw shape color:rgb(50,50,50,0.7) width:1.5;}
}

species block{
	int id;
	aspect default{
		draw shape color:rgb(50,50,50,0.5);
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

species park{
	aspect default{
		draw shape color:#gamaorange;
	}
}

species school{
	string id;
	string place_name;
	aspect default{
		draw square(30) color:rgb (204, 66, 107,255);
	}
}
