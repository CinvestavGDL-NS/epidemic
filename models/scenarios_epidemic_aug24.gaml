/**
* Name: scenariosepidemic
* Based on the internal empty template. 
* Author: Gamaliel Palomo
* Tags: 
*/


model scenariosepidemic
import "epidemic_v2.gaml"

//SECOND VERSION EXPERIMENTS
experiment Scenario1 type:batch until:int(timeElapsed/86400)=180{//until:stop_simulation{
	init{
		/*create simulation number:60 with:[
			scenario::"25-75-1",
			update_beliefs:: false,
			saveToCSV::false,
			mobility_restriction::false,
			nb_vertical_individualist::100,
			nb_vertical_collectivist::100,
			nb_horizontal_individualist::100,
			nb_horizontal_collectivist::100,
			init_nb_exposed::1,
			save_to_csv_R0::true,
			saveToCSV::false
		]*/
		/*create simulation number:1 with:[
			scenario::"Scenario1/100-0-10-noupdatebeliefs-nointervention-balanced",
			update_beliefs:: false,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::100,
			nb_vertical_collectivist::100,
			nb_horizontal_individualist::100,
			nb_horizontal_collectivist::100,
			init_nb_exposed::10,
			save_to_csv_R0::false,
			mobility_restriction:: false
		];
		create simulation number:1 with:[
			scenario::"Scenario1/100-0-10-updatebeliefs-nointervention-balanced",
			update_beliefs:: true,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::100,
			nb_vertical_collectivist::100,
			nb_horizontal_individualist::100,
			nb_horizontal_collectivist::100,
			init_nb_exposed::10,
			save_to_csv_R0::false
		];
		create simulation number:1 with:[
			scenario::"Scenario1/100-0-10-updatebeliefs-nointervention-balanced",
			update_beliefs:: true,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::100,
			nb_vertical_collectivist::100,
			nb_horizontal_individualist::100,
			nb_horizontal_collectivist::100,
			init_nb_exposed::10,
			save_to_csv_R0::false
		];
		create simulation number:1 with:[
			scenario::"Scenario1/100-0-10-updatebeliefs-nointervention-collectivist",
			update_beliefs:: true,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::1,
			nb_vertical_collectivist::1,
			nb_horizontal_individualist::1,
			nb_horizontal_collectivist::397,
			init_nb_exposed::10,
			save_to_csv_R0::false
		];
		create simulation number:1 with:[
			scenario::"Scenario1/100-0-10-updatebeliefs-nointervention-individualist",
			update_beliefs:: true,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::397,
			nb_vertical_collectivist::1,
			nb_horizontal_individualist::1,
			nb_horizontal_collectivist::1,
			init_nb_exposed::10,
			save_to_csv_R0::false
		];*/
		
		//create simulation with:[scenario::"50-50-1",save_to_csv_R0::true];
		//create simulation with:[scenario::"75-25-1",save_to_csv_R0::true];
	}
}
experiment Scenario2 type:batch until:int(timeElapsed/86400)=180{
	init{
		create simulation number:1 with:[
				scenario::"Scenario2/100-0-10-updatebeliefs-nointervention-usa",
				allow_beliefs:: true,
				saveToCSV::true,
				mobility_restriction::false,
				nb_vertical_individualist::397,
				nb_vertical_collectivist::1,
				nb_horizontal_individualist::1,
				nb_horizontal_collectivist::1,
				unique_individualist_value::0.9,
				collectivist_value::0.1,
				individualist_value::0.65,
				init_nb_exposed::10,
				save_to_csv_R0::false
			];
		create simulation number:1 with:[
			scenario::"Scenario2/100-0-10-updatebeliefs-nointervention-mex",
			allow_beliefs:: true,
			saveToCSV::true,
			mobility_restriction::false,
			nb_vertical_individualist::1,
			nb_vertical_collectivist::1,
			nb_horizontal_individualist::1,
			nb_horizontal_collectivist::397,
			unique_individualist_value::0.35,
			collectivist_value::0.65,
			individualist_value::0.1,
			init_nb_exposed::10,
			save_to_csv_R0::false
		];		
	}

}

//FIRST VERSION EXPERIMENTS

/*
experiment scenario1_no_intervention type:batch until:int(timeElapsed/86400)=180{
	parameter 'update_beliefs' var:update_beliefs <- false;
	parameter 'saveToCSV' var:saveToCSV <- true;
	parameter 'mobility_restriction' var:mobility_restriction <- false;
	parameter 'vert_indiv' var:nb_vertical_individualist <- 100;
	parameter 'vert_collect' var:nb_vertical_collectivist <- 100;
	parameter 'hor_indiv' var:nb_horizontal_individualist <- 100;
	parameter 'hor_collect' var:nb_horizontal_collectivist <- 100;
	parameter 'nb_init_exposed' var:init_nb_exposed <- 10;	
}

experiment scenario2_no_intervention_beliefs type:batch until:int(timeElapsed/86400)=180{
	parameter 'update_beliefs' var:update_beliefs <- true;
	parameter 'saveToCSV' var:saveToCSV <- true;
	parameter 'mobility_restriction' var:mobility_restriction <- false;
	parameter 'vert_indiv' var:nb_vertical_individualist <- 100;
	parameter 'vert_collect' var:nb_vertical_collectivist <- 100;
	parameter 'hor_indiv' var:nb_horizontal_individualist <- 100;
	parameter 'hor_collect' var:nb_horizontal_collectivist <- 100;
	parameter 'nb_init_exposed' var:init_nb_exposed <- 10;	
	parameter 'aux' var:aux_parameter <-0 min:0 max:400;
}

experiment scenario3_intervention_beliefs type:batch until:int(timeElapsed/86400)=180{
	parameter 'update_beliefs' var:update_beliefs <- true;
	parameter 'saveToCSV' var:saveToCSV <- true;
	parameter 'mobility_restriction' var:mobility_restriction <- true;
	parameter 'vert_indiv' var:nb_vertical_individualist <- 100;
	parameter 'vert_collect' var:nb_vertical_collectivist <- 100;
	parameter 'hor_indiv' var:nb_horizontal_individualist <- 100;
	parameter 'hor_collect' var:nb_horizontal_collectivist <- 100;
	parameter 'nb_init_exposed' var:init_nb_exposed <- 10;	
	parameter 'aux' var:aux_parameter <-0 min:0 max:400;	
}

experiment scenario4_intervention_beliefs type:batch until:int(timeElapsed/86400)=180{
	parameter 'update_beliefs' var:update_beliefs <- true;
	parameter 'saveToCSV' var:saveToCSV <- true;
	parameter 'mobility_restriction' var:mobility_restriction <- false;
	parameter 'vert_indiv' var:nb_vertical_individualist <- 397;
	parameter 'vert_collect' var:nb_vertical_collectivist <- 1;
	parameter 'hor_indiv' var:nb_horizontal_individualist <- 1;
	parameter 'hor_collect' var:nb_horizontal_collectivist <- 1;
	parameter 'nb_init_exposed' var:init_nb_exposed <- 10;	
	parameter 'aux' var:aux_parameter <-0 min:0 max:400;	
}
experiment scenario5_intervention_beliefs type:batch until:int(timeElapsed/86400)=180{
	parameter 'update_beliefs' var:update_beliefs <- true;
	parameter 'saveToCSV' var:saveToCSV <- true;
	parameter 'mobility_restriction' var:mobility_restriction <- false;
	parameter 'vert_indiv' var:nb_vertical_individualist <- 1;
	parameter 'vert_collect' var:nb_vertical_collectivist <- 1;
	parameter 'hor_indiv' var:nb_horizontal_individualist <- 1;
	parameter 'hor_collect' var:nb_horizontal_collectivist <- 397;
	parameter 'nb_init_exposed' var:init_nb_exposed <- 10;	
	parameter 'aux' var:aux_parameter <-0 min:0 max:400;	
}
*/

experiment big_scenario type:batch until:int(timeElapsed/86400)=180{
	init{
		create simulation number:1 with:[
			scenario::"Scenario3/El_Arenal_nobeliefs",
			allow_beliefs:: false,
			saveToCSV::true,
			unique_individualist_value::0.35
			//seed::the_seed
		];
		create simulation number:1 with:[
			scenario::"Scenario3/El_Arenal_collectivist",
			allow_beliefs:: true,
			saveToCSV::true,
			unique_individualist_value::0.35
			//seed::the_seed
		];
		create simulation number:1 with:[
			scenario::"Scenario3/El_Arenal_individualist",
			allow_beliefs:: true,
			saveToCSV::true,
			unique_individualist_value::0.9
			//seed::the_seed
		];
	}
}

experiment simulation{
	parameter 'allow_beliefs' 				var:allow_beliefs 								<- true;
	parameter 'individualist_value'		var:unique_individualist_value		<- 0.35;
	parameter 'saveToCSV'					var:saveToCSV 									<- false;
	parameter 'mobility_restriction' 	var:mobility_restriction 					<- false;
	parameter 'nb_init_exposed' 			var:init_nb_exposed 							<- 1;	
	parameter 'aux' 								var:aux_parameter 								<-0 min:0 max:400;	
	//parameter 'seed'								var:seed													<- the_seed;
	
	output{
		layout #split;
		display main background:#black type:opengl draw_env:false{
			
			species limit aspect:default refresh:false;
			species block aspect:default refresh:false;
			species park aspect:default refresh:false;
			species hospital aspect:default refresh:false;
			species people aspect:default;
			overlay size: { 0 #px, 0 #px } {
				draw "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.:0123456789" at: {0#px,0#px} color:rgb(0,0,0,0) font: font("Arial", 20, #plain);
				draw ""+current_date at:{30#px,30#px} color:#white font: font("Arial", 20,#plain);
				
				draw "Mask: "+nb_mask at:{30#px,110#px} color:#white font: font("Arial", 20, #plain);
				draw "H.Wash: "+nb_mask at:{30#px,140#px} color:#white font: font("Arial", 20, #plain);
				draw "S.Distance: "+nb_mask at:{30#px,170#px} color:#white font: font("Arial", 20, #plain);
				
				draw "S: "+nb_susceptible at:{30#px,200#px} color:#white font: font("Arial", 20, #plain);
				draw "E: "+nb_exposed at:{30#px,230#px} color:#white font: font("Arial", 20, #plain);
				draw "Is: "+nb_infectious_symptomatic at:{30#px,260#px} color:#white font: font("Arial", 20, #plain);
				draw "Ia: "+nb_infectious_asymptomatic at:{30#px,290#px} color:#white font: font("Arial", 20, #plain);
				draw "R: "+nb_recovered at:{30#px,320#px} color:#white font: font("Arial", 20, #plain);
				draw "Im: "+nb_immune at:{30#px,350#px} color:#white font: font("Arial", 20, #plain);
				draw "H: "+nb_H at:{30#px,380#px} color:#white font: font("Arial", 20, #plain);
				draw "D: "+nb_D at:{30#px,410#px} color:#white font: font("Arial", 20, #plain);
			}
			/*overlay position: { 10, 10 } size: { 0.1,0.1 } background: # black border: #black rounded: true{
                float y <- 30#px;
               draw ".:0123456789" at: {0#px,0#px} color:#white font: font("SansSerif", 20, #plain);
               draw "Infected: " +  length(people where (each.status=1)) at: { 40#px, y + 10#px } color: #white font: font("SansSerif", 15, #plain);
               // draw "Men: " +  length(men) at: { 40#px, y + 30#px } color: #white font: font("SansSerif", 20, #plain);
               //draw "Time: "+  current_date at:{ 40#px, y + 50#px} color:#white font:font("SansSerif",20, #plain);
               // draw "Sunlight: "+ sunlight at:{ 40#px, y + 70#px} color:#white font:font("SansSerif",20, #plain);
            }*/	
		}
		display chart_infections background:#black type:java2D refresh:every(1#hour){
			overlay size: { 5 #px, 50 #px } {
				draw ""+int(timeElapsed/86400)+" days, "+mod(int(timeElapsed/3600),24)+" hours" at:{150#px,30#px} color:#white font: font("Arial", 20,#plain);
			}
			chart "Global status" type: series legend_font:font("Arial",15,#bold) x_label: "Time" y_label:"People" style:ring background:#black color:#white label_font:font("Arial",15,#bold)  memorize:false title_font:font("Arial",15,#plain) title_visible:false{
				//0:Susceptible; 1:Exposed; 2:Infectious not yet symptomatic (pre or Asymptomatic); 3:Infectious with symptoms; 4:Hospitalized; 5:Recovered; 6:Isolated
				//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious without symptoms(Ia), 4.Recovered(R), 5.Immune(I).
				data "Susceptible" value: nb_susceptible color: status_color["S"] marker: false style: line;
				data "Mask" value:length(people where(each.wear_mask=true)) color:#deepskyblue marker:false style:line;
				data "Recovered" value: nb_recovered color: status_color["R"] marker: false style: line;
				data "Immune" value:nb_immune color:status_color["I"] marker:false style:line;
				data "Deaths" value:nb_immune color:status_color["D"] marker:false style:line;
			}
		}
		display chart_quarantine background:#black type:java2D refresh:every(1#hour){
			overlay size: { 5 #px, 100 #px } {
				draw ""+int(timeElapsed/86400)+" days, "+mod(int(timeElapsed/3600),24)+" hours" at:{150#px,30#px} color:#white font: font("Arial", 20,#plain);
			}
			chart "Quarantine" type: series legend_font:font("Arial",15,#bold) x_label: "Time" y_label:"People" style:ring background:#black color:#white label_font:font("Arial",15,#bold)  memorize:false title_font:font("Arial",15,#plain) title_visible:false{
				data "Qa" value:nb_Qa color:status_color["Qa"] marker:false style:line;
				data "Qs" value:nb_Qs color:status_color["Qs"] marker:false style:line;
				data "Hospitalized" value:nb_H color:status_color["H"] marker:false style:line;
			}
		}
		display chart_infected background:#black type:java2D refresh:every(1#hour){
			overlay size: { 5 #px, 100 #px } {
				draw ""+int(timeElapsed/86400)+" days, "+mod(int(timeElapsed/3600),24)+" hours" at:{150#px,30#px} color:#white font: font("Arial", 20,#plain);
			}
			chart "Infected" type: series legend_font:font("Arial",15,#bold) x_label: "Time" y_label:"People" style:ring background:#black color:#white label_font:font("Arial",15,#bold)  memorize:false title_font:font("Arial",15,#plain) title_visible:false{
				data "Exposed" value: nb_exposed color: status_color["E"] marker: false style: line;
				data "Infectious Symptomatic" value: nb_infectious_symptomatic color: status_color["Is"] marker: false style: line;
				data "Infectious Asymptomatic" value: nb_infectious_asymptomatic color: status_color["Ia"] marker: false style: line;
			}
		}
	}
}