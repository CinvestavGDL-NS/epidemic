model BayesianInference

global{

	string scenario;
	int nb_agents;
	bool saveToCSV;
	int day <- 0 update:cycle;
	float incoming_information <- 0.0 update:current_date.day/180;
	
	init{
		step <- 1#day;
		loop i from: 0 to:  nb_agents{
			create people{
				unique_individualist_value <- i/nb_agents;
			}
		}
		//create people{unique_individualist_value <- 0.5;}
		//create people{unique_individualist_value <- 1.0;}
}
	reflex save_results when:saveToCSV {
		string output <- ""+day+","+incoming_information;
		loop i from:0 to:nb_agents {
			output <- output + "," + people(i).belief;
		}
		save output to: "output_epidemic/"+scenario+".csv" type:csv rewrite:false;
	}
	/*reflex stop_simulation when: cycle = 3{
		do pause ;
   }*/
}

species people{
	
	float belief <- 0.0;
	float unique_individualist_value ;
	init{
		write name +":" +belief;
	}
	
	float likelihood{
		return unique_individualist_value;
	}
	
	float incoming_information{
		return day/180;
	}
	
	reflex update_beliefs{
		if belief = 0.0{
			belief <- 0.001;
		}
		float numerator1 			<- likelihood()*belief;
		float denominator1 		<- likelihood()*belief + (1-likelihood())*(1-belief);
		float numerator2 			<- (1-likelihood())*belief;
		float denominator2 		<- (1-likelihood())*belief + likelihood()*(1-belief);
		try{
			float t_minus_1 <- belief;
			write "\n  ---------------------  Incoming information: " + incoming_information() + "   ---------------------------";
			float result 		<- (numerator1*incoming_information()/denominator1) + (numerator2*(1-incoming_information())/denominator2);
			write name+" entra";
			write "belief: "+belief;
			belief <- result;
			write "new belief: "+belief; 
			//belief 		<- result=0?0.001:result;
			//belief 		<- belief=1.0?0.999:belief;
			
			write "delta:"+unique_individualist_value+" \nbelief(t-1):"+t_minus_1+" \ndivision1: "+numerator1*incoming_information()+"/"+denominator1+"\ndivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
			+"\n" +"likelihood: "+likelihood()+ ", \nbelief: "+belief;
		}catch{
			write "\n  ---------------------  Incoming information: " + incoming_information() + "   ---------------------------";
			write "delta:"+unique_individualist_value+" \nbelief(t-1):"+belief+"\ndivision1: "+numerator1*incoming_information()+"/"+denominator1+"\ndivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
			+"\n" +"likelihood: "+likelihood()+ ", \nbelief: "+belief;
			//write "delta:"+unique_individualist_value+" division1: "+numerator1*incoming_information()+"/"+denominator1+"\tdivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
			//+"\n" +"likelihood: "+likelihood()+ ", belief: "+belief;
			//write "agent("+name+") division1: "+numerator1*incoming_information()+"/"+denominator1+"\tdivision2: "+numerator2*(1-incoming_information())+"/"+denominator2
			//+"\n" +"likelihood: "+likelihood()+ ", beliefs["+i+"]:"+belief;
		}
	}	
	

}

experiment test type:batch until:day = 180{
	parameter "scenario" var:scenario <- "BI/test";
	parameter "saveToCSV" var:saveToCSV <- true;
	parameter "nb_agents" var:nb_agents <- 10;
}



