function [diffuseFilterspec, DirAC_struct] = updateDiffuseFilters(pars, DirAC_struct)
 
    diff = pars(:,4);
    % Combine separation filters with approximate correction for the
    % effect of virtual microphones to the diffuse sound energy, 
    % and energy weights per loudspeaker
    diffuseFilterspec = sqrt(diff) * (DirAC_struct.diffCorrection.*DirAC_struct.lsDiffCoeff);
end