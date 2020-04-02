/***
* Name: coronavirus
* Author: Gamaliel Palomo and Mario Siller
* Description: Modelo que permite conocer el impacto de la cultura, educación, forma de vida de la población en méxico en el patrón de dispersión del vírus.
* El modelo considera agentes que son personas, estas personas tienen comportamientos que se rigen dependiendo de ciertas variables como el nivel socio-economico. 
* Las personas con una alta necesidad de realizar actividades económicas se verán más motivadas a salir de casa en el caso de una emergencia epidemiológica.
* Las personas tienen diversos estados relacionados con el vírus: Suceptible, Infectado y Recuperado, basado en el bien conocido modelo SIR.
* El modelo calcula las probabilidades de transición de estado de los agentes de manera individual y general, teniendo la ventaja de ser valores dinámicos con lo que 
* pueden hacerse estimaciones más cercanas a la realidad.
* La base de la transmisión del virus es el contacto, contacto directo entre una persona infectada y una susceptible.
* El modelo puede simular tres escenarios de tiempo: corto, mediano y largo plazo donde se expone el comprotamiento de la enfermedad en la rutina de las 
* personas diariamente. Mediano plazo considera una semana con una escala de espacio mayor. Largo plazo simula el comportamiento de la
* ciudad y de sus servicios y actividad económica en un lapso de un mes.
* This model is based mostly in the following papers:
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
	
	//General virus behavior related parameters and variables
	float alpha parameter: "alpha" category:"Model parameters" <- 0.05 min:0.0 max:1.0; //Disease-related death rate of infectious individuals.
	float beta parameter: "beta" category:"Model parameters" <- 0.5 min:0.0 max:1.0; //Transmission probability of susceptible individuals.
	float gamma parameter: "gamma" category:"Model parameters" <- 0.1 min:0.0 max:1.0; //Rate of isolation of susceptible individuals.
	float delta parameter: "delta" category:"Model parameters" <- 0.1 min:0.0 max:1.0; //Rate at which return to susceptible class S from class Qs.
	float kappa parameter: "kappa" category:"Model parameters" <- 0.3 min:0.0 max:1.0; //Rate constant for recover.
	float mu parameter: "mu" category:"Model parameters"<- 0.1 min:0.0 max:1.0; //Per capita natural mortality rate.
	float rho parameter: "rho" category:"Model parameters" <- 0.86834 min:0.0 max:1.0; //Probability of having symptoms among infected individuals.
	float sigma parameter: "sigma" category:"Model parameters" <- 1/7 min:0.0 max:1.0; //Transition rate of exposed individuals to the infected class.
	
	//Visualization parameters
	list<rgb> status_color <- [#yellow,#darkturquoise,#indigo,#red,#blue,#green,#black];
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
		create people number:scenario="small"?500:1000;
		ask one_of(people){status<-2;}
	}
}
species people skills:[moving] parallel:100{
	//Mobility
	point target;
	float speed <- 1.4;
	//Virus
	int status; //0:Susceptible; 1:Exposed; 2:Infectious not yet symptomatic (pre or Asymptomatic); 3:Infectious with symptoms; 4:Hospitalized; 5:Recovered; 6:Isolated.
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
		if scenario = "small"{do goto target:target on:road_network;} else {do goto target:target;}
	}
	reflex virus{
		//This agent has been exposed to the virus
		if status = 1{
			time_exposed <- time_exposed + 1;
			if rnd(100)/100 < sigma{
				//Exposed agent becomes infected.
				status <- rnd(100)/100 < rho?3:2;//Likelihoood of rho of becoming Infectious with symptoms and (1-rho) of being asymptomatic.
			}
		}
		//This agent is infectous and asymptomatic
		if status = 2 or status = 3{ 
			list<people> near_people <- people at_distance(2);
			if near_people != nil{
				loop contact over:near_people{
					ask contact{
						if rnd(100)/100 < beta and status = 0{status <- 1;time_exposed <- 0#hour;}
					}
				}
			}
			incubation_period <- incubation_period + step;
		}
		//This agent is infectous and shows symptoms
		//It depends on the profile of agent if it goes to a hospital, goes to isolate at home.
		if status = 3{
			
		}
		if status = 4{
			
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
			chart "Global status" type: series x_label: "time" style:ring{
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