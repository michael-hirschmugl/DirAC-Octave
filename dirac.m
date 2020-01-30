
clc
clear all

pkg load signal

%% The main DirAC script 
%% Archontis Politis and Ville Pulkki 2016

fs=48000; 

[bfsig,fs] = audioread('Output3D-B-Format.wav'); 
siglen = size(bfsig,1);

[ls_dirs(:,1), ls_dirs(:,2)] = rdcartspk('des.3.48.9.txt');
%Initialize DirAC parameters
DirAC_struct = DirAC_init_stft(ls_dirs, fs);

% DirAC processing + write loudspeaker signals to disk
[dirOutsig, diffOutsig, DirAC_struct] = DirAC_run_stft(bfsig, DirAC_struct);

% Decorrelation with random phase
tempsig = [diffOutsig; zeros(DirAC_struct.decorDelay, DirAC_struct.nOutChan)];
for n = 1:1:DirAC_struct.nOutChan
    tempsig(:,n) = fftfilt(DirAC_struct.decorFilt(:,n), tempsig(:,n));
end
tempsig = tempsig(DirAC_struct.decorDelay+1:end,:);

% remove delay due to windowing and truncate output to original length
DIRsig = dirOutsig(DirAC_struct.hopsize+(1:siglen),:);
DIFFsig = diffOutsig(DirAC_struct.hopsize+(1:siglen),:);
tempsig = tempsig(DirAC_struct.hopsize+(1:siglen),:); 


audiowrite(['Output3D-DirAC-direct.wav'],DIRsig,fs);
audiowrite(['Output3D-DirAC-diffuse.wav'],DIFFsig,fs);
audiowrite(['Output3D-DirAC-diffuse-decorr.wav'],tempsig,fs); 

    
