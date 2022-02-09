/**
* Name: scenariosvalidation
* Based on the internal empty template. 
* Author: Gamaliel Palomo
* Tags: 
*/


model sensitivityanalysis
import "epidemic.gaml"

//
experiment COI type:batch until:int(timeElapsed/86400)=180{
	init{
		loop i from:0 to:10{
			create simulation with:[
				scenario::"Sensitivity analysis/cultural_orientation_index_"+i,
				update_beliefs:: true,
				saveToCSV::true,
				mobility_restriction::false,
				nb_vertical_individualist::0,
				nb_vertical_collectivist::0,
				nb_horizontal_individualist::0,
				nb_horizontal_collectivist::0,
				nb_unique_profile::400,
				unique_individualist_value::float(i)/10,
				collectivist_value::0.1,
				individualist_value::0.65,
				init_nb_exposed::10,
				save_to_csv_R0::false
			];
		}

	}

}