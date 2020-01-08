function DirAC_struct = DirAC_init_stft(ls_dirs, fs)
% Return different processing parameters for DirAC processing
% Archontis Politis and Ville Pulkki 2016
%
% ls_dirs ... array of speaker directions
% fs ........ sample rate (must be 44.1 or 48 kHz)

if fs == 44100 | fs == 48000
    DirAC_struct.fs = fs; % Sample rate
else
    disp('Sample rate has to be 44.1 or 48 kHz');
    return
end

DirAC_struct.ls_dirs = ls_dirs;
% 2D/3D test
if min(size(ls_dirs))==1 || all(ls_dirs(:,2)==0)
    DirAC_struct.dimension = 2;
else
    DirAC_struct.dimension = 3;
end
nOutChan = length(ls_dirs);                         % Amount of speakers
DirAC_struct.nOutChan = nOutChan;

% compute VBAP gain table
% Function by Archontis Politis
% return = (Ndirs x Nspeaker) gain matrix
DirAC_struct.VBAPtable = getGainTable(ls_dirs);

% compute virtual-microphone/ambisonic static decoding matrix
dirCoeff = (sqrt(3)-1)/2;                           % supercardioid virtual microphones
DirAC_struct.decodingMtx = computeVMICdecMtx(ls_dirs, dirCoeff);

% load/design decorrelating filters
% designs FIR filters for decorrelation
%This script creates decorrelation filters that have randomly
% delayed impulses at different frequency bands.
[DirAC_struct.decorFilt, DirAC_struct.decorDelay] = computeDecorrelators(nOutChan, fs);

% winsize for STFT, with 50% overlap
DirAC_struct.winsize = 1024;                        % about 20ms

% smoothing parameters
DirAC_struct.dirsmooth_cycles = 20;
DirAC_struct.dirsmooth_limf = 3000;
DirAC_struct.diffsmooth_cycles = 50;
DirAC_struct.diffsmooth_limf = 10000;
DirAC_struct.gainsmooth_cycles = 200;
DirAC_struct.gainsmooth_limf = 1500;

% compute recursive smoothing coefficients for the given above values
freq = (0:DirAC_struct.winsize/2)' * fs/DirAC_struct.winsize;
period = 1./freq;
period(1) = period(2);                              % omit infinity value for DC

% diffuseness smoothing time constant in sec
tau_diff = period*DirAC_struct.diffsmooth_cycles;

% diffuseness smoothing recursive coefficient
alpha_diff = exp(-DirAC_struct.winsize ./ (2*tau_diff*fs));

% limit recursive coefficient
alpha_diff(freq>DirAC_struct.diffsmooth_limf) = min(alpha_diff(freq<=DirAC_struct.diffsmooth_limf));
DirAC_struct.alpha_diff = alpha_diff;

% direction smoothing time constant in sec
tau_dir = period*DirAC_struct.dirsmooth_cycles;

% diffuseness smoothing recursive coefficient
alpha_dir = exp(-DirAC_struct.winsize./(2*tau_dir*fs));

% limit recursive coefficient
alpha_dir(freq>DirAC_struct.dirsmooth_limf) = min(alpha_dir(freq<=DirAC_struct.dirsmooth_limf));
DirAC_struct.alpha_dir = alpha_dir;

% gain smoothing time constant in sec
tau_gain = period*DirAC_struct.gainsmooth_cycles;

% gain smoothing recursive coefficient
alpha_gain = exp(-DirAC_struct.winsize ./ (2*tau_gain*fs));

% limit recursive coefficient
alpha_gain(freq>DirAC_struct.gainsmooth_limf) = min(alpha_gain(freq<=DirAC_struct.gainsmooth_limf));
DirAC_struct.alpha_gain = alpha_gain * ones(1,nOutChan);

% Inverse directivity factor of vmics
DirAC_struct.invQ = dirCoeff^2 + (1/3)*(1-dirCoeff)^2;
Q = 1./DirAC_struct.invQ;                           % directivity factor of vmics

% correction factor for energy of diffuse sound
DirAC_struct.diffCorrection = sqrt(Q) * ones(1,nOutChan);

% Diffuse energy proportion to each loudspeaker.
DirAC_struct.lsDiffCoeff = sqrt(1/nOutChan) * ones(1,nOutChan);
DirAC_struct.parhistory = [];
end