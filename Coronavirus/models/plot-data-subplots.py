import matplotlib.pyplot as plt
import numpy as np
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
with open('output.csv') as csv_file:
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

fig, axs = plt.subplots(3, 1)

axs[0].plot(nb_susceptible,'y',label='Susceptible')
axs[0].plot(nb_exposed,'orange',label='Exposed')
axs[0].plot(nb_infectious_symtomatic,'red',label='Infectious symptomatic')
axs[0].plot(nb_infectious_asymtomatic,'m',label='Infectious asymptomatic')
axs[0].plot(nb_D,'lawngreen',label='Immune')
axs[0].plot(nb_immune,'fuchsia',label='Dead')
axs[0].legend()
axs[0].set_title('Epidemiologic states')



axs[1].plot(nb_Qs,'brown',label="Qs")
axs[1].plot(nb_Qa,'blueviolet',label='Qa')
axs[1].plot(nb_H,'skyblue',label='H')
axs[1].legend()
axs[1].set_title('Behavioral states')


axs[2].plot(nb_mask, 'blue',label="wear mask")
axs[2].plot(nb_hand_wash, 'maroon',label="hand wash")
axs[2].plot(nb_social_distance, 'green',label="social distance")
axs[2].legend()
axs[2].set_title('Cultural behavior')
#axs[2].axis([0,180,0,10])


for ax in axs.flat:
    ax.set(xlabel='days', ylabel='people')

# Hide x labels and tick labels for top plots and y ticks for right plots.
for ax in axs.flat:
    ax.label_outer()

plt.show()