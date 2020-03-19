/***
* Name: coronavirus
* Author: Gamaliel Palomo
* Description: Modelo que permite conocer el impacto de la cultura, educación, forma de vida de la población en méxico en el patrón de dispersión del vírus.
* El modelo considera agentes que son personas, estas personas tienen comportamientos que se rigen dependiendo de ciertas variables como el nivel socio-economico. 
* Las personas con una alta necesidad de realizar actividades económicas se verán más motivadas a salir de casa en el caso de una emergencia epidemiológica.
* Las personas tienen diversos estados relacionados con el vírus: Suceptible, Infectado y Recuperado, basado en el bien conocido modelo SIR.
* El modelo calcula las probabilidades de transición de estado de los agentes de manera individual y general, teniendo la ventaja de ser valores dinámicos con lo que 
* pueden hacerse estimaciones más cercanas a la realidad.
* La base de la transmisión del virus es el contacto, contacto directo entre una persona infectada y una susceptible.
* Tags: Tag1, Tag2, TagN
***/

model coronavirus

/* Insert your model definition here */

global{
	geometry shape <- square(1000); 
	init{
		create people number:100;
	}
}
species people skills:[moving]{
	//Mobility
	point target;
	float speed <- 5.0;
	//Virus
	int status; //0:susceptible; 1:Infected; 2:Recovered
	list<rgb> status_color <- [#green,#red,#blue];
	
	init{
		target<-point(rnd(1000),rnd(1000));
		status <- 0; 
	}
	
	reflex mobility{
		if target = location{
			target<-point(rnd(1000),rnd(1000));
		}
		do goto target:target;
	}
	reflex virus{
		if status = 1{
			list<people> near_people <- people at_distance(2);
			if near_people != nil{
				loop contact over:near_people{
					ask contact{
						status <- 1;
					}
				}
			}			
		}
	}
	aspect default{
		draw circle(5) color:status_color[status];
	}
}

experiment simulation{
	output{
		layout #split;
		display main background:#black type:opengl{
			species people aspect:default;
		}
		display chart background:#black type:java2D{
			chart "Global status" type: series x_label: "time"{
				data "Susceptible" value: length(people with:[status=0]) color: # blue marker: false style: line;
				data "Infected" value: sinlist color: # red marker: false style: line;
				data "Recovered" value: sinlist color: # red marker: false style: line;
			}
		}
	}
}