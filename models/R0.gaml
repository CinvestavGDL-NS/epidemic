/**
* Name: herdimmunity
* Based on the internal empty template. 
* Author: Gamaliel
* Tags: 
*/


model herdimmunity
global{
	map<string,rgb> agent_color 	<- ["susceptible"::#yellow,"immune"::#blue,"infected"::#red];
	float infection_distance 				<- 2.0;
	float infectious_time						<- 15 #day;
	float R0											<- 0.0;
	geometry shape 							<- square(1000);
	
	string scenario;
	bool save_to_csv 			<- false;
	bool save_to_csv_R0 	<- false;
	
	int nb_susceptible;
	int nb_immune;
	int nb_infected;
	
	list<people> immune_people 		<- [] update:people where(each.status="immune");
	list<people> infected_people 		<- [] update:people where(each.status="infected");
	list<people> susceptible_people 	<- [] update:people where(each.status="susceptible");
	
	//Variables to calculate R0
	bool patient_0_recovered 	<- false;
	bool stop_simulation 			<- false;
	
	init{
		step <- 1#hour;
		if(scenario="250-750-1"){
			nb_susceptible 	<- 250;
			nb_immune 		<- 750;
			nb_infected 			<- 1;
		}
		else if(scenario="500-500-1"){
			nb_susceptible 	<- 500;
			nb_immune 		<- 500;
			nb_infected 			<- 1;
		}
		else if(scenario="750-250-1"){
			nb_susceptible 	<- 750;
			nb_immune 		<- 250;
			nb_infected 			<- 1;			
		}
		create people number: nb_infected{
			status 					<- "infected";
			im_patient_0 		<- true;
		}
		create people number:nb_susceptible{
			status <- "susceptible";
		}
		create people number:nb_immune{
			status <- "immune";
		}
	}
	/*reflex update_R0{
		list<people> recovered_people <- immune_people where(each.recovered = true and each.nb_caused_infections>0);
		float sum <- 0.0;
		ask recovered_people{
			sum <- sum + nb_caused_infections;
		}
		
		R0 <- length(recovered_people)>0?sum/length(recovered_people):0.0;
	}*/
	reflex saveToCSV when:save_to_csv and every(10#cycle){
		string current <- ""+cycle+","+length(immune_people)+","+length(susceptible_people)+","+length(infected_people);
		save current to: "output_herd_immunity/results_"+scenario+".csv" type:csv rewrite:false;
	}
	reflex saveToCSVR0 when:save_to_csv_R0 and patient_0_recovered{
		int nb_cases <- 0;
		ask people where(each.im_patient_0){
			nb_cases <- nb_caused_infections;
		}
		string current <- ""+nb_cases;
		save current to: "output_herd_immunity/results_R0_"+scenario+".csv" type:csv rewrite:false;
		write scenario+":"+"ready";
		stop_simulation <- true;
		//do die;
	}
}
species people skills:[moving]{
	string status;
	int nb_caused_infections 		<- 0;
	float time_infected 				<- 0#s;
	bool recovered					<- false;
	list<people> contacts 		<- [] update:people at_distance(infection_distance) where(each.status="susceptible");
	point target <- any_location_in(world);
	
	//Variables to calculate R0
	bool im_patient_0 <- false;
	
	reflex update_status{
		if status = "susceptible"{
			
		}
		else if status = "infected"{
			if time_infected > infectious_time{
				recovered 	<- true;
				status 		<- "immune";
				if im_patient_0{
					patient_0_recovered <- true;
				}
			}
			time_infected <- time_infected + 1*step;
		}
		else if status = "immune"{
			
		}
	}
	bool infect{
		if status != "susceptible"{
			return false;
		}
		status <- "infected";
		return true;	
	}
	reflex infect_others when:not empty(contacts) and status="infected"{
		int tmp_counter <- 0;
		ask contacts{
			if(self.infect()){
				myself.nb_caused_infections <- myself.nb_caused_infections + 1;
			}
		}
	}
	reflex movement{
		if location = target{
			target <- any_location_in(world);
		}
		do goto target:target;
	}
	aspect default{
		draw circle(7) color:agent_color[status]; 
	}
}
