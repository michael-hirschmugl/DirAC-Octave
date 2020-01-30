# DirAC-Octave
Octave (Matlab) implementation of DirAC (directional audio coding).

### dirac.m
Main script file. Reads B-format ambisonics file
"Output3D-B-Format.wav" and seperates it into direct and diffuse
components which are written to .wav files as well. The diffuse component is not
decorrelated and the generated files have 48 channels. The channels are specified
as virtual sound sources in the file des.3.48.9.txt. This file is actually a
T-design (9-design) that resembles an ideal speaker arrangement for 4th order
ambisonics. The file is read with the function rdcartspk.m which also converts
the cartesian coordinates that specify the speaker positions into spherical
coordinates (angles for elevation and azimuth).

### siggen.m
Generates 4-channel B-format ambisonics audio files "Output3D-B-Format.wav" (2 sounds; 3D rotation + diffuse noise).


