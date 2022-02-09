/**
* Name: scenarios
* Based on the internal empty template. 
* Author: Gamaliel Palomo
* Tags: 
*/

model scenarios

import "R0.gaml"

experiment herd_batch type:batch until:cycle=10000{
	init{
		create simulation with:[scenario::"250-750-1",save_to_csv::true];
		create simulation with:[scenario::"500-500-1",save_to_csv::true];
		create simulation with:[scenario::"750-250-1",save_to_csv::true];
	}
}

experiment calc_R0 type:batch until:stop_simulation {
	init{
		//create simulation number:100 with:[scenario::"250-750-1",save_to_csv_R0::true];
		//create simulation number:100 with:[scenario::"500-500-1",save_to_csv_R0::true];
		create simulation number:100 with:[scenario::"750-250-1",save_to_csv_R0::true];
	}
}

experiment herd_gui type:gui{
	init{
		create simulation with:[scenario::"250-750-1"];
		create simulation with:[scenario::"500-500-1"];
		create simulation with:[scenario::"750-250-1"];
	}
	output{
		layout #split;
		display simulation background:#black{
			species people aspect:default;		
			overlay size: { 50 #px, 20 #px } color:rgb(255,255,255) transparency:0.3 border:#gray{
				draw "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.:0123456789" at: {0#px,0#px} color:rgb(0,0,0,0) font: font("Arial", 20, #plain);
				draw "R0: "+R0 with_precision 2 font:font("Arial",20,#plain) color:#white at:{20#px,20#px};
			}
		}
		display plot{
			chart "chart_"+scenario type:series y_label:"People"{
				data "immune"		 	value:length(immune_people) 			color:agent_color["immune"]	 		marker:false;
				data "susceptible" 		value:length(susceptible_people) 	color:agent_color["susceptible"] 		marker:false;
				data "infected" 			value:length(infected_people) 			color:agent_color["infected"] 			marker:false;
			}
		}
	}
}