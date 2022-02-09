import matplotlib.pyplot as plt
import numpy as np
import csv

def plot_file(index,save):

	x = [i for i in range(len(scenarios[index]))]
	labels = ["75% immunity","50% immunity","25% immunity"]
	plt.clf()
	plt.plot(x,scenarios[index],label=labels[index])
	plt.fill_between(x, scenarios[index], color='#539ecd')
	plt.xlabel("Experiement")
	plt.ylabel("Secondary cases")
	plt.title("Evolution of secondary cases through 100 experiments")

	plt.xticks(np.arange(0,len(x),10))
	plt.yticks(np.arange(0,max(list(scenarios[0]+scenarios[1]+scenarios[2]))))
	#plt.yticks(np.arange(len(physical_tokens),0,4))
	plt.legend()
	if(save):
		plt.savefig("output_herd_immunity/R0_"+files[index]+".png")
	else:
		plt.show()

files = [
	"R0_250-750-1",
	"R0_500-500-1",
	"R0_750-250-1"
]
scenarios = [[] for i in range(len(files))]
counter = 0
for file in files:
	with open("output_herd_immunity/results_"+file+".csv") as csv_file:
		csv_reader = csv.reader(csv_file,delimiter=',')
		for row in csv_reader:
			scenarios[counter].append(int(row[0]))
	plot_file(counter,True)
	counter+=1
