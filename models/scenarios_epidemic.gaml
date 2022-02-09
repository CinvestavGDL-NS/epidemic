/**
* Name: scenariosepidemic
* Based on the internal empty template. 
* Author: Gamaliel Palomo
* Tags: 
*/

model scenariosepidemic
import "epidemic_v2.gaml"

//SECOND VERSION EXPERIMENTS
experiment R0 type:batch until:int(timeElapsed/86400)=180{
	init{
		//create simulation with:[scenario::"50-50-1",save_to_csv_R0::true];
		//create simulation with:[scenario::"75-25-1",save_to_csv_R0::true];
	}
}

experiment big_scenario type:batch until:int(timeElapsed/86400)=119{
	init{
		/*create simulation number:1 with:[
			scenario::"Scenario3/El_Arenal_nobeliefs",
			allow_beliefs:: false,
			saveToCSV::true,
			individualist_value::0.35,
			seed::10.0
		];*/
		loop i from:0 to:10{
			create simulation with:[
				scenario::"Scenario3/El_Arenal_collectivist_"+i,
				allow_beliefs:: true,
				saveToCSV::true,
				individualist_value::0.35,
				mobility_restriction::true
			];
		}
		
		/*create simulation number:1 with:[
			scenario::"Scenario3/El_Arenal_individualist",
			allow_beliefs:: true,
			saveToCSV::true,
			individualist_value::0.9,
			seed::10.0
		];*/
	}
}

experiment GUI{
	parameter 'allow_beliefs' 				var:allow_beliefs 								<- true;
	parameter 'individualist_value'		var:individualist_value						<- 0.35;
	parameter 'saveToCSV'					var:saveToCSV 									<- false;
	parameter 'mobility_restriction' 	var:mobility_restriction 					<- true;
	parameter 'seed'								var:seed													<- 10.0;
	
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
		}
		display chart_infections background:#black type:java2D refresh:every(1#hour){
			overlay size: { 5 #px, 50 #px } {
				draw ""+int(timeElapsed/86400)+" days, "+mod(int(timeElapsed/3600),24)+" hours" at:{150#px,30#px} color:#white font: font("Arial", 20,#plain);
			}
			chart "Global status" type: series legend_font:font("Arial",15,#bold) x_label: "Time" y_label:"People" style:ring background:#black color:#white label_font:font("Arial",15,#bold)  memorize:false title_font:font("Arial",15,#plain) title_visible:false{
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



/*experiment Scenario2 type:batch until:int(timeElapsed/86400)=180{
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

}*/