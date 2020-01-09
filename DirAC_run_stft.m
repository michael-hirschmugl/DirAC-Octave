function [LSsig, DIRsig, DIFFsig, DirAC_struct] = DirAC_run_stft(insig, DirAC_struct)
%% Run-time processing of 2D or 3D virtual-microphone STFT DirAC 
%% for loudspeaker output
%% Archontis Politis and Ville Pulkki  2016

lInsig = size(insig,1); % signal length
nInChan = size(insig,2); % normally 4 for B-format
nOutChan = DirAC_struct.nOutChan;

% STFT frame count and initialization
winsize = DirAC_struct.winsize;
hopsize = winsize/2;
fftsize = 2*winsize; % double the window size to suppress aliasing
Nhop = ceil(lInsig/hopsize) + 2;
insig = [zeros(hopsize,nInChan); insig; zeros(Nhop*hopsize - lInsig - hopsize,nInChan)]; % zero padding at start and end
% arrays for non-diffuse (direct) and diffuse sound output
dirOutsig = zeros(size(insig,1)+fftsize, nOutChan);
diffOutsig = zeros(size(insig,1)+fftsize, nOutChan);
% hanning window for analysis synthesis
window = hanning(winsize);
% zero pad both window and input frame to 2*winsize to 
% suppress temporal aliasing from adaptive filters
window = [window; zeros(winsize,1)]; 
window = window*ones(1,nInChan);
% DirAC analysis initialization
DirAC_struct.Intensity_smooth = 0; % initial values for recursive smoothing
DirAC_struct.Intensity_short_smooth = 0; % initial values for recursive smoothing
DirAC_struct.energy_smooth = 0; % initial values for recursive smoothing
DirAC_struct.gains_smooth = 0;

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
    [pars,DirAC_struct] = computeDirectionalParameters(inFramespec(1:2:end,:), DirAC_struct);   
    pos=size(DirAC_struct.parhistory,1)+1;
    DirAC_struct.parhistory(pos,:,:)=[pars];
    % Non-diffuse (direct) and diffuse sound filters
    directFilterspec = updateDirectFilters(pars, DirAC_struct); 
    diffuseFilterspec = updateDiffuseFilters(pars, DirAC_struct); 
    % Interpolate filters to fftsize
    directFilterspec = interpolateFilterSpec(directFilterspec); 
    diffuseFilterspec = interpolateFilterSpec(diffuseFilterspec); 
    %%% Synthesis of non-diffuse/diffuse streams
    % apply non-parametric decoding first (virtual microphones)
    linOutFramespec = inFramespec*DirAC_struct.decodingMtx;
    % adapt the linear decoding to the direct and diffuse streams
    dirOutFramespec = directFilterspec .* linOutFramespec;
    diffOutFramespec = diffuseFilterspec .* linOutFramespec;
    % overlap-add
    dirOutFramesig = real(ifft([dirOutFramespec; conj(dirOutFramespec(end-1:-1:2,:))]));
    dirOutsig(idx+(1:fftsize),:) = dirOutsig(idx+(1:fftsize),:) + dirOutFramesig;
    diffOutFramesig = real(ifft([diffOutFramespec; conj(diffOutFramespec(end-1:-1:2,:))]));
    diffOutsig(idx+(1:fftsize),:) = diffOutsig(idx+(1:fftsize),:) + diffOutFramesig;
end
% remove delay caused by the intepolation of gains and circular shift
dirOutsig = dirOutsig(hopsize+1:end,:);
diffOutsig = diffOutsig(hopsize+1:end,:);
% apply decorrelation to diffuse stream and remove decorrelation 
% delay if needed
if ~isempty(DirAC_struct.decorDelay) || DirAC_struct.decorDelay~=0
    tempsig = [diffOutsig; zeros(DirAC_struct.decorDelay, nOutChan)];
    tempsig = fftfilt(DirAC_struct.decorFilt, tempsig);
    diffOutsig = tempsig(DirAC_struct.decorDelay+1:end,:);
else
    diffOutsig = fftfilt(DirAC_struct.decorFilt, diffOutsig);
end
% remove delay due to windowing and truncate output to original length
DIRsig = dirOutsig(hopsize+(1:lInsig),:);
DIFFsig = diffOutsig(hopsize+(1:lInsig),:);
LSsig = DIRsig + DIFFsig;
end
