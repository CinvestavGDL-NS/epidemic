import matplotlib.pyplot as plt
import numpy as np
import csv
import datetime
import os
import math
import statsmodels.api as sm

days = 60

def process_radar_jalisco_pruebas():
	output_data = []
	with open('../includes/validation_data/positive_cases.csv','r') as csv_file:
		csv_reader = csv.reader(csv_file,delimiter=',')
		for row in csv_reader:
			sum = 0
			if str(row[1]) == "Confirmados":
				for i in range(2,6):
					if row[i] != 'Na':
						tmp = row[i].replace(',','')
						sum = sum + int(tmp)
				current_date = row[0].split('/')
				output_data.append([date(int(current_date[2]),int(current_date[1]),int(current_date[0])),sum])
	data_np = np.array(output_data)[:,1]
	new_output = [[output_data[0][0],data_np[0]]]
	for i in range(1,len(data_np)):
		new_output.append([output_data[i][0],data_np[i]-data_np[i-1]])
	return new_output

def process_radar_jalisco_casos():
	cur_path = os.path.dirname(__file__)
	new_path = os.path.relpath('..\\..\\includes\\validation_data\\positive_cases.csv', cur_path)
	starting_date = datetime.datetime(2020,5,23)
	finish_date = datetime.datetime(2020,7,21)#datetime.datetime(2020,7,21)
	result = []
	
	with open(new_path,'r') as csv_file: 
		csv_reader = csv.reader(csv_file,delimiter=',')
		sum = 0
		result = {starting_date+datetime.timedelta(days=i):[0,0] for i in range(days)}#range(60)}
		for row in csv_reader:
			if str(row[5]) == "9" and str(row[4])== "CONFIRMADO":
				sum = sum + 1
				date_string = row[0].split('/')
				current_date = datetime.datetime(int(date_string[2]),int(date_string[1]),int(date_string[0]))
				if current_date >= starting_date and current_date <= finish_date:
					result[current_date][0] += 1
					result[current_date][1] += sum
	sum = 0
	dates = [starting_date+datetime.timedelta(days=i) for i in range(days)]
	output = []
	for the_date in dates:
		sum += result[the_date][0]
		result[the_date][1] = sum
		output.append([the_date,result[the_date][0],result[the_date][1]])
	return output

def process_radar_jalisco_hospitalized():
	cur_path = os.path.dirname(__file__)
	new_path = os.path.relpath('..\\..\\includes\\validation_data\\positive_cases.csv', cur_path)
	starting_date = datetime.datetime(2020,5,23)
	finish_date = datetime.datetime(2020,7,21)#datetime.datetime(2020,7,21)
	result = []
	
	with open(new_path,'r') as csv_file: 
		csv_reader = csv.reader(csv_file,delimiter=',')
		sum = 0
		result = {starting_date+datetime.timedelta(days=i):[0,0] for i in range(days)}#range(120)}
		for row in csv_reader:
			if str(row[5]) == "9" and str(row[4])== "CONFIRMADO" and str(row[3]) == "HOSPITALIZADO":
				sum = sum + 1
				date_string = row[0].split('/')
				current_date = datetime.datetime(int(date_string[2]),int(date_string[1]),int(date_string[0]))
				if current_date >= starting_date and current_date <= finish_date:
					result[current_date][0] += 1
					result[current_date][1] += sum
	sum = 0
	dates = [starting_date+datetime.timedelta(days=i) for i in range(days)]
	output = []
	for the_date in dates:
		sum += result[the_date][0]
		result[the_date][1] = sum
		output.append([the_date,result[the_date][0],result[the_date][1]])
	return output

def load_data_from_file(file,key):
	variable = {  "nb_susceptible"				: [],
				  "nb_exposed"					: [],
				  "nb_infectious_symtomatic" 	: [],
				  "nb_infectious_asymtomatic" 	: [],
				  "nb_recovered"				: [],
				  "nb_immune"					: [],
				  "nb_Qs"						: [],
				  "nb_Qa"						: [],
				  "nb_H"						: [],
				  "nb_D"						: [],
				  "nb_mask"						: [],
				  "nb_hand_wash"				: [],
				  "nb_social_distance"			: [],
				  "R0"							: [],
				  "cases_today"					: [],
				  "total_cases"					: [],
				  "semaphore"					: [],
				  "hospitalized_today"			: [],
				  "tot_hosp"					: [],
				  "deaths_today"				: [],
				  "tot_deaths"					: []
				}
	with open('../output_epidemic/Scenario3/'+file+'.csv') as csv_file:
		csv_reader = csv.reader(csv_file,delimiter=',')
		first = True
		for row in csv_reader:
			if first:
				first = False
			else:
				variable["nb_susceptible"].append(int(row[3]))
				variable["nb_exposed"].append(int(row[4]))
				variable["nb_infectious_symtomatic"].append(int(row[5]))
				variable["nb_infectious_asymtomatic"].append(int(row[6]))
				variable["nb_recovered"].append(int(row[7]))
				variable["nb_immune"].append(int(row[8]))
				variable["nb_Qs"].append(int(row[9]))
				variable["nb_Qa"].append(int(row[10]))
				variable["nb_H"].append(int(row[11]))
				variable["nb_D"].append(int(row[12]))
				variable["nb_mask"].append(int(row[13]))
				variable["nb_hand_wash"].append(int(row[14]))
				variable["nb_social_distance"].append(int(row[15]))
				variable["R0"].append(float(row[16]))
				variable["cases_today"].append(int(row[17]))
				variable["total_cases"].append(int(row[18]))
				variable["semaphore"].append(float(row[19]))
				variable["hospitalized_today"].append(float(row[20]))
				variable["tot_hosp"].append(float(row[21]))
				variable["deaths_today"].append(float(row[22]))
				variable["tot_deaths"].append(float(row[22]))

	return variable[key]

def process_simulation_data(files,key):
	print("**********   PROCESSING SIMULATION DATA OF: {}  *************".format(key))
	data = {}
	output = {f:[] for f in files}
	starting_date = datetime.datetime(2020,5,23)
	dates = [starting_date+datetime.timedelta(days=i) for i in range(days)]
	for file in files:
		data[file] = load_data_from_file(file,key)
		print("\n\tsimulation ({}):".format(file))
		print (data[file])
		sum = 0
		for i in range(len(dates)):
			sum += data[file][i]
			output[file].append([dates[i],data[file][i],sum])
	return output

def getDates(data1,data2):
	tmp1 = data1[0][0]
	tmp2 = data2[0][0]
	
	initial_1 = tmp1
	initial_2 = tmp2
	latest_initial = initial_1
	if initial_2>initial_1:
		latest_initial = initial_2

	tmp1 = data1[-1][0]
	tmp2 = data2[-1][0]

	final_1 = tmp1
	final_2 = tmp2
	earliest_final = final_1
	if final_2<final_1:
		earliest_final = final_2

	return latest_initial,earliest_final

def filterDataByDateRange(d1,d2,first,last):
	data1 = np.array(d1)
	data2 = np.array(d2)
	i1 = np.where(data1[:,0] == first)
	i2 = np.where(data1[:,0] == last)
	data1 = data1[i1[0][0]:i2[0][0]+1]
	i1 = np.where(data2[:,0] == first)
	i2 = np.where(data2[:,0] == last)
	data2 = data2[i1[0][0]:i2[0][0]+1]
	return data1, data2

def plotData(data1, data2):
	d = np.array(data)
	x = d[:,0]
	plt.clf()
	plt.title("Real Positive Tests vs Simulated Infected Cases")
	plt.xlabel("Day")
	plt.ylabel("Cases")
	plt.plot(x,d[:,1],label="Real", linewidth=2.0)
	plt.plot(x,data2[:,1],label="Simulated", linewidth=2.0)
	plt.legend()
	plt.show()

def plotData2(data):
	d = np.array(data)
	x = d[:,0]
	plt.clf()
	plt.title("Daily cases")
	plt.xlabel("day")
	plt.ylabel("Cases")
	plt.plot(x,d[:,1],label="Real", linewidth=2.0)
	plt.legend()
	plt.show()

def plotSeveralData(data,labels,title,xlabel,ylabel,save):
	plt.clf()
	plt.title(title)
	plt.xlabel(xlabel)
	plt.ylabel(ylabel)
	x = [i for i in range(1,len(data[0])+1)]
	tmp_data = np.array(data[0])
	serie = tmp_data[:,0]
	number2name = {5:"may",6:"jun",7:"jul"}
	#ax = plt.gca()
	#ax.set_xlim((np.datetime64('2020-05-23'), np.datetime64('2020-07-21')))
	#tmp_labels = [number2name[i.month]+"/"+str(i.day) for i in serie]
	plt.xticks(np.arange(0,len(x)+1,10), fontsize='8', horizontalalignment='right')
	for i in range(len(data)):
		the_data = np.array(data[i])
		if i == 0:
			plt.plot(x,the_data[:,2],'^',label=labels[i])
		else: 
			plt.plot(x,the_data[:,2],color='darkgray',label=labels[i] if i == 1 else "")
		plt.legend()
	if save:
		plt.savefig("../output_epidemic/Scenario3/Comparison_"+title.replace(" ","_"),dpi=600,bbox_inches='tight')
	else: plt.show()

def bland_altman_plot(data1, data2, *args, **kwargs):
	data1     = np.array(data1)
	data2     = np.array(data2)
	f, ax = plt.subplots(1, figsize = (8,5))
	sm.graphics.mean_diff_plot(data1, data2, ax = ax)
	plt.show()
	
	"""print(str(len(data1)),", ",str(len(data2)))
	data1     = np.array(data1)
	data2     = np.array(data2)
	mean      = np.mean([data1, data2], axis=0)
	diff      = data1 - data2                   # Difference between data1 and data2
	md        = np.mean(diff)                   # Mean of the difference
	sd        = np.std(diff, axis=0)            # Standard deviation of the difference
	print(str(len(mean)),", ",str(len(diff)))
	plt.scatter(mean, diff, *args, **kwargs)
	plt.axhline(md,           color='gray', linestyle='--')
	plt.axhline(md + 1.96*sd, color='gray', linestyle='--')
	plt.axhline(md - 1.96*sd, color='gray', linestyle='--')
	plt.title('Bland-Altman Plot')
	plt.show()
"""
def compute_RMSE(d1,d2):
	sum = 0
	for i in range(len(d1)):
		sum = sum + math.pow((d1[i]-d2[i]),2)
	sum = sum / len(d1)
	result = math.sqrt(sum)
	return result


files = ["El_Arenal_collectivist_"+str(i) for i in range(10)]

real_cases_data = process_radar_jalisco_casos()
real_hospitalized = process_radar_jalisco_hospitalized()
simulated_data 	= process_simulation_data(files,"hospitalized_today")
data = [real_cases_data]

simulated_avg = [0 for x in range(len(real_cases_data))] 
for i in range(len(real_cases_data)):
	sum = 0
	for key in files:
		tmp_data = simulated_data[key]
		sum = sum + tmp_data[i][2]	
	simulated_avg[i] = sum / len(files)
print ("Average dataset:\n")
for i in simulated_avg:
	print ("{} ".format(str(i) for i in simulated_avg))
tmp = np.array(real_hospitalized)
print(compute_RMSE(tmp[:,2],simulated_avg))
bland_altman_plot(tmp[:,2],simulated_avg)

"""
labels = ["Real data"]
for key in files:
	data.append(simulated_data[key])
	labels.append("Simulated")
plotSeveralData(data,labels,"Total cases","Day","Cases",True)
data = [real_hospitalized]
labels = ["Real data"]
simulated_data 	= process_simulation_data(files,"hospitalized_today")
for key in files:
	data.append(simulated_data[key])
	labels.append("Simulated")
plotSeveralData(data,labels,"Hospitalized","Day","People",True)"""
#sim_output = load_files()
#date_range = getDates(sim_output,real_output)
#real_data, simulated_data = filterDataByDateRange(real_output,sim_output,date_range[0],date_range[1])
#plotData(real_data,simulated_data)

#print(len(sim_output))
#print(sim_output)
#plotData(real_cases_data,sim_output)