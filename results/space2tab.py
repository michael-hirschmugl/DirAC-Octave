#!/usr/bin/env python3

# Manuel Planton 2020

# convert data delimiters from spaces to tabs

f_names = ["dirac_room_quality.txt", "dirac_sound_quality.txt"]

for f_name in f_names:
    f = open(f_name, "r")
    data = f.read()
    f.close()
    new_str = ""
    for line in data.split('\n'):
        new_str += '\t'.join(line.split()) + '\n'
    
    f_name_lst = f_name.split('.')
    new_f_name = f_name_lst[0] + "_tab." + f_name_lst[1]
    new_f = open(new_f_name, "w")
    new_f.write(new_str)
    new_f.close()
