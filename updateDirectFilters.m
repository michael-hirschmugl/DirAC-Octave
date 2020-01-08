function [directFilterspec, DirAC_struct] = updateDirectFilters(pars, DirAC_struct)
 
    nOutChan = DirAC_struct.nOutChan;
    azi = pars(:,1);
    elev = pars(:,2);
    energy = pars(:,3);
    diff = pars(:,4);
    ndiff_sqrt = sqrt(1-diff); % diffuse sound suppresion filter
    ndiff_energy = energy.*(1-diff); % non-diffuse energy amount    
    % Amplitude panning gain filters
    Alpha = DirAC_struct.alpha_gain;  
    if DirAC_struct.dimension == 3
        % look-up the corresponding VBAP gains from the table
        aziIndex = round(mod(azi+180,360)/2);
        elevIndex = round((elev+90)/5);
        idx3D = elevIndex*181+aziIndex+1;
        gains = DirAC_struct.VBAPtable(idx3D,:);
    else   
        % look-up the corresponding VBAP gains from the table
        idx2D = round(mod(azi+180,360))+1;
        gains = DirAC_struct.VBAPtable(idx2D,:);
    end
    % recursive smoothing of gains (energy-weighted)
    gains_smooth = Alpha.*DirAC_struct.gains_smooth + (1-Alpha).*(ndiff_energy * ones(1,nOutChan)).*gains;
    % store smoothed gains for next update (before re-normalization)
    DirAC_struct.gains_smooth = gains_smooth;
    % re-normalization of smoothed gains to unity power
    gains_smooth = gains_smooth .* (sqrt(1./(sum(gains_smooth.^2,2)+eps))*ones(1,nOutChan));
    % Combine separation filters with panning filters, including 
    % approximate correction for the effect of virtual microphones 
    % to the direct sound
    dirCorrection = (1./sqrt(1 + diff*(DirAC_struct.invQ-1)))*ones(1,nOutChan);
    directFilterspec = gains_smooth .* (ndiff_sqrt*ones(1,nOutChan)) .* dirCorrection;
end