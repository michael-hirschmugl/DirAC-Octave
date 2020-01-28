%
% This script depends on the following files:
% - siggen.m (indirectly, see below)
% - getGainTable.m
% - findLsPairs.m
% - invertLsMtx.m
% - vbap.m
% - computeVMICdecMtx.m
% - computeDecorrelators.m
% - makepart_constcut.m
% - interpolateFilterSpec.m
%
% Script "siggen" must be run first to generate "Output2D-B-Format.wav"
% and "Output3D-B-Format.wav".
%
% And the package "signal" (pkg load signal)
%

clc
clear all

pkg load signal

fs = 48000;

% Read 2D Ambi B-Format audio file
[bfsig,fs] = audioread('Output2D-singleSig-B-Format.wav'); 
bw = bfsig(:,1);
bx = bfsig(:,2);
by = bfsig(:,3);
bz = bfsig(:,4);
bfsig = bfsig / max(max(abs(bfsig)))/3;
siglen = size(bfsig,1);
nInChan = 4;





% https://link.springer.com/chapter/10.1007/978-3-030-17207-7_4
% http://neilsloane.com/sphdesigns/dim3/
% http://neilsloane.com/sphdesigns/dim3/des.3.48.9.txt

% Define the directions of loudspeakers from file of 3D coordinates
[ls_dirs(:,1), ls_dirs(:,2)] = rdcartspk('des.3.48.9.txt');
dimension = 3;
nOutChan = length(ls_dirs);
VBAPtable = getGainTable(ls_dirs);

% compute virtual-microphone/ambisonic static decoding matrix
dirCoeff = (sqrt(3)-1)/2;  % supercardioid virtual microphones
decodingMtx = computeVMICdecMtx(ls_dirs, dirCoeff);







% winsize for STFT, with 50% overlap
winsize = 1024;  % about 20ms
hopsize = winsize/2;
fftsize = 2*winsize;
Nhop = ceil(siglen/hopsize) + 2;
% hanning window for analysis synthesis
window = hanning(winsize);
% zero pad both window and input frame to 2*winsize to 
% suppress temporal aliasing from adaptive filters
window = [window; zeros(winsize,1)]; 
window = window*ones(1,nInChan);

parhistory = [];







% smoothing parameters
dirsmooth_cycles = 20;
dirsmooth_limf = 3000;
diffsmooth_cycles = 50;
diffsmooth_limf = 10000;
gainsmooth_cycles = 200;
gainsmooth_limf = 1500;

% DirAC analysis initialization
% initial values for recursive smoothing
Intensity_smooth = 0;
% initial values for recursive smoothing
Intensity_short_smooth = 0;
% initial values for recursive smoothing
energy_smooth = 0;
gains_smooth = 0;

% compute recursive smoothing coefficients for the given above values
freq = (0:winsize/2)' * fs/winsize;
period = 1./freq;
period(1) = period(2);  % omit infinity value for DC

% diffuseness smoothing time constant in sec
tau_diff = period*diffsmooth_cycles;
% diffuseness smoothing recursive coefficient
alpha_diff = exp(-winsize ./ (2*tau_diff*fs));
% limit recursive coefficient
alpha_diff(freq > diffsmooth_limf) = min(alpha_diff(freq <= diffsmooth_limf));

% direction smoothing time constant in sec
tau_dir = period*dirsmooth_cycles;
% diffuseness smoothing recursive coefficient
alpha_dir = exp(-winsize./(2*tau_dir*fs));
% limit recursive coefficient
alpha_dir(freq>dirsmooth_limf) = min(alpha_dir(freq<=dirsmooth_limf));

% gain smoothing time constant in sec
tau_gain = period*gainsmooth_cycles;
% gain smoothing recursive coefficient
alpha_gain = exp(-winsize ./ (2*tau_gain*fs));
% limit recursive coefficient
alpha_gain(freq>gainsmooth_limf) = min(alpha_gain(freq<=gainsmooth_limf));
alpha_gain = alpha_gain * ones(1,nOutChan);






% Inverse directivity factor of vmics
invQ = dirCoeff^2 + (1/3)*(1-dirCoeff)^2;
Q = 1./invQ;   % directivity factor of vmics
% correction factor for energy of diffuse sound
diffCorrection = sqrt(Q) * ones(1,nOutChan);
% Diffuse energy proportion to each loudspeaker.
lsDiffCoeff = sqrt(1/nOutChan) * ones(1,nOutChan);






% zero padding at start and end
insig = [zeros(hopsize,nInChan); bfsig; zeros(Nhop*hopsize - siglen - ...
                                           hopsize,nInChan)];

% arrays for non-diffuse (direct) and diffuse sound output
dirOutsig = zeros(size(bfsig,1) + fftsize, nOutChan);
diffOutsig = zeros(size(bfsig,1) + fftsize, nOutChan);






% STFT runtime loop
for idx = 0:hopsize:(Nhop-2)*hopsize
    % zero pad both window and input frame to 2*winsize for aliasing suppression
    inFramesig = [insig(idx+(1:winsize),:); zeros(winsize,nInChan)]; 
    inFramesig = inFramesig .* window;

    % spectral processing
    inFramespec = fft(inFramesig);
    inFramespec = inFramespec(1:fftsize/2+1,:);

    % save only positive frequency bins
    % Analysis and filter estimation
    % Estimate directional parameters from signal
    %   using only non-interpolated spectrum
    %%% B-format analysis
    W = inFramespec(1:2:end,1); % omni
    V = inFramespec(1:2:end,2:4)/sqrt(2);
    % dipoles /cancel B-format dipole convention
    Intensity = real(conj(W)*ones(1,3) .* V);
    % spatially reversed normalized active intensity
    energy = (abs(W).^2 + sum(abs(V).^2,2))/2;




    % smooth Intensity with alpha_dir for Short Smooth of Intensity
    alpha_dir_1 = alpha_dir;
    Alpha_dir = alpha_dir_1*ones(1,3);
    Intensity_short_smooth_1 = Alpha_dir.*Intensity_short_smooth + (1-Alpha_dir).*Intensity;
    % azi and elev from Short smoothed Intensity
    azi = atan2(Intensity_short_smooth_1(:,2), Intensity_short_smooth_1(:,1))*180/pi;
    elev = atan2(Intensity_short_smooth_1(:,3), sqrt(sum(Intensity_short_smooth_1(:,1:2).^2,2)))*180/pi;
    % update values for recursive smoothing
    Intensity_short_smooth = Intensity_short_smooth_1;




    % smooth intensity with alpha_diff for Norm of smoothed Intensity
    alpha_diff_1 = alpha_diff;
    Alpha_diff = alpha_diff_1*ones(1,3);  
    Intensity_smooth_1 = Alpha_diff.*Intensity_smooth + (1-Alpha_diff).*Intensity;
    % Norm
    Intensity_smooth_norm = sqrt(sum(Intensity_smooth_1.^2,2));

    % smooth energy with alpha_diff
    energy_smooth_1 = alpha_diff_1.*energy_smooth + (1-alpha_diff_1).*energy;

    % Diffuseness = 1 - (Intensity / Energy)
    diffuseness = 1 - Intensity_smooth_norm./(energy_smooth_1 + eps);
    diffuseness(diffuseness<eps) = eps;
    diffuseness(diffuseness>1-eps) = 1-eps;

    % update values for recursive smoothing
    Intensity_smooth = Intensity_smooth_1;
    energy_smooth = energy_smooth_1;




    % store parameters
    pos = size(parhistory,1)+1;
    parhistory(pos,:,:) = [azi elev energy diffuseness];
    % pos is the block index increased by 1 for each spectrum block
    % parhistory(pos,:,1) prints azi for first spectrum block



    % Non-diffuse (direct) and diffuse sound filters
    ndiff_sqrt = sqrt(1-diffuseness); % diffuse sound suppresion filter
    ndiff_energy = energy.*(1-diffuseness); % non-diffuse energy amount ndiff_energy



    % look-up the corresponding VBAP gains from the table
    idx2D = round(mod(azi+180,360))+1;
    gains = VBAPtable(idx2D,:);

    % Amplitude panning gain filters
    Alpha = alpha_gain;
    % recursive smoothing of gains (energy-weighted)
    gains_smooth_1 = Alpha.*gains_smooth + (1-Alpha).*(ndiff_energy * ones(1,nOutChan)).*gains;
    % store smoothed gains for next update (before re-normalization)
    gains_smooth = gains_smooth_1;
    % re-normalization of smoothed gains to unity power
    gains_smooth_1 = gains_smooth_1 .* (sqrt(1./(sum(gains_smooth_1.^2,2)+eps))*ones(1,nOutChan));



    % Combine separation filters with panning filters, including 
    % approximate correction for the effect of virtual microphones 
    % to the direct sound

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SEITE 108 (Ambi Buch)
    dirCorrection = (1./sqrt(1 + diffuseness*(invQ-1)))*ones(1,nOutChan);
    directFilterspec = gains_smooth .* (ndiff_sqrt*ones(1,nOutChan)) .* dirCorrection;

    % Combine separation filters with approximate correction for the
    % effect of virtual microphones to the diffuse sound energy, 
    % and energy weights per loudspeaker
    diffuseFilterspec = sqrt(diffuseness) * (diffCorrection.*lsDiffCoeff);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SEITE 108 (Ambi Buch)

    % Interpolate filters to fftsize
    directFilterspec = interpolateFilterSpec(directFilterspec);
    diffuseFilterspec = interpolateFilterSpec(diffuseFilterspec);

    %%% Synthesis of non-diffuse/diffuse streams
    % apply non-parametric decoding first (virtual microphones)
    linOutFramespec = inFramespec * decodingMtx;

    % adapt the linear decoding to the direct and diffuse streams
    dirOutFramespec = directFilterspec .* linOutFramespec;
    diffOutFramespec = diffuseFilterspec .* linOutFramespec;

    % overlap-add
    dirOutFramesig = real(ifft([dirOutFramespec; ...
                                conj(dirOutFramespec(end-1:-1:2,:))]));
    dirOutsig(idx+(1:fftsize),:) = dirOutsig(idx + (1:fftsize),:) ...
                                                 + dirOutFramesig;
    diffOutFramesig = real(ifft([diffOutFramespec; ...
                           conj(diffOutFramespec(end-1:-1:2,:))]));
    diffOutsig(idx+(1:fftsize),:) = diffOutsig(idx + (1:fftsize),:) + diffOutFramesig;

end

audiowrite(['Output3D-DirAC-Direct.wav'], dirOutsig, fs);
audiowrite(['Output3D-DirAC-Diffuse-correlated.wav'], diffOutsig, fs);
