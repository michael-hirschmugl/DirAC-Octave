#!/usr/bin/env python3

import json

# Parameters:

# loudspeaker layout file in format: azimut, elevation (in degrees)
file_name_ls_layout = "ls_dirs.txt"
# name of config and config file
name = "9-design"

description = "An ideal 9-design loudspeaker layout"

# ------------------------------------------------------------------------------

f = open(file_name_ls_layout, 'r')
ls_dirs = f.read().split('\n')
f.close()

config = "{\n"
config += 2*' ' + '"Name": "' + name + '",\n'
config += 2*' ' + '"Description": "This file was created with a custom script",\n'

config += 2*' ' + '"LoudspeakerLayout": {\n'

# ls dirs format is azimut, elevation
config += 4*' ' + '"Name": "' + name + '",\n'
config += 4*' ' + '"Description": "' + description + '",\n'
config += 4*' ' + '"Loudspeakers": [\n'

channel_nr = 1
for direction in ls_dirs:
    split = direction.split(",")
    if len(split) != 2:
        break 
    azi, ele = split
    
    config += 6*' ' + "{\n"
    config += 8*' ' + '"Azimuth": ' + azi + ',\n'
    config += 8*' ' + '"Elevation": ' + ele + ',\n'
    # dummy values for MultiEncoder
    config += 8*' ' + '"Radius": 1.00000000000000000000,\n'
    config += 8*' ' + '"IsImaginary": false,\n'
    # channel
    config += 8*' ' + '"Channel": ' + str(channel_nr) + ',\n'
    config += 8*' ' + '"Gain": 0.00000000000000000000\n'
    
    config += 6*' ' + "}"
    if channel_nr != len(ls_dirs):
        config += ",\n"
    else:
        config += "\n"
    channel_nr += 1

config += 4*' ' + "]\n" # Loudspeakers
config += 2*' ' + "}\n" # LoudspeakerLayout
config += "}\n" # file

f_config = open(name + ".json", "w")
f_config.write(config)
f_config.close()
