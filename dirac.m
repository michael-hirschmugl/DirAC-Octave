
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
%ls_dirs(:,1) = [30 -30 0 135 -135 90 -90 45 -45 135 -135  0]';
%ls_dirs(:,2) = [ 0   0 0   0    0  0   0 45  45  45   45 90]';
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

%noSubDIRsig(:,1:3) = DIRsig(:,1:3);
%noSubDIRsig(:,4) = zeros(length(DIRsig(:,1)),1);
%noSubDIRsig(:,5:13) = DIRsig(:,4:12);

%noSubDIFFsig(:,1:3) = DIFFsig(:,1:3);
%noSubDIFFsig(:,4) = zeros(length(DIFFsig(:,1)),1);
%noSubDIFFsig(:,5:13) = DIFFsig(:,4:12);

%noSubtempsig(:,1:3) = tempsig(:,1:3);
%noSubtempsig(:,4) = zeros(length(tempsig(:,1)),1);
%noSubtempsig(:,5:13) = tempsig(:,4:12);

%audiowrite(['Output3D-DirAC-direct.wav'],noSubDIRsig,fs);
%audiowrite(['Output3D-DirAC-diffuse.wav'],noSubDIFFsig,fs);
%audiowrite(['Output3D-DirAC-diffuse-decorr.wav'],noSubtempsig,fs); 

    
audiowrite(['Output3D-DirAC-direct.wav'],DIRsig,fs);
audiowrite(['Output3D-DirAC-diffuse.wav'],DIFFsig,fs);
audiowrite(['Output3D-DirAC-diffuse-decorr.wav'],tempsig,fs); 