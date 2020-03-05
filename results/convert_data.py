#!/usr/bin/env python3

# A script to convert the data of the MUSHRA test into a table for analysis.
# Manuel Planton 2020

import json
import glob

f_names = glob.glob("*.json")
experiments = []

# test data
for f_name in f_names:
    f = open(f_name, "r")
    data = f.read()
    experiments.append(json.loads(data))
f.close()

# data is ordered by number of algorithm (0 to 6)
algorithms = ["Spkr_Octave_Decorr",
              "Spkr_FDN",
              "T-design_FDN",
              "T-design_Widening",
              "Harpy",
              "Compass",
              "FOA_Referenz"]

head = ""
for algorithm in algorithms:
    head += "   " + algorithm
head += "   scene   participant\n"
head_lst = head.split()


# MUSHRA test data:
# part 0 (sound quality) and  part 1 (room quality)
# 4 scenes/trials per part

# part 0: sound quality

participant_nr = 1
part_nr = 0

s = head
for experiment in experiments:
    scene_nr = 1
    for scene in experiment["Results"]["Parts"][part_nr]["Trials"]:
        ratings = scene["Ratings"]
        for i in range(len(ratings)):
            s += repr(ratings[i]).rjust(len(head_lst[i])+3)
        s += repr(scene_nr).rjust(len("scene")+3)
        scene_nr += 1
        s += repr(participant_nr).rjust(len(head_lst[-1])+3) + '\n'
    participant_nr += 1

# output file
f_sound = open("dirac_sound_quality.txt", "w")
f_sound.write(s)
f_sound.close()
    

# part 1: room quality

participant_nr = 1
part_nr = 1

s = head
for experiment in experiments:
    scene_nr = 1
    for scene in experiment["Results"]["Parts"][part_nr]["Trials"]:
        ratings = scene["Ratings"]
        for i in range(len(ratings)):
            s += repr(ratings[i]).rjust(len(head_lst[i])+3)
        s += repr(scene_nr).rjust(len("scene")+3)
        scene_nr += 1
        s += repr(participant_nr).rjust(len(head_lst[-1])+3) + '\n'
    participant_nr += 1

# output file
f_room = open("dirac_room_quality.txt", "w")
f_room.write(s)
f_room.close()
