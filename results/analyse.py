#!/usr/bin/env python3

# A script to analyze and plot the data of the MUSHRA test.
# Manuel Planton 2020

import json
import matplotlib.pyplot as plt
import numpy as np
import glob

f_names = glob.glob("*.json")
experiments = []

for f_name in f_names:
    f = open(f_name, "r")
    data = f.read()
    experiments.append(json.loads(data))



# MUSHRA test data:
# part 0 (sound quality) and  part 1 (room quality)
# 4 scenes/trials per part

# part 0: sound quality
exp_nr = 0
part_nr = 0

print("sound quality results:")
for trial in experiments[exp_nr]["Results"]["Parts"][part_nr]["Trials"]:
    print(trial["Ratings"])
    # TODO: Sind die "Ratings" in der Reihenfolge von "PresentedOrderOfStimuli" oder von 0 bis 6?

# part 1: room quality
exp_nr = 1
part_nr = 1

print("room quality results:")
for trial in experiments[exp_nr]["Results"]["Parts"][part_nr]["Trials"]:
    print(trial["Ratings"])

# TODO: Statistische Verteilung checken -> normalverteilt?
# TODO: Erwartungswert und Varianz berechenn

# just to show how to plot data:
#x = np.array([1, 2, 3, 4, 5])
#y = np.power(x, 2) # Effectively y = x**2
#e = np.array([1.5, 2.6, 3.7, 4.6, 5.5])

#plt.errorbar(x, y, e, linestyle='None', marker='^')

#plt.show()
