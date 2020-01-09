# DirAC-Octave
Octave (Matlab) implementation of DirAC (directional audio coding) with a simple simulation for headphones.

siggen.m
This file implements an Ambisonis B-Format signal generator for 2D and 3D spatial audio signals. The audio files consist of four mono channels and contain W, X, Y and Z components. There are two sawtooth signals which alternate in pitch an spatial position. One signal cycles three times in azimuth and has no elevation modulation. The other signal cycles only once and has additional altitude modulation. Both (2D and 3D) files are 12 seconds in duration and also feature diffuse pink noise with rising level to the end of the audiofile. The files are stored as Output2D-B-Format.wav and Output3D-B-Format.wav in the same folder.