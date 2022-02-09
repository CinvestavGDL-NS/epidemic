import matplotlib.pyplot as plt
import csv
x = []
nb_susceptible = []
nb_exposed = []
nb_infectious_symtomatic = []
nb_infectious_asymtomatic = []
nb_recovered = []
nb_immune = []
nb_Qs = []
nb_Qa = []
nb_H = []
nb_D = []
nb_mask = []
nb_hand_wash = []
nb_social_distance = []
with open('12310400_400.csv') as csv_file:
	csv_reader = csv.reader(csv_file,delimiter=',')
	line_count = 0
	for row in csv_reader:
		if line_count > 0:
			x.append(row[0])
			nb_susceptible.append(int(row[3]))
			nb_exposed.append(int(row[4]))
			nb_infectious_symtomatic.append(int(row[5]))
			nb_infectious_asymtomatic.append(int(row[6]))
			nb_recovered.append(int(row[7]))
			nb_immune.append(int(row[8]))
			nb_Qs.append(int(row[9]))
			nb_Qa.append(int(row[10]))
			nb_H.append(int(row[11]))
			nb_D.append(int(row[12]))
			nb_mask.append(int(row[13]))
			nb_hand_wash.append(int(row[14]))
			nb_social_distance.append(int(row[15]))
		line_count+=1
print(x)
plt.plot(nb_susceptible,'y',label='Susceptible')
plt.plot(nb_exposed,'orange',label='Exposed')
plt.plot(nb_infectious_symtomatic,'red',label='Infectious symptomatic')
plt.plot(nb_infectious_asymtomatic,'m',label='Infectious asymptomatic')
plt.plot(nb_recovered,'lawngreen',label='Recovered')
plt.plot(nb_immune,'black',label='Immune')
plt.plot(nb_Qs,'brown',label='Qs')
plt.plot(nb_Qa,'blueviolet',label='Qa')
plt.plot(nb_H,'skyblue',label='H')
plt.axis([0,180,0,1500])
plt.xlabel('Days')
plt.ylabel('People')
plt.show()