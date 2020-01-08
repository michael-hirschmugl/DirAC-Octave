function VMICdecMtx = computeVMICdecMtx(ls_dirs, alpha)
% virtual microphone type d(theta) = alpha + (1-alpha)*cos(theta)
% reshape ls_dirs, if 2D vector

if min(size(ls_dirs))==1
    if isrow(ls_dirs), ls_dirs = ls_dirs'; end
    ls_dirs(:,2) = zeros(size(ls_dirs));
end

% get the unit vectors of each vmic direction
Nvmic = size(ls_dirs, 1);
u_vmic = zeros(Nvmic, 3);
[u_vmic(:,1), u_vmic(:,2), u_vmic(:,3)] = sph2cart(ls_dirs(:,1)*pi/180, ls_dirs(:,2)*pi/180, ones(Nvmic, 1));

% divide dipoles with /sqrt(2) due to B-format convention
VMICdecMtx = [alpha*ones(Nvmic, 1) 1/sqrt(2)*(1-alpha)*u_vmic]';
end