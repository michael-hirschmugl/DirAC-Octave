function [pars, DirAC_struct] = computeDirectionalParameters(insigSpec, DirAC_struct)

    %%% B-format analysis
    w = insigSpec(:,1); % omni
    X = insigSpec(:,2:4)/sqrt(2); 
    % dipoles /cancel B-format dipole convention
    Intensity = real(conj(w)*ones(1,3) .* X); 
    % spatially reversed normalized active intensity
    energy = (abs(w).^2 + sum(abs(X).^2,2))/2; 
    % normalized energy density
    % direction-of-arrival parameters
    alpha_dir = DirAC_struct.alpha_dir;
    Alpha_dir = alpha_dir*ones(1,3);  
    Intensity_short_smooth = Alpha_dir.*DirAC_struct.Intensity_short_smooth + (1-Alpha_dir).*Intensity;
    azi = atan2(Intensity_short_smooth(:,2), Intensity_short_smooth(:,1))*180/pi;
    elev = atan2(Intensity_short_smooth(:,3), sqrt(sum(Intensity_short_smooth(:,1:2).^2,2)))*180/pi;
    % diffuseness parameter 
    alpha_diff = DirAC_struct.alpha_diff;
    Alpha_diff = alpha_diff*ones(1,3);  
    Intensity_smooth = Alpha_diff.*DirAC_struct.Intensity_smooth + (1-Alpha_diff).*Intensity;
    Intensity_smooth_norm = sqrt(sum(Intensity_smooth.^2,2));
    energy_smooth = alpha_diff.*DirAC_struct.energy_smooth + (1-alpha_diff).*energy;
    diffuseness = 1 - Intensity_smooth_norm./(energy_smooth + eps);
    diffuseness(diffuseness<eps) = eps;
    diffuseness(diffuseness>1-eps) = 1-eps;  
    % store parameters
    pars = [azi elev energy diffuseness];
    % update values for recursive smoothing
    DirAC_struct.Intensity_short_smooth = Intensity_short_smooth;
    DirAC_struct.Intensity_smooth = Intensity_smooth;
    DirAC_struct.energy_smooth = energy_smooth;
end