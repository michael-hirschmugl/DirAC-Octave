%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fpart npart] = makepart_constcut(first_band, bandsize, channels)
%%%% Compute auditory frequency bands
erb_bands = zeros(100,1); erb_bands(1) = first_band; lastband = 100; i = 2;
freq_upper_band = erb_bands(1);
while freq_upper_band < 20000
    erb = 24.7 + 0.108 * freq_upper_band;  % Compute the width of the band.
    % Compute the new upper limit of the band.
    freq_upper_band = freq_upper_band + bandsize*erb;
    erb_bands(i) = freq_upper_band;
    i = i + 1;
end
lastband = min([lastband i-1]);
erb_bands = round(erb_bands);
erb_bands = erb_bands(1:lastband);
erb_bands(lastband) = 22000;
fpart = erb_bands*ones(1,channels);
npart = size(fpart,1);
end