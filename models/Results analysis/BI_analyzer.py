import matplotlib.pyplot as plt
import numpy as np
import csv

sc = 1
"""
files = [
			 "100-0-10-updatebeliefs-nointervention-usa",
			 "100-0-10-updatebeliefs-nointervention-mex"]
labels = [
		  "Population with USA parameters",
		  "Population with MEX parameters"]"""

color = ['red','black','green']

files = {
			1:["test"]
		}
labels = {	1:[str("$\\delta$ = {}".format(i/10)) for i in range(0,11)]

		}


scenario = {1:"BI"}

var_labels = {"belief" : "Intention value"}
variable = { 	  "belief"				: [[] for i in range(0,11)]}

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
				for i in range(0,len(row[2:])):
					"""print("\n")
					print("columns: {}".format(len(row[2:])))
					print("i: {}\n".format(i))"""
					variable["belief"][i].append(float(row[i+2]))


def plot_scenario(key,save):
	x = [i/180 for i in range(0,len(variable[key][0]))]

	plt.clf()
	plt.title(var_labels[key])
	plt.xlabel("External incoming information ($\\epsilon$)")
	plt.ylabel("Intention value (" +u'$\\beta$'+")")
	plt.xticks(np.arange(0,max(x)+1,0.1))
	for i in range(0,len(variable[key])):
		if(i ==5 or i == 10):

			plt.plot(x,variable[key][i],label=labels[sc][i], linewidth=2.0)#,color=color[i] )#, marker=marker[i])
		#plt.fill_between(x, variable[key][i], color=color[i])
	plt.legend()
	if save:
		plt.savefig("../output_epidemic/"+scenario[sc]+"/"+var_labels[key])
	else: plt.show()

#Escenario 1: Observación de todas las variables de salida por cada población
def compare_values():
	for var in variable:
		print ("\nMean value of {}:".format(var))
		for i in range(len(labels[sc])):
			print ("{}:{}".format(labels[sc][i],sum(variable[var][i])/len(variable[var][i])))


load_files()
#compare_values()
for value in var_labels:
	plot_scenario(value,True)