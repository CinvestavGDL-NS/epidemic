import matplotlib.pyplot as plt
import numpy as np
import csv

sc = 5

color = ['red','black','green']

files = {
			1:["100-0-10-updatebeliefs-nointervention-balanced",
			 "100-0-10-updatebeliefs-nointervention-collectivist",
			 "100-0-10-updatebeliefs-nointervention-individualist"],

			2:["100-0-10-updatebeliefs-nointervention-usa",
			 "100-0-10-updatebeliefs-nointervention-mex"],

			3:["cultural_orientation_index_{}".format(i) for i in range(0,11)],

			4:["El_Arenal_collectivist"],

			5:["El_Arenal_collectivist_"+str(i) for i in range(0,10)]
		}
labels = {	1:["Balanced","Collectivist","Individualist"],
			2:["Population with USA parameters","Population with MEX parameters"],
			3:["0.0","0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1.0"],
			4:["El Arenal"],
			5:["Simulation "+str(i) for i in range(0,10)]
		}


scenario = {1:"Scenario1",2:"Scenario2",3:"Sensitivity analysis",4:"Scenario3", 5:"Scenario3"}

var_labels = {"nb_susceptible"				: "Susceptible people",
			  "nb_exposed"					: "Exposed people",
			  "nb_infectious_symtomatic" 	: "Infectious symptomatic people",
			  "nb_infectious_asymtomatic" 	: "Infectious not symptomatic",
			  "nb_recovered"				: "Recovered people",
			  "nb_immune"					: "Immune people",
			  "nb_Qs"						: "Symtomatic people in quarantine",
			  "nb_Qa"						: "Asymtomatic people in quarantine",
			  "nb_H"						: "Hospitalized people",
			  "nb_D"						: "Deceases",
			  "nb_mask"						: "People using mask",
			  "nb_hand_wash"				: "People who wash their hands",
			  "nb_social_distance"			: "People who keep social distance",
			  "R0"							: "Basic reproduction number (R0)",
			  "nb_infected"					: "Infected daily",
			  "nb_infected_total"			: "Total infected",
			  "semaphore"					: "Semaphore"
			}
variable = { 	  "nb_susceptible"				: [[] for i in range(len(files[sc]))],
				  "nb_exposed"					: [[] for i in range(len(files[sc]))],
				  "nb_infectious_symtomatic" 	: [[] for i in range(len(files[sc]))],
				  "nb_infectious_asymtomatic" 	: [[] for i in range(len(files[sc]))],
				  "nb_recovered"				: [[] for i in range(len(files[sc]))],
				  "nb_immune"					: [[] for i in range(len(files[sc]))],
				  "nb_Qs"						: [[] for i in range(len(files[sc]))],
				  "nb_Qa"						: [[] for i in range(len(files[sc]))],
				  "nb_H"						: [[] for i in range(len(files[sc]))],
				  "nb_D"						: [[] for i in range(len(files[sc]))],
				  "nb_mask"						: [[] for i in range(len(files[sc]))],
				  "nb_hand_wash"				: [[] for i in range(len(files[sc]))],
				  "nb_social_distance"			: [[] for i in range(len(files[sc]))],
				  "R0"							: [[] for i in range(len(files[sc]))],
				  "nb_infected"					: [[] for i in range(len(files[sc]))],
				  "nb_infected_total"			: [[] for i in range(len(files[sc]))],
				  "semaphore"					: [[] for i in range(len(files[sc]))]
				}

def load_files():
	for i in range(len(files[sc])):
		with open('../output_epidemic/'+
			scenario[sc]+
			'/'+
			files[sc][i]+
			'.csv') as csv_file:
			csv_reader = csv.reader(csv_file,delimiter=',')
			first = True
			for row in csv_reader:
				if first:
					first = False
				else:
					variable["nb_susceptible"][i].append(int(row[3]))
					variable["nb_exposed"][i].append(int(row[4]))
					variable["nb_infectious_symtomatic"][i].append(int(row[5]))
					variable["nb_infectious_asymtomatic"][i].append(int(row[6]))
					variable["nb_recovered"][i].append(int(row[7]))
					variable["nb_immune"][i].append(int(row[8]))
					variable["nb_Qs"][i].append(int(row[9]))
					variable["nb_Qa"][i].append(int(row[10]))
					variable["nb_H"][i].append(int(row[11]))
					variable["nb_D"][i].append(int(row[12]))
					variable["nb_mask"][i].append(int(row[13]))
					variable["nb_hand_wash"][i].append(int(row[14]))
					variable["nb_social_distance"][i].append(int(row[15]))
					variable["R0"][i].append(float(row[16]))
					variable["nb_infected"][i].append(float(row[17]))
					variable["nb_infected_total"][i].append(float(row[18]))
					variable["semaphore"][i].append(float(row[19]))


def plot_scenario(key,save):
	x = [i for i in range(len(variable["nb_susceptible"][0]))]

	plt.clf()
	plt.title(var_labels[key])
	plt.xlabel("Day")
	if(key=="R0"):
		label = "Value"
	else:
		label = "People"
	plt.ylabel(label)
	plt.xticks(np.arange(0,len(x)+1,20))
	for i in range(len(files[sc])):
		plt.plot(x,variable[key][i],label=labels[sc][i], linewidth=2.0)#,color=color[i] )#, marker=marker[i])
		#plt.fill_between(x, variable[key][i], color=color[i])
	plt.legend()
	if save:
		plt.savefig("../output_epidemic/"+scenario[sc]+"/"+var_labels[key])
	else: plt.show()

def box_plot(key,save):
	plt.clf()
	plt.title(var_labels[key])
	x = [i for i in range(1,len(labels[sc])+1)]
	
	data = [i for i in variable[key]]
	plt.xlabel("Day")
	if(key=="R0"):
		label = "Value"
	else:
		label = "People"
	plt.ylabel(label)
	plt.boxplot(data, notch=True)
	plt.xticks(x,labels[sc])
	#plt.legend()
	if save:
		plt.savefig("../output_epidemic/"+scenario[sc]+"/boxplot_"+var_labels[key])
	else: plt.show()

#Escenario 1: Observación de todas las variables de salida por cada población
def compare_values():
	for var in variable:
		print ("\nMean value of {}:".format(var))
		for i in range(len(labels[sc])):
			print ("{}:{}".format(labels[sc][i],sum(variable[var][i])/len(variable[var][i])))


load_files()
#box_plot("R0",True)
#compare_values()
for value in var_labels:
	plot_scenario(value,True)
	box_plot(value,True)