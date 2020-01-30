
clc
clear all

pkg load signal

%% The main DirAC script 
%% Archontis Politis and Ville Pulkki 2016

fs=48000; 
siglen=12*fs; % length of signal

[bfsig,fs] = audioread('Output3D-B-Format.wav'); 

[ls_dirs(:,1), ls_dirs(:,2)] = rdcartspk('des.3.48.9.txt');
%Initialize DirAC parameters
DirAC_struct = DirAC_init_stft(ls_dirs, fs);

% DirAC processing + write loudspeaker signals to disk
[DIRsig, DIFFsig, DirAC_struct] = DirAC_run_stft(bfsig, DirAC_struct);
audiowrite(['Output3D-DirAC-direct.wav'],DIRsig,fs);
audiowrite(['Output3D-DirAC-diffuse.wav'],DIFFsig,fs);

    
