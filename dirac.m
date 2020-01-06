%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% DirAC implementation based on the book "Parametric Spatial Audio" (chapter 5)
%
% This file is intended to be used with GNU octave and the signal package installed.
% sudo apt-get install octave-signal
%
% Licensed under GNU General Public License v2.0
%
% Missing functions:
% - DirAC_init_stft()
% - DirAC_run_stft()
% - Headphone_ITDILD_simulation()
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

fs = 48000;
siglen = 12 * fs;

% Sawtooth signals with repeated exp-decaying temporal envelope
sig1 = (mod([1:siglen]',200)/200-0.5) .* (10.^((mod([siglen:-1:1]',fs/5)/(fs/10)))-1)/10;
sig2 = (mod([1:siglen]',321)/321-0.5) .* (10.^((mod([siglen:-1:1]',fs/2)/(fs/ 4)))-1)/10;

% Simulate B-format signals for the sources 
azi1 = [1:siglen]' / siglen*3*360;					% changing source azimuth for sig1
ele1 = [1:siglen]' * 0;								% constant elevation for sig1
azi2 = round([1:siglen]' / siglen) * 180 - 90;		% azi for sig2
ele2 = [1:siglen/2 siglen/2:-1:1]' / siglen * 180;	% changing elev for sig2

bw = (sig1+sig2) / sqrt(2);
bx = sig1 .* cos(azi1/180*pi) .* cos(ele1/180) + sig2 .* cos(azi2/180*pi) .* cos(ele2/180*pi); 
by = sig1 .* sin(azi1/180*pi) .* cos(ele1/180) + sig2 .* sin(azi2/180*pi) .* cos(ele2/180*pi);
bz = sig1 .* sin(ele1/180*pi) + sig2 .* sin(ele2/180*pi);

% Add fading in diffuse low-passed noise about evenly in 3D 
[b,a] = butter(1, [500/fs/2]); 

for azi = 0:10:1430									% four azi rotations in 10deg steps, random elevation
    ele = asin(rand*2-1) / pi * 180;
    noise = filter(b, a, 5 * (rand(siglen,1)-0.5)) .* (10.^((([1:siglen]' / siglen)-1)*2));
    bw = bw + noise / sqrt(2);
    bx = bx + noise * cos(azi/180*pi) * cos(ele/180*pi);
    by = by + noise * sin(azi/180*pi) * cos(ele/180*pi);
    bz = bz + noise * sin(ele/180*pi);
end

%% 2D PROCESSING %%%%
% Compose B-format and discard Z-component for 2D processing
bfsig_2D = [bw bx by bz*0];
bfsig_2D = bfsig_2D / max(max(abs(bfsig_2D))) / 3;
bfsig_2D(end-500:end,:) = bfsig_2D(end-500:end, :) .* (linspace(1, 0, 501)' * [1 1 1 1]);

% Define the directions of loudspeakers 
ls_dirs_2D = [-30 0 30 -110 110 -150 150]';			% 7.1 surround

%Initialize DirAC parameters
%DirAC_struct = DirAC_init_stft(ls_dirs_2D, fs);

% DirAC processing
%[LSsig_2D, DIRsig_2D, DIFFsig_2D, DirAC_struct] = DirAC_run_stft(bfsig_2D, DirAC_struct);

% Simple simulation of LS listening with headphones
%HPsig_LIN2D   = Headphone_ITDILD_simulation(LINsig_2D, DirAC_struct);
%HPsig_DirAC2D = Headphone_ITDILD_simulation(LSsig_2D, DirAC_struct);