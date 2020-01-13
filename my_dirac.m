clc
clear all

pkg load signal

fs = 48000; 
siglen = 12*fs;                                        % length of signal

% Read 2D Ambi B-Format audio file
[insig_2D,fs] = audioread('Output2D-B-Format.wav'); 
bw = insig_2D(:,1);
bx = insig_2D(:,2);
by = insig_2D(:,3);
bz = insig_2D(:,4);
lInsig = size(insig_2D,1);

% Define the directions of loudspeakers
% Problem here is, that I actually don't know where I'd put
% speakers in a 2nd order Ambi setup. That's why I just used the
% 7.1 example setup:
ls_dirs_2D = [-30 0 30 -110 110 -150 150]';



%Initialize DirAC parameters
DirAC_struct = DirAC_init_stft(ls_dirs_2D, fs);

% 4 channels for B-format
nInChan = 4;

% output channels
% amount of speakers
% 7, in this case
nOutChan = 4;

% STFT frame count and initialization
% about 20ms
% winsize for STFT, with 50% overlap
winsize = 1024;
hopsize = 512;

% double the window size to suppress aliasing
fftsize = 2048;

% Amount of overlapping frames
% rounded up with ceil()
Nhop = ceil(lInsig/hopsize);

% zero padding at start and end
% Nhop + 2 for complete length because of additional 0 padded frames
insig_2D = [zeros(hopsize,nInChan); ...
	        insig_2D; ...
            zeros((Nhop+2)*hopsize - lInsig - hopsize,nInChan)];

% arrays for non-diffuse (direct) output
dirOutsig = zeros(size(insig_2D,1) + fftsize, nOutChan);

% hanning window for analysis synthesis
window = hanning(winsize);

% zero pad both window and input frame to 2*winsize to 
% suppress temporal aliasing from filters
window = [window; zeros(winsize,1)]; 
window = window*ones(1,nInChan);



% STFT runtime loop
for idx = 0:hopsize:(Nhop)*hopsize
    % zero pad both window and input frame to 2*winsize for aliasing suppression
    inFramesig = [insig_2D(idx+(1:winsize),:); zeros(winsize,nInChan)]; 

    inFramesig = inFramesig .* window;

    % spectral processing
    inFramespec = fft(inFramesig);
    inFramespec = inFramespec(1:fftsize/2+1,:);



    dirOutFramespec = inFramespec;



    % overlap-add
    dirOutFramesig = real(ifft([dirOutFramespec; ...
                                conj(dirOutFramespec(end-1:-1:2,:))]));   % ???
    dirOutsig(idx+(1:fftsize),:) = dirOutsig(idx + (1:fftsize),:) ...
                                                 + dirOutFramesig;
end



% remove delay
dirOutsig = dirOutsig(hopsize + 1:end,:);

DIRsig = dirOutsig(hopsize + (1:lInsig),:);

audiowrite(['Output2D-B-Format_after_STFT.wav'], DIRsig, fs);