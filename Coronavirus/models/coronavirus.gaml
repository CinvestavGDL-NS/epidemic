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

global{
	//scenario
	string scenario parameter: "scenario" category:"Model parameters" <- "small" among:["small","large"]; //small or large scenario
	file roads_shp <- file("../includes/gis/"+scenario+"_roads.shp");
	int timeElapsed <- 0 update: int(cycle*5#mn);
	
	//General virus behavior related parameters and variables
	int init_nb_exposed parameter:"init_nb_exposed" category:"Model parameters" <- 10 min:0 max:100; //Number of agents initially exposed to the virus S.
	float alpha parameter: "alpha" category:"Model parameters" <- 0.05 min:0.0 max:1.0; //Probability of going from Exposed to Susceptible.
	float beta parameter: "beta" category:"Model parameters" <- 0.25 min:0.0 max:1.0; //Probability of going from Susceptible to Exposed.
	float rho parameter: "rho" category:"Model parameters" <- 0.86834 min:0.0 max:1.0; //Probability of having symptoms among infected individuals E->Is.
	float sigma parameter: "sigma" category:"Model parameters" <- 1/7 min:0.0 max:1.0; //Probability of not having symptoms among infected individiuals E->Ia.
	float delta_Is parameter: "delta_Is" category:"Model parameters" <- 0.13266 min:0.0 max:1.0; //Probability of going from symptomatic infected individuals to the quarantined infected class I->Q_Is.
	float delta_Ia parameter: "delta_Ia" category:"Model parameters" <- 0.13266 min:0.0 max:1.0; //Probability of going from asymptomatic infected individuals to the quarantined infected class I->Q_Ia.
	float gamma parameter: "gamma" category:"Model parameters" <- 0.1 min:0.0 max:1.0; //Probability of being symptomatic and being then hospitalized.
	float delta parameter: "delta" category:"Model parameters" <- 0.1 min:0.0 max:1.0; //Probability of return to susceptible class S once Recovered.
	float kappa_QIs parameter: "kappa_QIs" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Probability of recovery after being Infectious symptomatic and in isolation.
	float kappa_Is parameter: "kappa_Is" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Probability of recovery after being Infectious symptomatic.
	float kappa_Ia parameter: "kappa_Ia" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Probability of recovery after being Infectious asymptomatic.
	float kappa_H parameter: "kappa_H" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Probability of recovery after being Hospitalized.
	float kappa_QIa parameter: "kappa_QIa" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Probability of recovery after being Infectious asymptomatic.
	float mu parameter: "mu" category:"Model parameters"<- 0.1 min:0.0 max:1.0; //Per capita natural mortality rate for causes other than disease-related.
	
	
	//Visualization parameters
	//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious with symptoms and Isolated (Q_Is), 
	//4.Infectious asymptomatic (Ia), 5.Infectious asymptomatic and Isolated(Q_Ia), 6.Hospitalized (H), 7.Recovered (R), 8.Death(D).
	list<rgb> status_color <- [#yellow,#darkturquoise,#red,#magenta,#indigo,#sienna, #skyblue,#green,#gray];
	list<int> status_size <- scenario="small"?[5,6,7,8,9,10,11]:[10,12,14,16,18,20,22];
	
	//Output variables
	int nb_susceptible <- 0 update: length(people where(each.status=0));
	int nb_exposed <- 0 update: length(people where(each.status=1));
	int nb_infectious_asymptomatic <- 0 update: length(people where(each.status=2));
	int nb_infectious_symptomatic <- 0 update: length(people where(each.status=3));
	int nb_hospitalized <- 0 update: length(people where(each.status=4));
	int nb_recovered <- 0 update: length(people where(each.status=5));
	int nb_isolated <- 0 update: length(people where(each.status=6));
	
	//General model parameters
	geometry shape <- envelope(roads_shp);
	graph road_network;
	map<road, float> weight_map;
	init{
		step <- scenario = "small"? 5#mn:1#hour; 
		create road from:roads_shp;
		weight_map <- road as_map(each::each.shape.perimeter);
		road_network <- as_edge_graph(road) with_weights weight_map;
		create people number:scenario="small"?500-init_nb_exposed:1000-init_nb_exposed;
		create people number:init_nb_exposed{status<-1;}
	}
}
species people skills:[moving] parallel:100{
	//Mobility
	point target;
	float speed <- 1.4;
	//Virus
	//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious with symptoms and Isolated (Q_Is), 
	//4.Infectious asymptomatic (Ia), 5.Infectious asymptomatic and Isolated(Q_Ia), 6.Hospitalized (H), 7.Recovered (R), 8.Death(D).
	int status;
	float time_exposed; //In case of being exposed to an infected contact.
	float incubation_period; //The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days. [WHO: The “incubation period” means the time between catching the virus and beginning to have symptoms of the disease. Most estimates of the incubation period for COVID-19 range from 1-14 days, most commonly around five days.]
	
	init{
		location <- any_location_in(world);
		target <- any_location_in(world);
		status <- 0; 
	}
	
	reflex mobility{
		if target = location{
			target<-any_location_in(world);
		}
		if scenario = "small" and status != 6 {do goto target:target on:road_network;} else if status != 6 {do goto target:target;}
	}
	reflex virus{
		//0.Susceptible (S), 1.Exposed (E), 2.Infectious with symptoms (Is), 3.Infectious with symptoms and Isolated (Q_Is), 
		//4.Infectious asymptomatic (Ia), 5.Infectious asymptomatic and Isolated(Q_Ia), 6.Hospitalized (H), 7.Recovered (R), 8.Death(D).
		//This agent has been exposed to the virus
		if status = 1{
			time_exposed <- time_exposed + 1;
			if rnd(100)/100 < sigma{
				//Exposed agent becomes infected.
				status <- rnd(100)/100 < rho?3:2;//Likelihoood of rho of becoming Infectious with symptoms and (1-rho) of being asymptomatic.
			}
		}
		//This agent is infectous showing symptoms
		if status = 2 { 
			list<people> near_people <- people at_distance(2);//To do: as a parameter 
			if near_people != nil{
				loop contact over:near_people{
					ask contact{
						if rnd(100)/100 < beta and status = 0{status <- 1;time_exposed <- 0#hour;}
					}
				}
			}
			incubation_period <- incubation_period + step;
			if rnd(100)/100 < delta_Is{status <- 6;} //Infected goes to isolation.
		}
		//This agent is infectous asymptomatic
		if status = 3{
			list<people> near_people <- people at_distance(2);
			if near_people != nil{
				loop contact over:near_people{
					ask contact{
						if rnd(100)/100 < beta and status = 0{status <- 1;time_exposed <- 0#hour;}
					}
				}
			}
			incubation_period <- incubation_period + step;
			if rnd(100)/100 < delta_Is{status <- 6;} //Infected goes to isolation.
		}
		if status = 4{
		//Agent has been infected with virus, showing symptoms and required hospitalization.
		}
		if status = 5{
			
		}
		if status = 6{
			
		}
	}
	user_command "infect"{status <- 3;}
	aspect default{draw sphere(status_size[status]) color:status_color[status];}
}
species road{
	aspect default{draw shape color:#gray;}
}
experiment simulation{
	output{
		layout #split;
		display main background:#black type:opengl{
			species road aspect:default;
			species people aspect:default;
			/*overlay position: { 10, 10 } size: { 0.1,0.1 } background: # black border: #black rounded: true{
                float y <- 30#px;
               draw ".:0123456789" at: {0#px,0#px} color:#white font: font("SansSerif", 20, #plain);
               draw "Infected: " +  length(people where (each.status=1)) at: { 40#px, y + 10#px } color: #white font: font("SansSerif", 15, #plain);
               // draw "Men: " +  length(men) at: { 40#px, y + 30#px } color: #white font: font("SansSerif", 20, #plain);
               //draw "Time: "+  current_date at:{ 40#px, y + 50#px} color:#white font:font("SansSerif",20, #plain);
               // draw "Sunlight: "+ sunlight at:{ 40#px, y + 70#px} color:#white font:font("SansSerif",20, #plain);
            }*/
		}
		display chart background:#black type:java2D refresh:every(1#hour){
			overlay size: { 180 #px, 100 #px } {
				draw ""+int(timeElapsed/3600)+" hours" at:{350#px,30#px} color:#white font: font("Arial", 20,#plain);
			}
			chart "Global status" type: series x_label: "Time" y_label:"People" style:ring background:#black color:#white label_font:"Arial" x_tick_unit:step memorize:false label_font_size:15 legend_font_size:15 title_font:"Arial" title_font_size:16 title_visible:false{
				//0:Susceptible; 1:Exposed; 2:Infectious not yet symptomatic (pre or Asymptomatic); 3:Infectious with symptoms; 4:Hospitalized; 5:Recovered; 6:Isolated
				data "Susceptible" value: nb_susceptible color: status_color[0] marker: false style: line;
				data "Exposed" value: nb_exposed color: status_color[1] marker: false style: line;
				data "Infectious Asymptomatic" value: nb_infectious_asymptomatic color: status_color[2] marker: false style: line;
				data "Infectious Symptomatic" value: nb_infectious_symptomatic color: status_color[3] marker: false style: line;
				data "Hospitalized" value: nb_hospitalized color: status_color[4] marker: false style: line;
				data "Recovered" value: nb_recovered color: status_color[5] marker: false style: line;
				data "Isolated" value: nb_isolated color: status_color[6] marker: false style: line;
			}
		}
	}
}