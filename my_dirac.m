clc
clear all

pkg load signal

fs = 48000; 
siglen = 12*fs;                                        % length of signal

% Read 2D Ambi B-Format audio file
[bfsig_2D,fs] = audioread('Output2D-B-Format.wav'); 
bw = bfsig_2D(:,1);
bx = bfsig_2D(:,2);
by = bfsig_2D(:,3);
bz = bfsig_2D(:,4);

% Define the directions of loudspeakers
% Problem here is, that I actually don't know where I'd put
% speakers in a 2nd order Ambi setup. That's why I just used the
% 7.1 example setup:
ls_dirs_2D = [-30 0 30 -110 110 -150 150]';

%Initialize DirAC parameters


% DirAC processing
